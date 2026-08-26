"""extend job status lifecycle values

Revision ID: 0002_extend_job_status_lifecycle
Revises: 0001_create_jobs_and_job_steps
Create Date: 2026-05-31
"""

from alembic import op
import sqlalchemy as sa

revision = "0002_extend_job_status_lifecycle"
down_revision = "0001_create_jobs_and_job_steps"
branch_labels = None
depends_on = None

old_job_status = sa.Enum("PENDING", "RUNNING", "SUCCESS", "FAILED", name="job_status")
new_job_status = sa.Enum("PENDING", "VALIDATING", "RUNNING", "VERIFYING", "SUCCESS", "FAILED", name="job_status")


def upgrade():
    bind = op.get_bind()

    # PostgreSQL enum extension
    op.execute("ALTER TYPE job_status ADD VALUE IF NOT EXISTS 'VALIDATING'")
    op.execute("ALTER TYPE job_status ADD VALUE IF NOT EXISTS 'VERIFYING'")


def downgrade():
    # Enum value removal is not trivial in PostgreSQL.
    # Safe downgrade typically requires creating a new enum type and casting data.
    # For MVP/local environment, leave as no-op or handle manually if needed.
    pass
