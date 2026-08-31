from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db import get_db
from app.services.ledger_service import LedgerService
from app.models.audit import AuditEvent

router = APIRouter(prefix="/api/v1", tags=["ledger"])


@router.get("/jobs/{job_id}/ledger")
def get_job_ledger(job_id: str, db: Session = Depends(get_db)):
    try:
        ledger = LedgerService.get_by_job_id(db=db, job_id=job_id)
        return {
            "id": str(ledger.id),
            "job_id": ledger.job_id,
            "request_source": ledger.request_source,
            "request_reference": ledger.request_reference,
            "requested_by": ledger.requested_by,
            "software_name": ledger.software_name,
            "target_host": ledger.target_host,
            "connection_method": ledger.connection_method,
            "authorization_result": ledger.authorization_result,
            "authorization_reason": ledger.authorization_reason,
            "execution_path": ledger.execution_path,
            "execution_result": ledger.execution_result,
            "execution_details": ledger.execution_details,
            "verification_result": ledger.verification_result,
            "verification_details": ledger.verification_details,
            "final_outcome": ledger.final_outcome,
            "created_at": ledger.created_at,
            "updated_at": ledger.updated_at,
        }
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.get("/jobs/{job_id}/ledger/summary")
def get_ledger_summary(job_id: str, db: Session = Depends(get_db)):
    """Get concise ledger summary for quick audit checks"""
    try:
        ledger = LedgerService.get_by_job_id(db=db, job_id=job_id)
        return {
            "job_id": ledger.job_id,
            "request_source": ledger.request_source,
            "request_reference": ledger.request_reference,
            "software_name": ledger.software_name,
            "authorization_decision": ledger.authorization_result,
            "execution_result": ledger.execution_result,
            "verification_result": ledger.verification_result,
            "final_outcome": ledger.final_outcome,
            "completed_at": ledger.updated_at,
        }
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.get("/jobs/{job_id}/audit-trail")
def get_audit_trail(job_id: str, db: Session = Depends(get_db)):
    """Get complete audit trail (ledger + all audit events)"""
    try:
        ledger = LedgerService.get_by_job_id(db=db, job_id=job_id)
        audit_events = (
            db.query(AuditEvent)
            .filter(AuditEvent.job_id == job_id)
            .order_by(AuditEvent.created_at.asc())
            .all()
        )

        return {
            "job_id": job_id,
            "ledger": ledger,
            "events": [
                {
                    "timestamp": event.created_at,
                    "event_type": event.event_type,
                    "result": event.result,
                    "message": event.message,
                    "actor_id": event.actor_id,
                }
                for event in audit_events
            ],
        }
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))