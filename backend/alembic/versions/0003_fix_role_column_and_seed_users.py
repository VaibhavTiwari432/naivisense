"""Fix role column type and seed default users

Revision ID: 0003
Revises: 0002
Create Date: 2026-04-25
"""
from alembic import op
import sqlalchemy as sa
from datetime import datetime

revision = '0003'
down_revision = '0002'
branch_labels = None
depends_on = None

_NOW = datetime(2026, 4, 25, 12, 0, 0)

_SEED_USERS = [
    {
        'id': '9371fdef-0d7a-4752-9f2c-265695d41c77',
        'phone': '0000000001',
        'name': 'Admin User',
        'role': 'admin',
        'password_hash': '$2b$12$j5CuvbM8aj5MN/h6gGi3leqrbJiuv1fchXzQPqEf.PTRLYrSGzjh2',
        'email': None,
        'is_verified': True,
        'created_at': _NOW,
        'updated_at': _NOW,
    },
    {
        'id': '38785b60-a04d-4b58-8708-72668b030079',
        'phone': '1111111111',
        'name': 'Demo Therapist',
        'role': 'therapist',
        'password_hash': '$2b$12$mzRPMR5nji9v77ipV5LNP.nueEe7n3AkzT.0TGgS6LbnLaAJI9y6O',
        'email': None,
        'is_verified': True,
        'created_at': _NOW,
        'updated_at': _NOW,
    },
    {
        'id': '69ebd4c0-2b97-4ed2-81e2-13fbb343886a',
        'phone': '2222222222',
        'name': 'Demo Parent',
        'role': 'parent',
        'password_hash': '$2b$12$Ccc8AjcvZ6m4ODfElwka3eTAML72Xi1LU4G8/ZIkGHezYKyyCRZre',
        'email': None,
        'is_verified': True,
        'created_at': _NOW,
        'updated_at': _NOW,
    },
]


def upgrade() -> None:
    users = sa.table(
        'users',
        sa.column('id', sa.String),
        sa.column('phone', sa.String),
        sa.column('name', sa.String),
        sa.column('role', sa.String),
        sa.column('password_hash', sa.String),
        sa.column('email', sa.String),
        sa.column('is_verified', sa.Boolean),
        sa.column('created_at', sa.DateTime),
        sa.column('updated_at', sa.DateTime),
    )
    op.bulk_insert(users, _SEED_USERS)


def downgrade() -> None:
    op.execute(
        "DELETE FROM users WHERE phone IN ('0000000001','1111111111','2222222222')"
    )
