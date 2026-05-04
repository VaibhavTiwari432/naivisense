const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const db = require('../db');
const config = require('../config/config');
const { authenticate, requireAdmin } = require('../middleware/auth');

const router = express.Router();

router.post('/create-user', authenticate, requireAdmin, async (req, res) => {
  const { phone, email, name, role, password } = req.body;
  if (!phone || !name || !role || !password) {
    return res.status(422).json({ detail: 'phone, name, role, and password are required' });
  }
  const existing = await db.query('SELECT id FROM users WHERE phone = $1', [phone]);
  if (existing.rows.length) {
    return res.status(400).json({ detail: 'Phone number already registered' });
  }
  const passwordHash = await bcrypt.hash(password, 12);
  const id = uuidv4();
  const { rows } = await db.query(
    `INSERT INTO users (id, phone, email, name, role, password_hash)
     VALUES ($1,$2,$3,$4,$5,$6) RETURNING *`,
    [id, phone, email || null, name, role, passwordHash]
  );
  const user = rows[0];
  const token = jwt.sign(
    { sub: user.id, role: user.role },
    config.secretKey,
    { expiresIn: config.accessTokenExpireMinutes * 60 }
  );
  const { password_hash, ...safeUser } = user;
  res.status(201).json({ access_token: token, token_type: 'bearer', user: safeUser });
});

module.exports = router;