"""Rename hashed_password → password_hash to match ORM model

Revision ID: 0002
Revises: 0001
Create Date: 2026-04-25
"""
from alembic import op

revision = '0002'
down_revision = '0001'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.alter_column('users', 'hashed_password', new_column_name='password_hash')


def downgrade() -> None:
    op.alter_column('users', 'password_hash', new_column_name='hashed_password')
