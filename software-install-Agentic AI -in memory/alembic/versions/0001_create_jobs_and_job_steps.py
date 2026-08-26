"""create jobs and job_steps tables

Revision ID: 0001_create_jobs_and_job_steps
Revises:
Create Date: 2026-05-31
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "0001_create_jobs_and_job_steps"
down_revision = None
branch_labels = None
depends_on = None

#job_status = sa.Enum("PENDING", "RUNNING", "SUCCESS", "FAILED", name="job_status")

job_status = postgresql.ENUM(
    "PENDING",
    "RUNNING",
    "SUCCESS",
    "FAILED",
    name="job_status",
    create_type=False
)


def upgrade():
    job_status.create(op.get_bind(), checkfirst=True)

    op.create_table(
        "jobs",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("ticket_id", sa.String(), nullable=False),
        sa.Column("module", sa.String(), nullable=False),
        sa.Column("status", job_status, nullable=False),
        sa.Column("target_host", sa.String(), nullable=False),
        sa.Column("os_type", sa.String(), nullable=False),
        sa.Column("software_name", sa.String(), nullable=False),
        sa.Column("software_version", sa.String(), nullable=True),
        sa.Column("requested_by", sa.String(), nullable=True),
        sa.Column("justification", sa.Text(), nullable=True),
        sa.Column("trace_id", sa.String(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("updated_at", sa.DateTime(), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_jobs_ticket_id"), "jobs", ["ticket_id"], unique=False)

    op.create_table(
        "job_steps",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("job_id", sa.String(), nullable=False),
        sa.Column("step_name", sa.String(), nullable=False),
        sa.Column("status", sa.String(), nullable=False),
        sa.Column("message", sa.Text(), nullable=True),
        sa.Column("exit_code", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(["job_id"], ["jobs.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_job_steps_job_id"), "job_steps", ["job_id"], unique=False)


def downgrade():
    op.drop_index(op.f("ix_job_steps_job_id"), table_name="job_steps")
    op.drop_table("job_steps")
    op.drop_index(op.f("ix_jobs_ticket_id"), table_name="jobs")
    op.drop_table("jobs")
    job_status.drop(op.get_bind(), checkfirst=True)
