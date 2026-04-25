"""Fix all model/migration column mismatches

Revision ID: 0004
Revises: 0003
Create Date: 2026-04-25
"""
from alembic import op
import sqlalchemy as sa

revision = '0004'
down_revision = '0003'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # users — missing photo_url
    op.add_column('users', sa.Column('photo_url', sa.String(500), nullable=True))

    # therapist_profiles — rename experience_years → years_of_experience
    op.alter_column('therapist_profiles', 'experience_years',
                    new_column_name='years_of_experience')
    # therapist_profiles — missing columns
    op.add_column('therapist_profiles', sa.Column('clinic_name', sa.String(255), nullable=True))
    op.add_column('therapist_profiles', sa.Column('clinic_address', sa.String(500), nullable=True))
    op.add_column('therapist_profiles', sa.Column('rating', sa.Float(), nullable=True, server_default='0'))
    op.add_column('therapist_profiles', sa.Column('total_sessions', sa.Integer(), nullable=True, server_default='0'))
    op.add_column('therapist_profiles', sa.Column('languages', sa.JSON(), nullable=True))
    op.add_column('therapist_profiles', sa.Column('updated_at', sa.DateTime(), nullable=True))

    # alerts — missing title column
    op.add_column('alerts', sa.Column('title', sa.String(255), nullable=True))


def downgrade() -> None:
    op.drop_column('alerts', 'title')
    op.drop_column('therapist_profiles', 'updated_at')
    op.drop_column('therapist_profiles', 'languages')
    op.drop_column('therapist_profiles', 'total_sessions')
    op.drop_column('therapist_profiles', 'rating')
    op.drop_column('therapist_profiles', 'clinic_address')
    op.drop_column('therapist_profiles', 'clinic_name')
    op.alter_column('therapist_profiles', 'years_of_experience',
                    new_column_name='experience_years')
    op.drop_column('users', 'photo_url')
