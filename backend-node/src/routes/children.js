const express = require('express');
const { v4: uuidv4 } = require('uuid');
const db = require('../db');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.get('/', authenticate, async (req, res) => {
  const { role, id } = req.user;
  let rows;
  if (role === 'parent') {
    ({ rows } = await db.query('SELECT * FROM children WHERE parent_id = $1', [id]));
  } else if (role === 'therapist' || role === 'admin') {
    ({ rows } = await db.query(
      'SELECT * FROM children WHERE therapist_id = $1 OR parent_id = $1', [id]
    ));
  } else {
    rows = [];
  }
  res.json(rows);
});

router.post('/', authenticate, async (req, res) => {
  const { name, date_of_birth, gender, diagnosis, therapy_goals,
          medical_notes, emergency_contact, photo_url, therapist_id } = req.body;
  const id = uuidv4();
  const { rows } = await db.query(
    `INSERT INTO children
       (id, parent_id, therapist_id, name, date_of_birth, gender,
        diagnosis, therapy_goals, medical_notes, emergency_contact, photo_url)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11) RETURNING *`,
    [id, req.user.id, therapist_id || null, name, date_of_birth || null, gender || null,
     diagnosis || null, JSON.stringify(therapy_goals || []),
     medical_notes || null, emergency_contact || null, photo_url || null]
  );
  res.status(201).json(rows[0]);
});

router.get('/:childId', authenticate, async (req, res) => {
  const { rows } = await db.query('SELECT * FROM children WHERE id = $1', [req.params.childId]);
  if (!rows.length) return res.status(404).json({ detail: 'Child not found' });
  res.json(rows[0]);
});

router.put('/:childId', authenticate, async (req, res) => {
  const existing = await db.query('SELECT id FROM children WHERE id = $1', [req.params.childId]);
  if (!existing.rows.length) return res.status(404).json({ detail: 'Child not found' });

  const fields = ['name', 'date_of_birth', 'gender', 'diagnosis', 'therapy_goals',
                  'medical_notes', 'emergency_contact', 'photo_url', 'therapist_id'];
  const updates = [];
  const values = [];
  let idx = 1;

  for (const field of fields) {
    if (req.body[field] !== undefined) {
      updates.push(`${field} = $${idx++}`);
      values.push(field === 'therapy_goals' ? JSON.stringify(req.body[field]) : req.body[field]);
    }
  }
  if (!updates.length) {
    const { rows } = await db.query('SELECT * FROM children WHERE id = $1', [req.params.childId]);
    return res.json(rows[0]);
  }

  updates.push('updated_at = NOW()');
  values.push(req.params.childId);
  const { rows } = await db.query(
    `UPDATE children SET ${updates.join(', ')} WHERE id = $${idx} RETURNING *`,
    values
  );
  res.json(rows[0]);
});

module.exports = router;