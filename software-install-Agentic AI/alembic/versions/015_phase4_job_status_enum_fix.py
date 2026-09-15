from alembic import op

revision = "phase4_job_status_enum_fix"
down_revision = "phase4_slice1_foundation"  # replace with your actual previous revision
branch_labels = None
depends_on = None


def upgrade():
    op.execute("ALTER TYPE job_status ADD VALUE IF NOT EXISTS 'PLANNING'")
    op.execute("ALTER TYPE job_status ADD VALUE IF NOT EXISTS 'PLAN_READY'")
    op.execute("ALTER TYPE job_status ADD VALUE IF NOT EXISTS 'REVIEW_REQUIRED'")


def downgrade():
    pass