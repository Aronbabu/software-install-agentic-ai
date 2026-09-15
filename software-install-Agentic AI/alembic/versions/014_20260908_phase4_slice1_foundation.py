"""phase4 slice1 foundation

Revision ID: phase4_slice1_foundation
Revises:
Create Date: 2026-09-08
"""

from alembic import op
import sqlalchemy as sa
from pgvector.sqlalchemy import Vector
from typing import Sequence, Union


# revision identifiers, used by Alembic.
revision = "phase4_slice1_foundation"
down_revision: Union[str, None] = '255cda0c3fd2' # replace with your current latest revision id
branch_labels = None
depends_on = None


def upgrade():
    op.execute("CREATE EXTENSION IF NOT EXISTS vector")

    op.add_column("jobs", sa.Column("current_plan_id", sa.String(), nullable=True))
    op.add_column(
        "jobs",
        sa.Column(
            "operator_review_required",
            sa.Boolean(),
            nullable=False,
            server_default=sa.false(),
        ),
    )
    op.add_column("jobs", sa.Column("review_reason", sa.Text(), nullable=True))

    op.create_table(
        "sop_repository",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("name", sa.String(), nullable=False),
        sa.Column("software_name", sa.String(), nullable=False),
        sa.Column("software_version", sa.String(), nullable=True),
        sa.Column("platform", sa.String(), nullable=False),
        sa.Column("document_type", sa.String(), nullable=False),
        sa.Column("source_path", sa.String(), nullable=True),
        sa.Column("owner", sa.String(), nullable=True),
        sa.Column("status", sa.String(), nullable=False),
        sa.Column("version", sa.String(), nullable=True),
        sa.Column("content_raw", sa.Text(), nullable=True),
        sa.Column("last_updated_at", sa.DateTime(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_sop_repository_platform"), "sop_repository", ["platform"], unique=False)
    op.create_index(op.f("ix_sop_repository_software_name"), "sop_repository", ["software_name"], unique=False)

    op.create_table(
        "knowledge_articles",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("title", sa.String(), nullable=False),
        sa.Column("software_name", sa.String(), nullable=True),
        sa.Column("platform", sa.String(), nullable=True),
        sa.Column("source_path", sa.String(), nullable=True),
        sa.Column("article_type", sa.String(), nullable=False),
        sa.Column("status", sa.String(), nullable=False),
        sa.Column("content_raw", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("updated_at", sa.DateTime(), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_knowledge_articles_platform"), "knowledge_articles", ["platform"], unique=False)
    op.create_index(op.f("ix_knowledge_articles_software_name"), "knowledge_articles", ["software_name"], unique=False)

    op.create_table(
        "knowledge_chunks",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("document_kind", sa.String(), nullable=False),
        sa.Column("sop_id", sa.String(), nullable=True),
        sa.Column("knowledge_article_id", sa.String(), nullable=True),
        sa.Column("chunk_index", sa.Integer(), nullable=False),
        sa.Column("chunk_text", sa.Text(), nullable=False),
        sa.Column("embedding", Vector(dim=1536), nullable=True),
        sa.Column("software_name", sa.String(), nullable=True),
        sa.Column("platform", sa.String(), nullable=True),
        sa.Column("status", sa.String(), nullable=False),
        sa.Column("source_reference", sa.String(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(["knowledge_article_id"], ["knowledge_articles.id"]),
        sa.ForeignKeyConstraint(["sop_id"], ["sop_repository.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_knowledge_chunks_platform"), "knowledge_chunks", ["platform"], unique=False)
    op.create_index(op.f("ix_knowledge_chunks_software_name"), "knowledge_chunks", ["software_name"], unique=False)

    op.create_table(
        "ai_requests",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("job_id", sa.String(), nullable=False),
        sa.Column("request_type", sa.String(), nullable=False),
        sa.Column("prompt_version", sa.String(), nullable=False),
        sa.Column("model_name", sa.String(), nullable=True),
        sa.Column("deployment_name", sa.String(), nullable=True),
        sa.Column("input_context_json", sa.Text(), nullable=True),
        sa.Column("retrieved_chunk_ids_json", sa.Text(), nullable=True),
        sa.Column("trace_id", sa.String(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_ai_requests_job_id"), "ai_requests", ["job_id"], unique=False)

    op.create_table(
        "ai_responses",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("ai_request_id", sa.String(), nullable=False),
        sa.Column("job_id", sa.String(), nullable=False),
        sa.Column("response_type", sa.String(), nullable=False),
        sa.Column("response_json", sa.Text(), nullable=True),
        sa.Column("review_status", sa.String(), nullable=True),
        sa.Column("grounded", sa.Boolean(), nullable=False),
        sa.Column("operator_review_required", sa.Boolean(), nullable=False),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_ai_responses_ai_request_id"), "ai_responses", ["ai_request_id"], unique=False)
    op.create_index(op.f("ix_ai_responses_job_id"), "ai_responses", ["job_id"], unique=False)

    op.create_table(
        "execution_plans",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("job_id", sa.String(), nullable=False),
        sa.Column("ai_request_id", sa.String(), nullable=True),
        sa.Column("ai_response_id", sa.String(), nullable=True),
        sa.Column("summary", sa.Text(), nullable=True),
        sa.Column("target_platform", sa.String(), nullable=True),
        sa.Column("preconditions_json", sa.Text(), nullable=True),
        sa.Column("install_steps_json", sa.Text(), nullable=True),
        sa.Column("verify_steps_json", sa.Text(), nullable=True),
        sa.Column("rollback_steps_json", sa.Text(), nullable=True),
        sa.Column("risks_json", sa.Text(), nullable=True),
        sa.Column("selected_sop_reference", sa.String(), nullable=True),
        sa.Column("retrieved_references_json", sa.Text(), nullable=True),
        sa.Column("review_status", sa.String(), nullable=True),
        sa.Column("approved_for_execution", sa.Boolean(), nullable=False),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("updated_at", sa.DateTime(), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_execution_plans_job_id"), "execution_plans", ["job_id"], unique=False)


def downgrade():
    op.drop_index(op.f("ix_execution_plans_job_id"), table_name="execution_plans")
    op.drop_table("execution_plans")

    op.drop_index(op.f("ix_ai_responses_job_id"), table_name="ai_responses")
    op.drop_index(op.f("ix_ai_responses_ai_request_id"), table_name="ai_responses")
    op.drop_table("ai_responses")

    op.drop_index(op.f("ix_ai_requests_job_id"), table_name="ai_requests")
    op.drop_table("ai_requests")

    op.drop_index(op.f("ix_knowledge_chunks_software_name"), table_name="knowledge_chunks")
    op.drop_index(op.f("ix_knowledge_chunks_platform"), table_name="knowledge_chunks")
    op.drop_table("knowledge_chunks")

    op.drop_index(op.f("ix_knowledge_articles_software_name"), table_name="knowledge_articles")
    op.drop_index(op.f("ix_knowledge_articles_platform"), table_name="knowledge_articles")
    op.drop_table("knowledge_articles")

    op.drop_index(op.f("ix_sop_repository_software_name"), table_name="sop_repository")
    op.drop_index(op.f("ix_sop_repository_platform"), table_name="sop_repository")
    op.drop_table("sop_repository")

    op.drop_column("jobs", "review_reason")
    op.drop_column("jobs", "operator_review_required")
    op.drop_column("jobs", "current_plan_id")