const express = require('express');
const { v4: uuidv4 } = require('uuid');
const db = require('../db');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.post('/daily', authenticate, async (req, res) => {
  const { child_id, mood_score, sleep_score, appetite_score, cooperation_score,
          home_practice_done, notes, feedback_date } = req.body;
  if (!child_id) return res.status(422).json({ detail: 'child_id is required' });

  const today = (feedback_date || new Date().toISOString().slice(0, 10));
  const existing = await db.query(
    `SELECT id FROM daily_feedback
     WHERE child_id = $1 AND parent_id = $2 AND feedback_date = $3`,
    [child_id, req.user.id, today]
  );
  if (existing.rows.length) {
    return res.status(400).json({ detail: 'Feedback already submitted for today' });
  }
  const id = uuidv4();
  const { rows } = await db.query(
    `INSERT INTO daily_feedback
       (id, child_id, parent_id, feedback_date, mood_score, sleep_score,
        appetite_score, cooperation_score, home_practice_done, notes)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) RETURNING *`,
    [id, child_id, req.user.id, today, mood_score, sleep_score,
     appetite_score, cooperation_score, home_practice_done || false, notes || null]
  );
  res.status(201).json(rows[0]);
});

router.get('/history/:childId', authenticate, async (req, res) => {
  const { rows } = await db.query(
    `SELECT * FROM daily_feedback WHERE child_id = $1
     ORDER BY feedback_date DESC LIMIT 30`,
    [req.params.childId]
  );
  res.json(rows);
});

module.exports = router;