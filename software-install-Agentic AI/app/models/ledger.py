import uuid
from datetime import datetime

import sqlalchemy as sa

from sqlalchemy import (
    Column,
    DateTime,
    ForeignKey,
    String,
    Text,
)

from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.db.base import Base


class DecisionLedger(Base):
    __tablename__ = "decision_ledger"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        server_default=sa.text("gen_random_uuid()"),
    )

    job_id = Column(
        String(36),
        ForeignKey("jobs.id", ondelete="CASCADE"),
        nullable=False,
        unique=True,
        index=True,
    )

    request_source = Column(
        String(50),
        nullable=False,
        index=True,
    )

    request_reference = Column(
        String(255),
        nullable=True,
        index=True,
    )

    requested_by = Column(
        String(100),
        nullable=True,
    )

    software_name = Column(
        String(255),
        nullable=True,
    )

    target_host = Column(
        String(255),
        nullable=True,
    )

    connection_method = Column(
        String(50),
        nullable=True,
    )

    authorization_result = Column(
        String(20),
        nullable=True,
    )

    authorization_reason = Column(
        Text,
        nullable=True,
    )

    execution_path = Column(
        String(100),
        nullable=True,
    )

    execution_result = Column(
        String(50),
        nullable=True,
    )

    execution_details = Column(
        Text,
        nullable=True,
    )

    verification_result = Column(
        String(50),
        nullable=True,
    )

    verification_details = Column(
        Text,
        nullable=True,
    )

    final_outcome = Column(
        String(50),
        nullable=True,
        index=True,
    )

    created_at = Column(
        DateTime,
        nullable=False,
        default=datetime.utcnow,
        server_default=sa.text("CURRENT_TIMESTAMP"),
    )

    updated_at = Column(
        DateTime,
        nullable=False,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
        server_default=sa.text("CURRENT_TIMESTAMP"),
    )

    job = relationship(
        "Job",
        lazy="joined",
    )