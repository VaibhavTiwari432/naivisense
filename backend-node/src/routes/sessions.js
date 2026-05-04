const express = require('express');
const { v4: uuidv4 } = require('uuid');
const db = require('../db');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.get('/', authenticate, async (req, res) => {
  const { rows } = await db.query(
    'SELECT * FROM sessions WHERE therapist_id = $1', [req.user.id]
  );
  res.json(rows);
});

router.get('/upcoming', authenticate, async (req, res) => {
  const { rows } = await db.query(
    `SELECT * FROM sessions
     WHERE therapist_id = $1 AND status = 'scheduled' AND scheduled_at >= NOW()
     ORDER BY scheduled_at`,
    [req.user.id]
  );
  res.json(rows);
});

router.post('/', authenticate, async (req, res) => {
  const { child_id, scheduled_at, duration_minutes, session_type, location } = req.body;
  if (!child_id || !scheduled_at) {
    return res.status(422).json({ detail: 'child_id and scheduled_at are required' });
  }
  const id = uuidv4();
  const { rows } = await db.query(
    `INSERT INTO sessions
       (id, child_id, therapist_id, scheduled_at, duration_minutes, session_type, location)
     VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING *`,
    [id, child_id, req.user.id, scheduled_at,
     duration_minutes || 45, session_type || 'Individual', location || null]
  );
  res.status(201).json(rows[0]);
});

router.post('/:sessionId/complete', authenticate, async (req, res) => {
  const { rows } = await db.query(
    `UPDATE sessions SET status = 'completed', updated_at = NOW()
     WHERE id = $1 RETURNING *`,
    [req.params.sessionId]
  );
  if (!rows.length) return res.status(404).json({ detail: 'Session not found' });
  res.json(rows[0]);
});

router.post('/:sessionId/notes', authenticate, async (req, res) => {
  const sessionCheck = await db.query('SELECT id FROM sessions WHERE id = $1', [req.params.sessionId]);
  if (!sessionCheck.rows.length) return res.status(404).json({ detail: 'Session not found' });

  const { attention_score, participation_score, mood_score, progress_score,
          behavior_score, observations, goals_worked_on, next_session_plan } = req.body;
  const id = uuidv4();
  const { rows } = await db.query(
    `INSERT INTO session_notes
       (id, session_id, therapist_id, attention_score, participation_score,
        mood_score, progress_score, behavior_score, observations, goals_worked_on, next_session_plan)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11) RETURNING *`,
    [id, req.params.sessionId, req.user.id, attention_score, participation_score,
     mood_score, progress_score, behavior_score, observations || null,
     JSON.stringify(goals_worked_on || []), next_session_plan || null]
  );
  res.status(201).json(rows[0]);
});

router.get('/:sessionId/notes', authenticate, async (req, res) => {
  const { rows } = await db.query(
    'SELECT * FROM session_notes WHERE session_id = $1', [req.params.sessionId]
  );
  if (!rows.length) return res.status(404).json({ detail: 'Notes not found' });
  res.json(rows[0]);
});

module.exports = router;