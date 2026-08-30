import uuid
from datetime import datetime

from sqlalchemy import Column, DateTime, String
from sqlalchemy.dialects.postgresql import UUID

from app.db.base import Base



class AuditEvent(Base):
    __tablename__ = "audit_events"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
    )

    event_type = Column(
        String(100),
        nullable=False,
        index=True,
    )

    request_source = Column(
        String(50),
        nullable=True,
        index=True,
    )

    request_reference = Column(
        String(255),
        nullable=True,
        index=True,
    )

    job_id = Column(
        UUID(as_uuid=True),
        nullable=True,
        index=True,
    )

    actor_id = Column(
        UUID(as_uuid=True),
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

    result = Column(
        String(50),
        nullable=True,
    )

    message = Column(
        String(1000),
        nullable=True,
    )

    created_at = Column(
        DateTime,
        nullable=False,
        default=datetime.utcnow,
        index=True,
    )