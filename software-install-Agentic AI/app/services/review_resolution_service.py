from __future__ import annotations

import json
from typing import Optional

from sqlalchemy.orm import Session

from app.models.execution_plan import ExecutionPlan
from app.models.job import Job, JobStatus
from app.models.sop_repository import SOPRepository
from app.schemas.review_resolution import ReviewResolutionRequest, ReviewResolutionType
from app.services.job_lifecycle import append_job_step, attach_plan_to_job, update_job_status


class ReviewResolutionService:
    def __init__(self, db: Session):
        self.db = db

    def resolve_review(
        self,
        *,
        job_id: str,
        payload: ReviewResolutionRequest,
    ) -> dict:
        job = self.db.query(Job).filter(Job.id == job_id).first()
        if not job:
            raise ValueError("Job not found")

        if job.status != JobStatus.REVIEW_REQUIRED:
            raise ValueError("Job is not in REVIEW_REQUIRED status")

        execution_plan: Optional[ExecutionPlan] = None

        if payload.resolution_type == ReviewResolutionType.REUSE_PLAN:
            if not payload.selected_plan_id:
                raise ValueError("selected_plan_id is required for REUSE_PLAN")

            execution_plan = (
                self.db.query(ExecutionPlan)
                .filter(ExecutionPlan.id == payload.selected_plan_id)
                .first()
            )
            if not execution_plan:
                raise ValueError("Selected execution plan was not found")

            if not execution_plan.approved_for_execution:
                raise ValueError("Selected execution plan is not approved for execution")

            job.current_plan_id = execution_plan.id

            if payload.operator_notes:
                job.notes = (job.notes or "") + f"\n[REVIEW RESOLUTION] {payload.operator_notes}"

            job.operator_review_required = False
            job.review_reason = None
            self.db.add(job)
            self.db.flush()

            update_job_status(
                db=self.db,
                job=job,
                new_status=JobStatus.PLAN_READY,
                message="Manual review resolved and plan is ready for execution.",
            )

            append_job_step(
                db=self.db,
                job_id=job.id,
                step_name="manual_review_resolved",
                status="SUCCESS",
                message=f"Manual review resolved with {payload.resolution_type.value}",
                exit_code=0,
            )
            self.db.commit()
            self.db.refresh(job)

            return {
                "job_id": job.id,
                "status": job.status.value,
                "resolution_type": payload.resolution_type,
                "execution_plan_id": execution_plan.id if execution_plan else None,
                "selected_plan_id": payload.selected_plan_id,
                "selected_sop_id": payload.selected_sop_id,
                "message": "Manual review resolved successfully",
            }

        elif payload.resolution_type == ReviewResolutionType.USE_SOP:
            if not payload.selected_sop_id:
                raise ValueError("selected_sop_id is required for USE_SOP")

            sop = (
                self.db.query(SOPRepository)
                .filter(SOPRepository.id == payload.selected_sop_id)
                .first()
            )
            if not sop:
                raise ValueError("Selected SOP was not found")

            if sop.status != "ACTIVE":
                raise ValueError("Selected SOP is not active")

            execution_plan = ExecutionPlan(
                job_id=job.id,
                summary=f"Manual review approved SOP plan for {job.software_name}",
                target_platform=job.os_type,
                preconditions_json=json.dumps([
                    "Confirm target host is reachable",
                    "Confirm operator-approved SOP is current",
                ]),
                install_steps_json=json.dumps([
                    "Follow the approved SOP steps for the selected document",
                ]),
                verify_steps_json=json.dumps([
                    "Confirm the installation is complete",
                    "Confirm the installed software responds as expected",
                ]),
                rollback_steps_json=json.dumps([
                    "Use the approved SOP rollback/removal steps if required",
                ]),
                risks_json=json.dumps([
                    "Manual review used approved SOP reference",
                ]),
                selected_sop_reference=sop.id,
                retrieved_references_json=json.dumps([
                    {
                        "source_type": "SOP",
                        "reference_id": sop.id,
                        "reference_title": sop.name,
                        "source_path": sop.source_path,
                    }
                ]),
                review_status="APPROVED",
                approved_for_execution=True,
            )
            self.db.add(execution_plan)
            self.db.flush()

            attach_plan_to_job(
                db=self.db,
                job=job,
                execution_plan_id=execution_plan.id,
            )

            if payload.operator_notes:
                job.notes = (job.notes or "") + f"\n[REVIEW RESOLUTION] {payload.operator_notes}"

            job.operator_review_required = False
            job.review_reason = None
            self.db.add(job)
            self.db.flush()

            update_job_status(
                db=self.db,
                job=job,
                new_status=JobStatus.PLAN_READY,
                message="Manual review resolved and plan is ready for execution.",
            )

            append_job_step(
                db=self.db,
                job_id=job.id,
                step_name="manual_review_resolved",
                status="SUCCESS",
                message=f"Manual review resolved with {payload.resolution_type.value}",
                exit_code=0,
            )
            self.db.commit()
            self.db.refresh(job)

            return {
                "job_id": job.id,
                "status": job.status.value,
                "resolution_type": payload.resolution_type,
                "execution_plan_id": execution_plan.id if execution_plan else None,
                "selected_plan_id": payload.selected_plan_id,
                "selected_sop_id": payload.selected_sop_id,
                "message": "Manual review resolved successfully",
            }

        elif payload.resolution_type == ReviewResolutionType.APPROVE_AI_PLAN:
            if not payload.selected_plan_id:
                raise ValueError("selected_plan_id is required for APPROVE_AI_PLAN")

            execution_plan = (
                self.db.query(ExecutionPlan)
                .filter(ExecutionPlan.id == payload.selected_plan_id)
                .first()
            )
            if not execution_plan:
                raise ValueError("Selected execution plan was not found")

            if not execution_plan.approved_for_execution:
                raise ValueError("Selected execution plan is not approved for execution")

            job.current_plan_id = execution_plan.id

            if payload.operator_notes:
                job.notes = (job.notes or "") + f"\n[REVIEW RESOLUTION] {payload.operator_notes}"

            job.operator_review_required = False
            job.review_reason = None
            self.db.add(job)
            self.db.flush()

            update_job_status(
                db=self.db,
                job=job,
                new_status=JobStatus.PLAN_READY,
                message="Manual review resolved and plan is ready for execution.",
            )

            append_job_step(
                db=self.db,
                job_id=job.id,
                step_name="manual_review_resolved",
                status="SUCCESS",
                message=f"Manual review resolved with {payload.resolution_type.value}",
                exit_code=0,
            )
            self.db.commit()
            self.db.refresh(job)

            return {
                "job_id": job.id,
                "status": job.status.value,
                "resolution_type": payload.resolution_type,
                "execution_plan_id": execution_plan.id if execution_plan else None,
                "selected_plan_id": payload.selected_plan_id,
                "selected_sop_id": payload.selected_sop_id,
                "message": "Manual review resolved successfully",
            }

        elif payload.resolution_type == ReviewResolutionType.DEFER_TO_MANUAL:
            if payload.operator_notes:
                job.notes = (job.notes or "") + f"\n[REVIEW DEFERRED] {payload.operator_notes}"

            job.operator_review_required = True
            job.review_reason = job.review_reason or "Deferred by operator for manual handling"
            self.db.add(job)
            self.db.flush()

            append_job_step(
                db=self.db,
                job_id=job.id,
                step_name="manual_review_deferred",
                status="SUCCESS",
                message="Review deferred to manual handling. Execution will not be resumed automatically.",
                exit_code=0,
            )
            self.db.commit()
            self.db.refresh(job)

            return {
                "job_id": job.id,
                "status": job.status.value,
                "resolution_type": payload.resolution_type,
                "execution_plan_id": None,
                "selected_plan_id": None,
                "selected_sop_id": None,
                "message": "Review deferred to manual handling without resuming execution",
            }

        else:
            raise ValueError("Unsupported resolution type")