const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const db = require('../db');
const config = require('../config/config');
const { authenticate } = require('../middleware/auth');
const { registerLimiter, loginLimiter } = require('../middleware/rateLimiter');

const router = express.Router();

function createToken(userId, role) {
  return jwt.sign(
    { sub: userId, role },
    config.secretKey,
    { expiresIn: config.accessTokenExpireMinutes * 60 }
  );
}

function safeUser(user) {
  const { password_hash, ...rest } = user;
  return rest;
}

router.post('/register', registerLimiter, async (req, res) => {
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
  const token = createToken(user.id, user.role);
  return res.status(201).json({ access_token: token, token_type: 'bearer', user: safeUser(user) });
});

router.post('/login', loginLimiter, async (req, res) => {
  const { phone, password } = req.body;
  if (!phone || !password) {
    return res.status(422).json({ detail: 'phone and password are required' });
  }
  const { rows } = await db.query('SELECT * FROM users WHERE phone = $1', [phone]);
  const user = rows[0];
  if (!user || !(await bcrypt.compare(password, user.password_hash))) {
    return res.status(401).json({ detail: 'Incorrect phone or password' });
  }
  const token = createToken(user.id, user.role);
  return res.json({ access_token: token, token_type: 'bearer', user: safeUser(user) });
});

router.get('/me', authenticate, (req, res) => {
  const { password_hash, ...user } = req.user;
  res.json(user);
});

module.exports = router;