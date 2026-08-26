"""add FAILED_FINAL status

Revision ID: 8b43761452f3
Revises: 004_add_workflow_ready_fields
Create Date: 2026-06-23 18:44:22.354417

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '8b43761452f3' #005_add_final_failed_final_status
down_revision: Union[str, None] = '004_add_workflow_ready_fields'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None



def upgrade():
    op.execute("ALTER TYPE job_status ADD VALUE IF NOT EXISTS 'FAILED_FINAL'")

def downgrade() -> None:
    op.execute("ALTER TYPE job_status DROP VALUE IF EXISTS 'FAILED_FINAL'")
