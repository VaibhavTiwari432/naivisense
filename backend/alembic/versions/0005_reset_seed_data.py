"""Reset seed data: single admin 2026001, synthetic therapists/children/sessions

Revision ID: 0005
Revises: 0004
Create Date: 2026-04-25
"""
from alembic import op

revision = '0005'
down_revision = '0004'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # ── remove old seed accounts (0003 seeds) ────────────────────────────────
    op.execute(
        "DELETE FROM users WHERE phone IN "
        "('0000000001','1111111111','2222222222')"
    )

    # ── users ─────────────────────────────────────────────────────────────────
    op.execute("""
        INSERT INTO users (id, phone, name, role, password_hash, email,
                           is_verified, is_active, created_at, updated_at)
        VALUES
          ('cf6bc814-bce2-42ce-8e7c-af062af4f269',
           '2026001', 'Admin User', 'admin',
           '$2b$12$xn2YkCc.RIDFFOwaCtKmAuEtNfT7EugpKqCfowz18IRPB./cnjlb2',
           NULL, TRUE, TRUE,
           '2026-04-25 12:00:00', '2026-04-25 12:00:00'),

          ('ccfd12aa-171e-471e-a929-9b4cdef3866e',
           '9876500001', 'Dr. Priya Mehta', 'therapist',
           '$2b$12$HcIjCjDSd8qL9BJdbtZsKuYVXV4xNdaoGv.n6doueOJxzVa5mDdJm',
           NULL, TRUE, TRUE,
           '2026-04-25 12:00:00', '2026-04-25 12:00:00'),

          ('8d9adf30-fa5b-4960-93d0-e4b97be98330',
           '9876500002', 'Dr. Rahul Verma', 'therapist',
           '$2b$12$MBMJuHiGcM4bZ4sBIRRlHOVenNc/biWL8DQFvUourlQM.yLMvlM.m',
           NULL, TRUE, TRUE,
           '2026-04-25 12:00:00', '2026-04-25 12:00:00'),

          ('f192adcf-72e4-4116-805a-db1829bc4a0a',
           '9876500003', 'Anita Sharma', 'parent',
           '$2b$12$sfiKnfJIOMfmLk.LrsV4U.mdwKFxen8nbtTp8uP0PLNbsW2KuVXGC',
           NULL, TRUE, TRUE,
           '2026-04-25 12:00:00', '2026-04-25 12:00:00'),

          ('3add8dcc-5064-4c8d-ba21-5f18b3b75843',
           '9876500004', 'Ramesh Patel', 'parent',
           '$2b$12$WIGZn.YQfovziD3mNxknvuhQNvTBJcz7cjyexAXjEn3ugRAQGNy6e',
           NULL, TRUE, TRUE,
           '2026-04-25 12:00:00', '2026-04-25 12:00:00')
    """)

    # ── therapist_profiles ────────────────────────────────────────────────────
    op.execute("""
        INSERT INTO therapist_profiles
              (id, user_id, specialization, years_of_experience, qualification,
               clinic_name, clinic_address, rating, total_sessions, languages,
               created_at, updated_at)
        VALUES
          ('11111111-0001-0001-0001-000000000001',
           'ccfd12aa-171e-471e-a929-9b4cdef3866e',
           'Speech Therapy', 6, 'M.Sc Speech-Language Pathology',
           'Priya Speech Clinic', 'Rajkot, Gujarat',
           4.8, 142,
           '["Hindi","Gujarati","English"]',
           '2026-04-25 12:00:00', '2026-04-25 12:00:00'),

          ('11111111-0002-0001-0001-000000000002',
           '8d9adf30-fa5b-4960-93d0-e4b97be98330',
           'Occupational Therapy', 4, 'B.Sc Occupational Therapy',
           'Rahul OT Centre', 'Ahmedabad, Gujarat',
           4.5, 89,
           '["Hindi","English"]',
           '2026-04-25 12:00:00', '2026-04-25 12:00:00')
    """)

    # ── children ──────────────────────────────────────────────────────────────
    op.execute("""
        INSERT INTO children
              (id, parent_id, therapist_id, name, date_of_birth, gender,
               diagnosis, therapy_goals, created_at, updated_at)
        VALUES
          ('22222222-0001-0001-0001-000000000001',
           'f192adcf-72e4-4116-805a-db1829bc4a0a',
           'ccfd12aa-171e-471e-a929-9b4cdef3866e',
           'Aarav Sharma', '2019-06-15', 'Boy', 'Speech Delay',
           '["Improve vocabulary","Sentence formation","Pronunciation"]',
           '2026-04-25 12:00:00', '2026-04-25 12:00:00'),

          ('22222222-0002-0001-0001-000000000002',
           'f192adcf-72e4-4116-805a-db1829bc4a0a',
           '8d9adf30-fa5b-4960-93d0-e4b97be98330',
           'Siya Sharma', '2020-03-22', 'Girl', 'Occupational Delay',
           '["Fine motor skills","Sensory regulation","Writing readiness"]',
           '2026-04-25 12:00:00', '2026-04-25 12:00:00'),

          ('22222222-0003-0001-0001-000000000003',
           '3add8dcc-5064-4c8d-ba21-5f18b3b75843',
           'ccfd12aa-171e-471e-a929-9b4cdef3866e',
           'Arjun Patel', '2018-11-08', 'Boy', 'Autism',
           '["Eye contact","Social interaction","Speech clarity"]',
           '2026-04-25 12:00:00', '2026-04-25 12:00:00')
    """)

    # ── sessions ──────────────────────────────────────────────────────────────
    op.execute("""
        INSERT INTO sessions
              (id, child_id, therapist_id, scheduled_at, duration_minutes,
               status, session_type, location, created_at, updated_at)
        VALUES
          ('33333333-0001-0001-0001-000000000001',
           '22222222-0001-0001-0001-000000000001',
           'ccfd12aa-171e-471e-a929-9b4cdef3866e',
           '2026-04-11 10:00:00', 45, 'completed', 'Individual', 'Clinic',
           '2026-04-25 12:00:00', '2026-04-25 12:00:00'),

          ('33333333-0002-0001-0001-000000000002',
           '22222222-0001-0001-0001-000000000001',
           'ccfd12aa-171e-471e-a929-9b4cdef3866e',
           '2026-04-18 10:00:00', 45, 'completed', 'Individual', 'Clinic',
           '2026-04-25 12:00:00', '2026-04-25 12:00:00'),

          ('33333333-0003-0001-0001-000000000003',
           '22222222-0003-0001-0001-000000000003',
           'ccfd12aa-171e-471e-a929-9b4cdef3866e',
           '2026-04-15 11:00:00', 60, 'completed', 'Individual', 'Clinic',
           '2026-04-25 12:00:00', '2026-04-25 12:00:00'),

          ('33333333-0004-0001-0001-000000000004',
           '22222222-0001-0001-0001-000000000001',
           'ccfd12aa-171e-471e-a929-9b4cdef3866e',
           '2026-05-02 10:00:00', 45, 'scheduled', 'Individual', 'Clinic',
           '2026-04-25 12:00:00', '2026-04-25 12:00:00')
    """)

    # ── session_notes ─────────────────────────────────────────────────────────
    op.execute("""
        INSERT INTO session_notes
              (id, session_id, therapist_id,
               attention_score, participation_score, mood_score,
               progress_score, behavior_score,
               observations, next_session_plan, created_at, updated_at)
        VALUES
          ('44444444-0001-0001-0001-000000000001',
           '33333333-0001-0001-0001-000000000001',
           'ccfd12aa-171e-471e-a929-9b4cdef3866e',
           3, 4, 4, 3, 4,
           'Aarav showed good engagement today. Practiced 15 new vocabulary words. Sentence formation improving gradually.',
           'Focus on 2-word combinations and greetings.',
           '2026-04-25 12:00:00', '2026-04-25 12:00:00'),

          ('44444444-0002-0001-0001-000000000002',
           '33333333-0002-0001-0001-000000000002',
           'ccfd12aa-171e-471e-a929-9b4cdef3866e',
           4, 4, 5, 4, 5,
           'Excellent session. Aarav successfully formed 3-word sentences. Very motivated.',
           'Introduce question words (what, where). Practice at home.',
           '2026-04-25 12:00:00', '2026-04-25 12:00:00'),

          ('44444444-0003-0001-0001-000000000003',
           '33333333-0003-0001-0001-000000000003',
           'ccfd12aa-171e-471e-a929-9b4cdef3866e',
           3, 3, 3, 3, 3,
           'Arjun was slightly distracted today. Made some eye contact during activities.',
           'Sensory play activities before speech work. Eye contact games.',
           '2026-04-25 12:00:00', '2026-04-25 12:00:00')
    """)

    # ── daily_feedback ────────────────────────────────────────────────────────
    op.execute("""
        INSERT INTO daily_feedback
              (id, child_id, parent_id, feedback_date,
               mood_score, sleep_score, appetite_score, cooperation_score,
               home_practice_done, notes, created_at)
        VALUES
          ('55555555-0001-0001-0001-000000000001',
           '22222222-0001-0001-0001-000000000001',
           'f192adcf-72e4-4116-805a-db1829bc4a0a',
           '2026-04-24', 4, 4, 5, 4, TRUE,
           'He practiced naming objects at home. Very enthusiastic!',
           '2026-04-25 12:00:00'),

          ('55555555-0002-0001-0001-000000000002',
           '22222222-0001-0001-0001-000000000001',
           'f192adcf-72e4-4116-805a-db1829bc4a0a',
           '2026-04-23', 3, 3, 4, 3, FALSE,
           'Busy day, could not do practice. Will try tomorrow.',
           '2026-04-25 12:00:00')
    """)


def downgrade() -> None:
    op.execute("DELETE FROM daily_feedback WHERE id LIKE '55555555%'")
    op.execute("DELETE FROM session_notes WHERE id LIKE '44444444%'")
    op.execute("DELETE FROM sessions WHERE id LIKE '33333333%'")
    op.execute("DELETE FROM children WHERE id LIKE '22222222%'")
    op.execute("DELETE FROM therapist_profiles WHERE id LIKE '11111111%'")
    op.execute(
        "DELETE FROM users WHERE phone IN "
        "('2026001','9876500001','9876500002','9876500003','9876500004')"
    )
