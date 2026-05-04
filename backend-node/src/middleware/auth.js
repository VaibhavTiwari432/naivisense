const jwt = require('jsonwebtoken');
const config = require('../config/config');
const db = require('../db');

async function authenticate(req, res, next) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ detail: 'Could not validate credentials' });
  }
  const token = header.slice(7);
  try {
    const payload = jwt.verify(token, config.secretKey);
    const { rows } = await db.query('SELECT * FROM users WHERE id = $1', [payload.sub]);
    if (!rows.length) return res.status(401).json({ detail: 'Could not validate credentials' });
    req.user = rows[0];
    next();
  } catch {
    return res.status(401).json({ detail: 'Could not validate credentials' });
  }
}

function requireAdmin(req, res, next) {
  if (req.user?.role !== 'admin') {
    return res.status(403).json({ detail: 'Admin access required' });
  }
  next();
}

module.exports = { authenticate, requireAdmin };