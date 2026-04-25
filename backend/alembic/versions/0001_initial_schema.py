"""Initial schema — all tables

Revision ID: 0001
Revises:
Create Date: 2026-04-25
"""
from alembic import op
import sqlalchemy as sa

revision = '0001'
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    # ── users ─────────────────────────────────────────────────────────────────
    op.create_table(
        'users',
        sa.Column('id', sa.String(36), primary_key=True),
        sa.Column('name', sa.String(255), nullable=False),
        sa.Column('phone', sa.String(20), nullable=False, unique=True),
        sa.Column('email', sa.String(255), nullable=True, unique=True),
        sa.Column('hashed_password', sa.String(255), nullable=False),
        sa.Column('role', sa.String(20), nullable=False),
        sa.Column('is_active', sa.Boolean(), default=True),
        sa.Column('is_verified', sa.Boolean(), default=False),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
    )
    op.create_index('ix_users_phone', 'users', ['phone'], unique=True)
    op.create_index('ix_users_email', 'users', ['email'], unique=True)

    # ── therapist_profiles ────────────────────────────────────────────────────
    op.create_table(
        'therapist_profiles',
        sa.Column('id', sa.String(36), primary_key=True),
        sa.Column('user_id', sa.String(36), sa.ForeignKey('users.id'), nullable=False, unique=True),
        sa.Column('specialization', sa.String(255), nullable=True),
        sa.Column('qualification', sa.String(255), nullable=True),
        sa.Column('experience_years', sa.Integer(), nullable=True),
        sa.Column('bio', sa.Text(), nullable=True),
        sa.Column('availability', sa.JSON(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
    )

    # ── children ──────────────────────────────────────────────────────────────
    op.create_table(
        'children',
        sa.Column('id', sa.String(36), primary_key=True),
        sa.Column('parent_id', sa.String(36), sa.ForeignKey('users.id'), nullable=False),
        sa.Column('therapist_id', sa.String(36), sa.ForeignKey('users.id'), nullable=True),
        sa.Column('name', sa.String(255), nullable=False),
        sa.Column('date_of_birth', sa.Date(), nullable=True),
        sa.Column('gender', sa.String(10), nullable=True),
        sa.Column('diagnosis', sa.String(255), nullable=True),
        sa.Column('photo_url', sa.String(500), nullable=True),
        sa.Column('therapy_goals', sa.JSON(), nullable=True),
        sa.Column('medical_notes', sa.Text(), nullable=True),
        sa.Column('emergency_contact', sa.JSON(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
    )
    op.create_index('ix_children_parent_id', 'children', ['parent_id'])
    op.create_index('ix_children_therapist_id', 'children', ['therapist_id'])

    # ── sessions ──────────────────────────────────────────────────────────────
    op.create_table(
        'sessions',
        sa.Column('id', sa.String(36), primary_key=True),
        sa.Column('child_id', sa.String(36), sa.ForeignKey('children.id'), nullable=False),
        sa.Column('therapist_id', sa.String(36), sa.ForeignKey('users.id'), nullable=False),
        sa.Column('scheduled_at', sa.DateTime(), nullable=False),
        sa.Column('duration_minutes', sa.Integer(), nullable=True),
        sa.Column('session_type', sa.String(100), nullable=True),
        sa.Column('location', sa.String(255), nullable=True),
        sa.Column('status', sa.String(20), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
    )
    op.create_index('ix_sessions_child_id', 'sessions', ['child_id'])
    op.create_index('ix_sessions_therapist_id', 'sessions', ['therapist_id'])
    op.create_index('ix_sessions_scheduled_at', 'sessions', ['scheduled_at'])

    # ── session_notes ─────────────────────────────────────────────────────────
    op.create_table(
        'session_notes',
        sa.Column('id', sa.String(36), primary_key=True),
        sa.Column('session_id', sa.String(36), sa.ForeignKey('sessions.id'), nullable=False, unique=True),
        sa.Column('therapist_id', sa.String(36), sa.ForeignKey('users.id'), nullable=False),
        sa.Column('attention_score', sa.Integer(), nullable=True),
        sa.Column('participation_score', sa.Integer(), nullable=True),
        sa.Column('mood_score', sa.Integer(), nullable=True),
        sa.Column('progress_score', sa.Integer(), nullable=True),
        sa.Column('behavior_score', sa.Integer(), nullable=True),
        sa.Column('observations', sa.Text(), nullable=True),
        sa.Column('goals_worked_on', sa.JSON(), nullable=True),
        sa.Column('next_session_plan', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
    )

    # ── daily_feedback ────────────────────────────────────────────────────────
    op.create_table(
        'daily_feedback',
        sa.Column('id', sa.String(36), primary_key=True),
        sa.Column('child_id', sa.String(36), sa.ForeignKey('children.id'), nullable=False),
        sa.Column('parent_id', sa.String(36), sa.ForeignKey('users.id'), nullable=False),
        sa.Column('feedback_date', sa.Date(), nullable=True),
        sa.Column('mood_score', sa.Integer(), nullable=True),
        sa.Column('sleep_score', sa.Integer(), nullable=True),
        sa.Column('appetite_score', sa.Integer(), nullable=True),
        sa.Column('cooperation_score', sa.Integer(), nullable=True),
        sa.Column('home_practice_done', sa.Boolean(), default=False),
        sa.Column('notes', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
    )
    op.create_index('ix_feedback_child_date', 'daily_feedback', ['child_id', 'feedback_date'])

    # ── tasks ─────────────────────────────────────────────────────────────────
    op.create_table(
        'tasks',
        sa.Column('id', sa.String(36), primary_key=True),
        sa.Column('child_id', sa.String(36), sa.ForeignKey('children.id'), nullable=False),
        sa.Column('assigned_by', sa.String(36), sa.ForeignKey('users.id'), nullable=False),
        sa.Column('title', sa.String(255), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('status', sa.String(20), nullable=True),
        sa.Column('is_home_task', sa.Boolean(), default=False),
        sa.Column('due_date', sa.DateTime(), nullable=True),
        sa.Column('completed_at', sa.DateTime(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
    )
    op.create_index('ix_tasks_child_id', 'tasks', ['child_id'])

    # ── alerts ────────────────────────────────────────────────────────────────
    op.create_table(
        'alerts',
        sa.Column('id', sa.String(36), primary_key=True),
        sa.Column('user_id', sa.String(36), sa.ForeignKey('users.id'), nullable=False),
        sa.Column('alert_type', sa.String(50), nullable=True),
        sa.Column('message', sa.Text(), nullable=True),
        sa.Column('is_read', sa.Boolean(), default=False),
        sa.Column('created_at', sa.DateTime(), nullable=True),
    )
    op.create_index('ix_alerts_user_id', 'alerts', ['user_id'])


def downgrade() -> None:
    op.drop_table('alerts')
    op.drop_table('tasks')
    op.drop_table('daily_feedback')
    op.drop_table('session_notes')
    op.drop_table('sessions')
    op.drop_table('children')
    op.drop_table('therapist_profiles')
    op.drop_table('users')
