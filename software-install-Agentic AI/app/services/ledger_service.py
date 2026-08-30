from typing import Optional

from sqlalchemy.orm import Session

from app.models.ledger import DecisionLedger


class LedgerService:

    @staticmethod
    def create_or_get(
        db: Session,
        *,
        job_id: str,
        request_source: str,
        request_reference: Optional[str],
        requested_by: Optional[str],
        software_name: Optional[str],
        target_host: Optional[str],
        connection_method: Optional[str],
    ) -> DecisionLedger:

        ledger = (
            db.query(DecisionLedger)
            .filter(DecisionLedger.job_id == job_id)
            .first()
        )

        if ledger is not None:
            return ledger

        ledger = DecisionLedger(
            job_id=job_id,
            request_source=request_source,
            request_reference=request_reference,
            requested_by=requested_by,
            software_name=software_name,
            target_host=target_host,
            connection_method=connection_method,
            execution_path=connection_method,
        )

        db.add(ledger)
        db.flush()

        return ledger

    @staticmethod
    def record_authorization(
        db: Session,
        *,
        job_id: str,
        result: str,
        reason: Optional[str] = None,
    ) -> DecisionLedger:

        ledger = LedgerService.get_by_job_id(
            db=db,
            job_id=job_id,
        )

        ledger.authorization_result = result
        ledger.authorization_reason = reason

        if result == "DENY":
            ledger.final_outcome = "DENIED"

        db.flush()
        return ledger

    @staticmethod
    def record_execution(
        db: Session,
        *,
        job_id: str,
        result: str,
        details: Optional[str] = None,
        execution_path: Optional[str] = None,
    ) -> DecisionLedger:

        ledger = LedgerService.get_by_job_id(
            db=db,
            job_id=job_id,
        )

        ledger.execution_result = result
        ledger.execution_details = details

        if execution_path:
            ledger.execution_path = execution_path

        db.flush()
        return ledger

    @staticmethod
    def record_verification(
        db: Session,
        *,
        job_id: str,
        result: str,
        details: Optional[str] = None,
    ) -> DecisionLedger:

        ledger = LedgerService.get_by_job_id(
            db=db,
            job_id=job_id,
        )

        ledger.verification_result = result
        ledger.verification_details = details

        db.flush()
        return ledger

    @staticmethod
    def record_final_outcome(
        db: Session,
        *,
        job_id: str,
        outcome: str,
    ) -> DecisionLedger:

        ledger = LedgerService.get_by_job_id(
            db=db,
            job_id=job_id,
        )

        ledger.final_outcome = outcome

        db.flush()
        return ledger

    @staticmethod
    def get_by_job_id(
        db: Session,
        *,
        job_id: str,
    ) -> DecisionLedger:

        ledger = (
            db.query(DecisionLedger)
            .filter(DecisionLedger.job_id == job_id)
            .first()
        )

        if ledger is None:
            raise ValueError(
                f"Decision ledger not found for job {job_id}"
            )

        return ledger