require('dotenv').config();
const db = require('./index');

async function migrate() {
  console.log('Running database migrations...');

  await db.query(`
    CREATE TABLE IF NOT EXISTS users (
      id            TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
      phone         TEXT UNIQUE NOT NULL,
      email         TEXT UNIQUE,
      name          TEXT NOT NULL,
      role          TEXT NOT NULL CHECK (role IN ('therapist','parent','admin')),
      password_hash TEXT NOT NULL,
      photo_url     TEXT,
      is_verified   BOOLEAN NOT NULL DEFAULT FALSE,
      is_active     BOOLEAN NOT NULL DEFAULT TRUE,
      created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
    )
  `);

  await db.query(`
    CREATE TABLE IF NOT EXISTS therapist_profiles (
      id                  TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
      user_id             TEXT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
      specialization      TEXT,
      years_of_experience INTEGER,
      qualification       TEXT,
      clinic_name         TEXT,
      clinic_address      TEXT,
      rating              REAL DEFAULT 0.0,
      total_sessions      INTEGER DEFAULT 0,
      languages           JSONB DEFAULT '[]',
      created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
    )
  `);

  await db.query(`
    CREATE TABLE IF NOT EXISTS children (
      id                TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
      parent_id         TEXT NOT NULL REFERENCES users(id),
      therapist_id      TEXT REFERENCES users(id),
      name              TEXT NOT NULL,
      date_of_birth     DATE,
      gender            TEXT,
      diagnosis         TEXT,
      therapy_goals     JSONB DEFAULT '[]',
      medical_notes     TEXT,
      emergency_contact TEXT,
      photo_url         TEXT,
      created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
    )
  `);

  await db.query(`
    CREATE TABLE IF NOT EXISTS sessions (
      id               TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
      child_id         TEXT NOT NULL REFERENCES children(id),
      therapist_id     TEXT NOT NULL REFERENCES users(id),
      scheduled_at     TIMESTAMPTZ NOT NULL,
      duration_minutes INTEGER DEFAULT 45,
      session_type     TEXT DEFAULT 'Individual',
      location         TEXT,
      status           TEXT NOT NULL DEFAULT 'scheduled'
                         CHECK (status IN ('scheduled','in_progress','completed','cancelled')),
      created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
    )
  `);

  await db.query(`
    CREATE TABLE IF NOT EXISTS session_notes (
      id                  TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
      session_id          TEXT UNIQUE NOT NULL REFERENCES sessions(id),
      therapist_id        TEXT NOT NULL REFERENCES users(id),
      attention_score     INTEGER CHECK (attention_score BETWEEN 1 AND 5),
      participation_score INTEGER CHECK (participation_score BETWEEN 1 AND 5),
      mood_score          INTEGER CHECK (mood_score BETWEEN 1 AND 5),
      progress_score      INTEGER CHECK (progress_score BETWEEN 1 AND 5),
      behavior_score      INTEGER CHECK (behavior_score BETWEEN 1 AND 5),
      observations        TEXT,
      goals_worked_on     JSONB DEFAULT '[]',
      next_session_plan   TEXT,
      created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
    )
  `);

  await db.query(`
    CREATE TABLE IF NOT EXISTS daily_feedback (
      id                 TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
      child_id           TEXT NOT NULL REFERENCES children(id),
      parent_id          TEXT NOT NULL REFERENCES users(id),
      feedback_date      DATE NOT NULL DEFAULT CURRENT_DATE,
      mood_score         INTEGER CHECK (mood_score BETWEEN 1 AND 5),
      sleep_score        INTEGER CHECK (sleep_score BETWEEN 1 AND 5),
      appetite_score     INTEGER CHECK (appetite_score BETWEEN 1 AND 5),
      cooperation_score  INTEGER CHECK (cooperation_score BETWEEN 1 AND 5),
      home_practice_done BOOLEAN DEFAULT FALSE,
      notes              TEXT,
      created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
    )
  `);

  await db.query(`
    CREATE TABLE IF NOT EXISTS tasks (
      id           TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
      child_id     TEXT NOT NULL REFERENCES children(id),
      assigned_by  TEXT NOT NULL REFERENCES users(id),
      title        TEXT NOT NULL,
      description  TEXT,
      is_home_task BOOLEAN DEFAULT FALSE,
      status       TEXT NOT NULL DEFAULT 'pending'
                     CHECK (status IN ('pending','in_progress','completed')),
      due_date     DATE,
      completed_at TIMESTAMPTZ,
      created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
    )
  `);

  await db.query(`
    CREATE TABLE IF NOT EXISTS alerts (
      id         TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
      user_id    TEXT NOT NULL REFERENCES users(id),
      alert_type TEXT,
      title      TEXT,
      message    TEXT,
      is_read    BOOLEAN DEFAULT FALSE,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    )
  `);

  // Performance indexes
  await db.query(`CREATE INDEX IF NOT EXISTS ix_children_parent_id     ON children(parent_id)`);
  await db.query(`CREATE INDEX IF NOT EXISTS ix_children_therapist_id  ON children(therapist_id)`);
  await db.query(`CREATE INDEX IF NOT EXISTS ix_sessions_child_id      ON sessions(child_id)`);
  await db.query(`CREATE INDEX IF NOT EXISTS ix_sessions_therapist_id  ON sessions(therapist_id)`);
  await db.query(`CREATE INDEX IF NOT EXISTS ix_sessions_scheduled_at  ON sessions(scheduled_at)`);
  await db.query(`CREATE INDEX IF NOT EXISTS ix_feedback_child_date    ON daily_feedback(child_id, feedback_date)`);
  await db.query(`CREATE INDEX IF NOT EXISTS ix_tasks_child_id         ON tasks(child_id)`);
  await db.query(`CREATE INDEX IF NOT EXISTS ix_alerts_user_id         ON alerts(user_id)`);

  console.log('Migrations complete.');
}

module.exports = { migrate };

// Run directly when called as a script
if (require.main === module) {
  migrate()
    .then(() => process.exit(0))
    .catch(err => { console.error('Migration failed:', err); process.exit(1); });
}