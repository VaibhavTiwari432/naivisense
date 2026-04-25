"""Reset seed data: single admin 2026001, synthetic therapists/children/sessions

Revision ID: 0005
Revises: 0004
Create Date: 2026-04-25
"""
from alembic import op
import sqlalchemy as sa
from datetime import datetime, timedelta

revision = '0005'
down_revision = '0004'
branch_labels = None
depends_on = None

NOW = datetime(2026, 4, 25, 12, 0, 0)

# ── IDs ───────────────────────────────────────────────────────────────────────
ADMIN_ID     = 'cf6bc814-bce2-42ce-8e7c-af062af4f269'
PRIYA_ID     = 'ccfd12aa-171e-471e-a929-9b4cdef3866e'
RAHUL_ID     = '8d9adf30-fa5b-4960-93d0-e4b97be98330'
ANITA_ID     = 'f192adcf-72e4-4116-805a-db1829bc4a0a'
RAMESH_ID    = '3add8dcc-5064-4c8d-ba21-5f18b3b75843'

PRIYA_PROFILE_ID  = '11111111-0001-0001-0001-000000000001'
RAHUL_PROFILE_ID  = '11111111-0002-0001-0001-000000000002'

AARAV_ID   = '22222222-0001-0001-0001-000000000001'
SIYA_ID    = '22222222-0002-0001-0001-000000000002'
ARJUN_ID   = '22222222-0003-0001-0001-000000000003'

SESSION_1  = '33333333-0001-0001-0001-000000000001'
SESSION_2  = '33333333-0002-0001-0001-000000000002'
SESSION_3  = '33333333-0003-0001-0001-000000000003'
SESSION_4  = '33333333-0004-0001-0001-000000000004'

NOTES_1 = '44444444-0001-0001-0001-000000000001'
NOTES_2 = '44444444-0002-0001-0001-000000000002'
NOTES_3 = '44444444-0003-0001-0001-000000000003'


def upgrade() -> None:
    # ── remove old seed accounts ──────────────────────────────────────────────
    op.execute(
        "DELETE FROM users WHERE phone IN "
        "('0000000001','1111111111','2222222222')"
    )

    # ── users ─────────────────────────────────────────────────────────────────
    users = sa.table(
        'users',
        sa.column('id'), sa.column('phone'), sa.column('name'),
        sa.column('role'), sa.column('password_hash'), sa.column('email'),
        sa.column('is_verified'), sa.column('created_at'), sa.column('updated_at'),
    )
    op.bulk_insert(users, [
        dict(id=ADMIN_ID,  phone='2026001',    name='Admin User',      role='admin',
             password_hash='$2b$12$xn2YkCc.RIDFFOwaCtKmAuEtNfT7EugpKqCfowz18IRPB./cnjlb2',
             email=None, is_verified=True, created_at=NOW, updated_at=NOW),
        dict(id=PRIYA_ID,  phone='9876500001', name='Dr. Priya Mehta', role='therapist',
             password_hash='$2b$12$HcIjCjDSd8qL9BJdbtZsKuYVXV4xNdaoGv.n6doueOJxzVa5mDdJm',
             email=None, is_verified=True, created_at=NOW, updated_at=NOW),
        dict(id=RAHUL_ID,  phone='9876500002', name='Dr. Rahul Verma', role='therapist',
             password_hash='$2b$12$MBMJuHiGcM4bZ4sBIRRlHOVenNc/biWL8DQFvUourlQM.yLMvlM.m',
             email=None, is_verified=True, created_at=NOW, updated_at=NOW),
        dict(id=ANITA_ID,  phone='9876500003', name='Anita Sharma',    role='parent',
             password_hash='$2b$12$sfiKnfJIOMfmLk.LrsV4U.mdwKFxen8nbtTp8uP0PLNbsW2KuVXGC',
             email=None, is_verified=True, created_at=NOW, updated_at=NOW),
        dict(id=RAMESH_ID, phone='9876500004', name='Ramesh Patel',    role='parent',
             password_hash='$2b$12$WIGZn.YQfovziD3mNxknvuhQNvTBJcz7cjyexAXjEn3ugRAQGNy6e',
             email=None, is_verified=True, created_at=NOW, updated_at=NOW),
    ])

    # ── therapist profiles ────────────────────────────────────────────────────
    profiles = sa.table(
        'therapist_profiles',
        sa.column('id'), sa.column('user_id'), sa.column('specialization'),
        sa.column('years_of_experience'), sa.column('qualification'),
        sa.column('clinic_name'), sa.column('clinic_address'),
        sa.column('rating'), sa.column('total_sessions'), sa.column('languages'),
        sa.column('created_at'), sa.column('updated_at'),
    )
    op.bulk_insert(profiles, [
        dict(id=PRIYA_PROFILE_ID, user_id=PRIYA_ID,
             specialization='Speech Therapy', years_of_experience=6,
             qualification='M.Sc Speech-Language Pathology',
             clinic_name='Priya Speech Clinic', clinic_address='Rajkot, Gujarat',
             rating=4.8, total_sessions=142,
             languages='["Hindi","Gujarati","English"]',
             created_at=NOW, updated_at=NOW),
        dict(id=RAHUL_PROFILE_ID, user_id=RAHUL_ID,
             specialization='Occupational Therapy', years_of_experience=4,
             qualification='B.Sc Occupational Therapy',
             clinic_name='Rahul OT Centre', clinic_address='Ahmedabad, Gujarat',
             rating=4.5, total_sessions=89,
             languages='["Hindi","English"]',
             created_at=NOW, updated_at=NOW),
    ])

    # ── children ──────────────────────────────────────────────────────────────
    children = sa.table(
        'children',
        sa.column('id'), sa.column('parent_id'), sa.column('therapist_id'),
        sa.column('name'), sa.column('date_of_birth'), sa.column('gender'),
        sa.column('diagnosis'), sa.column('therapy_goals'),
        sa.column('created_at'), sa.column('updated_at'),
    )
    op.bulk_insert(children, [
        dict(id=AARAV_ID, parent_id=ANITA_ID, therapist_id=PRIYA_ID,
             name='Aarav Sharma', date_of_birth=datetime(2019, 6, 15).date(),
             gender='Boy', diagnosis='Speech Delay',
             therapy_goals='["Improve vocabulary","Sentence formation","Pronunciation"]',
             created_at=NOW, updated_at=NOW),
        dict(id=SIYA_ID, parent_id=ANITA_ID, therapist_id=RAHUL_ID,
             name='Siya Sharma', date_of_birth=datetime(2020, 3, 22).date(),
             gender='Girl', diagnosis='Occupational Delay',
             therapy_goals='["Fine motor skills","Sensory regulation","Writing readiness"]',
             created_at=NOW, updated_at=NOW),
        dict(id=ARJUN_ID, parent_id=RAMESH_ID, therapist_id=PRIYA_ID,
             name='Arjun Patel', date_of_birth=datetime(2018, 11, 8).date(),
             gender='Boy', diagnosis='Autism',
             therapy_goals='["Eye contact","Social interaction","Speech clarity"]',
             created_at=NOW, updated_at=NOW),
    ])

    # ── sessions ──────────────────────────────────────────────────────────────
    sessions = sa.table(
        'sessions',
        sa.column('id'), sa.column('child_id'), sa.column('therapist_id'),
        sa.column('scheduled_at'), sa.column('duration_minutes'),
        sa.column('status'), sa.column('session_type'), sa.column('location'),
        sa.column('created_at'), sa.column('updated_at'),
    )
    op.bulk_insert(sessions, [
        dict(id=SESSION_1, child_id=AARAV_ID, therapist_id=PRIYA_ID,
             scheduled_at=NOW - timedelta(days=14), duration_minutes=45,
             status='completed', session_type='Individual', location='Clinic',
             created_at=NOW, updated_at=NOW),
        dict(id=SESSION_2, child_id=AARAV_ID, therapist_id=PRIYA_ID,
             scheduled_at=NOW - timedelta(days=7), duration_minutes=45,
             status='completed', session_type='Individual', location='Clinic',
             created_at=NOW, updated_at=NOW),
        dict(id=SESSION_3, child_id=ARJUN_ID, therapist_id=PRIYA_ID,
             scheduled_at=NOW - timedelta(days=10), duration_minutes=60,
             status='completed', session_type='Individual', location='Clinic',
             created_at=NOW, updated_at=NOW),
        dict(id=SESSION_4, child_id=AARAV_ID, therapist_id=PRIYA_ID,
             scheduled_at=NOW + timedelta(days=7), duration_minutes=45,
             status='scheduled', session_type='Individual', location='Clinic',
             created_at=NOW, updated_at=NOW),
    ])

    # ── session notes ─────────────────────────────────────────────────────────
    notes = sa.table(
        'session_notes',
        sa.column('id'), sa.column('session_id'), sa.column('therapist_id'),
        sa.column('attention_score'), sa.column('participation_score'),
        sa.column('mood_score'), sa.column('progress_score'), sa.column('behavior_score'),
        sa.column('observations'), sa.column('next_session_plan'),
        sa.column('created_at'), sa.column('updated_at'),
    )
    op.bulk_insert(notes, [
        dict(id=NOTES_1, session_id=SESSION_1, therapist_id=PRIYA_ID,
             attention_score=3, participation_score=4, mood_score=4,
             progress_score=3, behavior_score=4,
             observations='Aarav showed good engagement today. Practiced 15 new vocabulary words. Sentence formation improving gradually.',
             next_session_plan='Focus on 2-word combinations and greetings.',
             created_at=NOW, updated_at=NOW),
        dict(id=NOTES_2, session_id=SESSION_2, therapist_id=PRIYA_ID,
             attention_score=4, participation_score=4, mood_score=5,
             progress_score=4, behavior_score=5,
             observations='Excellent session. Aarav successfully formed 3-word sentences. Very motivated.',
             next_session_plan='Introduce question words (what, where). Practice at home.',
             created_at=NOW, updated_at=NOW),
        dict(id=NOTES_3, session_id=SESSION_3, therapist_id=PRIYA_ID,
             attention_score=3, participation_score=3, mood_score=3,
             progress_score=3, behavior_score=3,
             observations='Arjun was slightly distracted today. Made some eye contact during activities.',
             next_session_plan='Sensory play activities before speech work. Eye contact games.',
             created_at=NOW, updated_at=NOW),
    ])

    # ── daily feedback ────────────────────────────────────────────────────────
    feedback = sa.table(
        'daily_feedback',
        sa.column('id'), sa.column('child_id'), sa.column('parent_id'),
        sa.column('feedback_date'), sa.column('mood_score'), sa.column('sleep_score'),
        sa.column('appetite_score'), sa.column('cooperation_score'),
        sa.column('home_practice_done'), sa.column('notes'), sa.column('created_at'),
    )
    op.bulk_insert(feedback, [
        dict(id='55555555-0001-0001-0001-000000000001',
             child_id=AARAV_ID, parent_id=ANITA_ID,
             feedback_date=datetime(2026, 4, 24).date(),
             mood_score=4, sleep_score=4, appetite_score=5, cooperation_score=4,
             home_practice_done=True,
             notes='He practiced naming objects at home. Very enthusiastic!',
             created_at=NOW),
        dict(id='55555555-0002-0001-0001-000000000002',
             child_id=AARAV_ID, parent_id=ANITA_ID,
             feedback_date=datetime(2026, 4, 23).date(),
             mood_score=3, sleep_score=3, appetite_score=4, cooperation_score=3,
             home_practice_done=False,
             notes='Busy day, could not do practice. Will try tomorrow.',
             created_at=NOW),
    ])


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
