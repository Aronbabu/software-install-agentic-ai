from typing import Optional
from uuid import UUID

from sqlalchemy.orm import Session

from app.models.audit import AuditEvent


class AuditService:

    @staticmethod
    def record_event(
        db: Session,
        *,
        event_type: str,
        request_source: Optional[str] = None,
        request_reference: Optional[str] = None,
        job_id: Optional[UUID] = None,
        actor_id: Optional[UUID] = None,
        target_host: Optional[str] = None,
        connection_method: Optional[str] = None,
        result: Optional[str] = None,
        message: Optional[str] = None,
    ) -> AuditEvent:

        event = AuditEvent(
            event_type=event_type,
            request_source=request_source,
            request_reference=request_reference,
            job_id=job_id,
            actor_id=actor_id,
            target_host=target_host,
            connection_method=connection_method,
            result=result,
            message=message,
        )

        db.add(event)
        db.flush()

        return event