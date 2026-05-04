const express = require('express');
const db = require('../db');
const config = require('../config/config');
const { authenticate } = require('../middleware/auth');
const svc = require('../services/intelligence');

const router = express.Router();

// AI-001: Skill Score
router.get('/skill-score/:childId', authenticate, async (req, res) => {
  const { childId } = req.params;
  const childRes = await db.query('SELECT * FROM children WHERE id = $1', [childId]);
  if (!childRes.rows.length) return res.status(404).json({ detail: 'Child not found' });
  const child = childRes.rows[0];

  const sessionRes = await db.query(
    'SELECT id FROM sessions WHERE child_id = $1', [childId]
  );
  const sessionIds = sessionRes.rows.map(r => r.id);

  let notes = [];
  if (sessionIds.length) {
    const notesRes = await db.query(
      'SELECT * FROM session_notes WHERE session_id = ANY($1)', [sessionIds]
    );
    notes = notesRes.rows;
  }

  const result = svc.computeSkillScore(child, notes);
  res.json({ child_id: childId, child_name: child.name, ...result });
});

// AI-003: Therapist Matching
router.get('/match-therapist/:childId', authenticate, async (req, res) => {
  const { childId } = req.params;
  const childRes = await db.query('SELECT * FROM children WHERE id = $1', [childId]);
  if (!childRes.rows.length) return res.status(404).json({ detail: 'Child not found' });
  const child = childRes.rows[0];

  const profilesRes = await db.query(
    `SELECT tp.*, u.id as user_id, u.name as user_name, u.role as user_role
     FROM therapist_profiles tp
     JOIN users u ON u.id = tp.user_id
     WHERE u.role = 'therapist'`
  );
  const profiles = profilesRes.rows.map(row => ({
    profile: {
      specialization: row.specialization,
      years_of_experience: row.years_of_experience,
      qualification: row.qualification,
      rating: row.rating,
      total_sessions: row.total_sessions,
    },
    user: { id: row.user_id, name: row.user_name },
  }));

  const matches = svc.matchTherapists(child, profiles);
  res.json({
    child_id: childId,
    child_name: child.name,
    diagnosis: child.diagnosis,
    therapy_goals: child.therapy_goals || [],
    matches,
  });
});

// AI-002: Auto-tag Session Notes
router.post('/auto-tag/:sessionId', authenticate, async (req, res) => {
  const { rows } = await db.query(
    'SELECT * FROM session_notes WHERE session_id = $1', [req.params.sessionId]
  );
  if (!rows.length) return res.status(404).json({ detail: 'Session notes not found' });
  const notes = rows[0];
  if (!notes.observations) return res.json({ session_id: req.params.sessionId, tags: [] });

  const tags = await svc.autoTagObservations(notes.observations, config.anthropicApiKey);
  res.json({ session_id: req.params.sessionId, tags });
});

// AI-004: Narrative Report
router.get('/generate-report/:childId', authenticate, async (req, res) => {
  const { childId } = req.params;
  const period = ['weekly', 'monthly'].includes(req.query.period) ? req.query.period : 'weekly';
  const days = period === 'weekly' ? 7 : 30;
  const since = new Date(Date.now() - days * 24 * 60 * 60 * 1000).toISOString();

  const childRes = await db.query('SELECT * FROM children WHERE id = $1', [childId]);
  if (!childRes.rows.length) return res.status(404).json({ detail: 'Child not found' });
  const child = childRes.rows[0];

  const sessionsRes = await db.query(
    'SELECT * FROM sessions WHERE child_id = $1 AND scheduled_at >= $2', [childId, since]
  );
  const sessions = sessionsRes.rows;
  const sessionIds = sessions.map(s => s.id);

  let notes = [];
  if (sessionIds.length) {
    const notesRes = await db.query(
      'SELECT * FROM session_notes WHERE session_id = ANY($1)', [sessionIds]
    );
    notes = notesRes.rows;
  }

  const sinceDate = since.slice(0, 10);
  const feedbackRes = await db.query(
    `SELECT * FROM daily_feedback WHERE child_id = $1 AND feedback_date >= $2`,
    [childId, sinceDate]
  );
  const feedbacks = feedbackRes.rows;

  const completed = sessions.filter(s => s.status === 'completed').length;
  const scoreFields = ['attention_score', 'participation_score', 'mood_score', 'progress_score', 'behavior_score'];
  const dimAvgs = {};
  for (const field of scoreFields) {
    const vals = notes.map(n => n[field]).filter(v => v != null);
    dimAvgs[field] = vals.length
      ? Math.round(vals.reduce((a, b) => a + b, 0) / vals.length * 100) / 100 : 0;
  }

  const nonZero = Object.fromEntries(Object.entries(dimAvgs).filter(([, v]) => v > 0));
  const strongest = Object.keys(nonZero).length
    ? Object.entries(nonZero).sort((a, b) => b[1] - a[1])[0][0] : 'N/A';
  const weakest = Object.keys(nonZero).length
    ? Object.entries(nonZero).sort((a, b) => a[1] - b[1])[0][0] : 'N/A';

  const goals = [...new Set(notes.flatMap(n => n.goals_worked_on || []))].slice(0, 5);
  const latestNote = notes.length ? notes[0].next_session_plan : null;
  const fbMood = feedbacks.map(f => f.mood_score).filter(v => v != null);
  const avgFeedbackMood = fbMood.length
    ? Math.round(fbMood.reduce((a, b) => a + b, 0) / fbMood.length * 10) / 10 : 0;

  const data = {
    child_name: child.name,
    sessions_completed: completed,
    avg_progress: dimAvgs['progress_score'] || 0,
    strongest: strongest.replace(/_score$/, '').replace(/_/g, ' '),
    weakest: weakest.replace(/_score$/, '').replace(/_/g, ' '),
    goals,
    latest_note: latestNote,
    avg_feedback_mood: avgFeedbackMood,
  };

  const narrative = await svc.generateNarrativeReport(data, period, config.anthropicApiKey);
  res.json({ child_id: childId, child_name: child.name, period, narrative });
});

module.exports = router;