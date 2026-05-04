const express = require('express');
const { v4: uuidv4 } = require('uuid');
const db = require('../db');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.get('/profile', authenticate, async (req, res) => {
  const { rows } = await db.query(
    'SELECT * FROM therapist_profiles WHERE user_id = $1', [req.user.id]
  );
  if (!rows.length) return res.status(404).json({ detail: 'Therapist profile not found' });
  res.json(rows[0]);
});

router.post('/profile', authenticate, async (req, res) => {
  const existing = await db.query(
    'SELECT id FROM therapist_profiles WHERE user_id = $1', [req.user.id]
  );
  if (existing.rows.length) return res.status(400).json({ detail: 'Profile already exists' });

  const { specialization, years_of_experience, qualification, clinic_name, clinic_address, rating, total_sessions, languages } = req.body;
  const id = uuidv4();
  const { rows } = await db.query(
    `INSERT INTO therapist_profiles
       (id, user_id, specialization, years_of_experience, qualification,
        clinic_name, clinic_address, rating, total_sessions, languages)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) RETURNING *`,
    [id, req.user.id, specialization, years_of_experience, qualification,
     clinic_name, clinic_address, rating || 0, total_sessions || 0,
     JSON.stringify(languages || [])]
  );
  res.status(201).json(rows[0]);
});

router.put('/profile', authenticate, async (req, res) => {
  const existing = await db.query(
    'SELECT * FROM therapist_profiles WHERE user_id = $1', [req.user.id]
  );
  if (!existing.rows.length) return res.status(404).json({ detail: 'Therapist profile not found' });

  const fields = ['specialization', 'years_of_experience', 'qualification',
                  'clinic_name', 'clinic_address', 'rating', 'total_sessions', 'languages'];
  const updates = [];
  const values = [];
  let idx = 1;

  for (const field of fields) {
    if (req.body[field] !== undefined) {
      updates.push(`${field} = $${idx++}`);
      values.push(field === 'languages' ? JSON.stringify(req.body[field]) : req.body[field]);
    }
  }
  if (!updates.length) return res.json(existing.rows[0]);

  updates.push(`updated_at = NOW()`);
  values.push(req.user.id);
  const { rows } = await db.query(
    `UPDATE therapist_profiles SET ${updates.join(', ')} WHERE user_id = $${idx} RETURNING *`,
    values
  );
  res.json(rows[0]);
});

module.exports = router;