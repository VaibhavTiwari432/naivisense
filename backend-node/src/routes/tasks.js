const express = require('express');
const { v4: uuidv4 } = require('uuid');
const db = require('../db');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.get('/', authenticate, async (req, res) => {
  const { child_id } = req.query;
  let query = 'SELECT * FROM tasks WHERE assigned_by = $1';
  const values = [req.user.id];
  if (child_id) {
    query += ' AND child_id = $2';
    values.push(child_id);
  }
  const { rows } = await db.query(query, values);
  res.json(rows);
});

router.post('/', authenticate, async (req, res) => {
  const { child_id, title, description, is_home_task, status, due_date } = req.body;
  if (!child_id || !title) return res.status(422).json({ detail: 'child_id and title are required' });
  const id = uuidv4();
  const { rows } = await db.query(
    `INSERT INTO tasks (id, child_id, assigned_by, title, description, is_home_task, status, due_date)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8) RETURNING *`,
    [id, child_id, req.user.id, title, description || null,
     is_home_task || false, status || 'pending', due_date || null]
  );
  res.status(201).json(rows[0]);
});

router.put('/:taskId', authenticate, async (req, res) => {
  const existing = await db.query('SELECT * FROM tasks WHERE id = $1', [req.params.taskId]);
  if (!existing.rows.length) return res.status(404).json({ detail: 'Task not found' });

  const fields = ['title', 'description', 'is_home_task', 'status', 'due_date'];
  const updates = [];
  const values = [];
  let idx = 1;

  for (const field of fields) {
    if (req.body[field] !== undefined) {
      updates.push(`${field} = $${idx++}`);
      values.push(req.body[field]);
    }
  }

  if (req.body.status === 'completed') {
    updates.push(`completed_at = $${idx++}`);
    values.push(new Date().toISOString());
  }

  if (!updates.length) return res.json(existing.rows[0]);

  updates.push('updated_at = NOW()');
  values.push(req.params.taskId);
  const { rows } = await db.query(
    `UPDATE tasks SET ${updates.join(', ')} WHERE id = $${idx} RETURNING *`,
    values
  );
  res.json(rows[0]);
});

module.exports = router;