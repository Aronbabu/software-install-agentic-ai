"""add_target_port

Revision ID: b578ded92e66
Revises: 8b43761452f3
Create Date: 2026-08-17
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

revision = "b578ded92e66"
down_revision = "8b43761452f3"
branch_labels = None
depends_on = None


def upgrade() -> None:

    op.add_column(
        "jobs",
        sa.Column(
            "target_port",
            sa.Integer(),
            nullable=False,
            server_default="22"
        )
    )

    op.add_column(
        "jobs",
        sa.Column(
            "connection_method",
            sa.String(length=20),
            nullable=False,
            server_default="openssh"
        )
    )


def downgrade() -> None:

    op.drop_column("jobs", "connection_method")
    op.drop_column("jobs", "target_port")