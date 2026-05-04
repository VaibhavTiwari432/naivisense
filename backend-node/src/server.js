require('dotenv').config();
const app = require('./app');
const config = require('./config/config');
const db = require('./db');

async function runMigrations() {
  console.log('Running migrations...');
  const { migrate } = require('./db/migrate');
  await migrate();
}

async function start() {
  try {
    // Verify DB connection
    await db.query('SELECT 1');
    console.log('Database connected.');
  } catch (err) {
    console.error('Failed to connect to database:', err.message);
    process.exit(1);
  }

  app.listen(config.port, () => {
    console.log(`NaiviSense API running on http://localhost:${config.port} (${config.environment})`);
  });
}

start();