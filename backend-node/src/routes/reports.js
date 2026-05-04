const express = require('express');
const db = require('../db');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.get('/progress/:childId', authenticate, async (req, res) => {
  const { childId } = req.params;

  const childRes = await db.query('SELECT * FROM children WHERE id = $1', [childId]);
  if (!childRes.rows.length) return res.json({ error: 'Child not found' });
  const child = childRes.rows[0];

  const sessionsRes = await db.query(
    `SELECT * FROM sessions WHERE child_id = $1 ORDER BY scheduled_at DESC LIMIT 10`,
    [childId]
  );
  const sessions = sessionsRes.rows;
  const sessionIds = sessions.map(s => s.id);

  let notes = [];
  if (sessionIds.length) {
    const notesRes = await db.query(
      `SELECT * FROM session_notes WHERE session_id = ANY($1)`,
      [sessionIds]
    );
    notes = notesRes.rows;
  }

  const feedbackRes = await db.query(
    `SELECT * FROM daily_feedback WHERE child_id = $1
     ORDER BY feedback_date DESC LIMIT 30`,
    [childId]
  );
  const feedbacks = feedbackRes.rows;

  const scoreFields = ['attention_score', 'participation_score', 'mood_score',
                       'progress_score', 'behavior_score'];
  const avgScores = {};
  for (const field of scoreFields) {
    const vals = notes.map(n => n[field]).filter(v => v != null);
    avgScores[field] = vals.length
      ? Math.round(vals.reduce((a, b) => a + b, 0) / vals.length * 100) / 100
      : null;
  }

  const sessionsCompleted = sessions.filter(s => s.status === 'completed').length;
  const sessionsScheduled = sessions.length;
  const attendancePercent = sessionsScheduled > 0
    ? Math.round(sessionsCompleted / sessionsScheduled * 100) : 0;

  const allVals = Object.values(avgScores).filter(v => v != null);
  const averageProgress = allVals.length
    ? Math.round(allVals.reduce((a, b) => a + b, 0) / allVals.length * 100) / 100 : 0;

  const progressTrend = [...notes].reverse().slice(0, 8).map((n, i) => ({
    label: `W${i + 1}`,
    score: parseFloat(n.progress_score || 0),
  }));

  const therapistNote = notes.length && notes[0].next_session_plan
    ? notes[0].next_session_plan : null;

  res.json({
    child_id: childId,
    child_name: child.name,
    sessions_completed: sessionsCompleted,
    sessions_scheduled: sessionsScheduled,
    attendance_percent: attendancePercent,
    average_progress: averageProgress,
    average_therapy_scores: avgScores,
    total_feedback_entries: feedbacks.length,
    progress_trend: progressTrend,
    therapist_note: therapistNote,
  });
});

module.exports = router;