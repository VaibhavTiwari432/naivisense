const { Pool } = require('pg');
const config = require('../config/config');

const pool = new Pool({ connectionString: config.databaseUrl });

pool.on('error', (err) => {
  console.error('Unexpected DB pool error:', err);
});

module.exports = {
  query: (text, params) => pool.query(text, params),
  pool,
};