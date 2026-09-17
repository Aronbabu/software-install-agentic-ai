from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from typing import Any, Optional

from sqlalchemy.orm import Session

from app.ai.azure_openai_client import get_azure_openai_client
from app.ai.embeddings_service import embed_text
from app.ai.prompt_templates import (
    PLANNING_PROMPT_VERSION,
    build_grounded_planning_prompt,
    build_review_advisory_prompt,
)
from app.ai.response_validators import validate_planning_result
from app.config import settings
from app.models.ai_request import AIRequest
from app.models.ai_response import AIResponse
from app.models.execution_plan import ExecutionPlan
from app.models.job import Job, JobStatus
from app.models.knowledge_chunk import KnowledgeChunk
from app.models.sop_repository import SOPRepository
from app.schemas.ai_plan import (
    ExecutionPlanPayload,
    PlanReference,
    PlanSource,
    PlanningResult,
    ReviewAdvisoryPayload,
)
from app.services.job_lifecycle import (
    attach_plan_to_job,
    mark_review_required,
    update_job_status,
)
from app.services.execution_policy import APPROVED_PACKAGES
from app.services.execution_policy import is_approved_software

@dataclass
class PlanningContext:
    software_name: str
    platform: str
    version: Optional[str]
    request_type: Optional[str]
    retrieved_context: str
    references: list[PlanReference]
    grounding_status: str


class PlanningService:
    def __init__(self, db: Session):
        self.db = db
    def _is_software_approved_for_platform(self, software_name: str, platform: str) -> bool:
        os_type = (platform or "").strip().lower()
        software = (software_name or "").strip().lower()

        if not os_type or not software:
            return False
        
        try:
            return software in APPROVED_PACKAGES[os_type]
        except KeyError:
            return False
        
    def plan_for_job(self, job: Job) -> PlanningResult:
        job = self._ensure_planning_status(job)
        context = self._build_context(job)

        if not is_approved_software(context.platform, context.software_name):
            return self._create_review_required_result(
                job=job,
                context=context,
                failure_reason=(
                    f"Software '{context.software_name}' is not approved for platform '{context.platform}'."
                ),
                grounding_status="UNSUPPORTED_SOFTWARE",
            )
        
        reusable_plan = self._find_reusable_plan(job)
        if reusable_plan is not None:
            return self._reuse_existing_plan(job, reusable_plan, context)

        deterministic_plan = self._try_deterministic_plan(job, context)
        if deterministic_plan is not None:
            return self._persist_approved_plan(
                job=job,
                plan=deterministic_plan,
                source=PlanSource.SOP_DIRECT,
            )

        if not context.references:
            return self._create_review_required_result(
                job=job,
                context=context,
                failure_reason="No approved grounded context was found for safe planning.",
                grounding_status="INSUFFICIENT",
            )

        ai_result = self._generate_grounded_plan(job, context)
        if ai_result.outcome == PlanSource.REVIEW_REQUIRED or ai_result.plan is None:
            review = ai_result.review
            failure_reason = (
                review.failure_reason
                if review is not None
                else "AI planning failed validation."
            )
            return self._create_review_required_result(
                job=job,
                context=context,
                failure_reason=failure_reason,
                grounding_status="VALIDATION_FAILED",
                advisory=review,
            )

        return self._persist_approved_plan(
            job=job,
            plan=ai_result.plan,
            source=ai_result.outcome,
        )

    def _ensure_planning_status(self, job: Job) -> Job:
        if job.status != JobStatus.PLANNING:
            try:
                job = update_job_status(
                    db=self.db,
                    job=job,
                    new_status=JobStatus.PLANNING,
                    message="Planning started.",
                )
            except ValueError:
                pass
        return job

    def _build_context(self, job: Job) -> PlanningContext:
        retrieved_context, references, grounding_status = self._retrieve_grounding(job)

        return PlanningContext(
            software_name=(job.software_name or "").strip(),
            platform=(job.os_type or "").strip().lower(),
            version=(job.software_version or "").strip() or None,
            request_type=job.request_source,
            retrieved_context=retrieved_context,
            references=references,
            grounding_status=grounding_status,
        )

    def _find_reusable_plan(self, job: Job) -> Optional[ExecutionPlan]:
        return (
            self.db.query(ExecutionPlan)
            .filter(
                ExecutionPlan.target_platform == job.os_type,
                ExecutionPlan.review_status == "APPROVED",
                ExecutionPlan.approved_for_execution.is_(True),
                ExecutionPlan.summary.isnot(None),
            )
            .order_by(ExecutionPlan.created_at.desc())
            .first()
        )

    def _reuse_existing_plan(
        self,
        job: Job,
        reusable_plan: ExecutionPlan,
        context: PlanningContext,
    ) -> PlanningResult:
        payload = ExecutionPlanPayload(
            software_name=job.software_name,
            platform=context.platform,
            version=context.version,
            request_type=context.request_type,
            plan_source=PlanSource.REUSED,
            reusable=True,
            summary=reusable_plan.summary or f"Reused approved plan for {job.software_name}",
            prechecks=self._json_list(reusable_plan.preconditions_json),
            install_steps=self._json_list(reusable_plan.install_steps_json),
            verify_steps=self._json_list(reusable_plan.verify_steps_json),
            rollback_steps=self._json_list(reusable_plan.rollback_steps_json),
            risks=self._json_list(reusable_plan.risks_json),
            approved_parameters=[],
            warnings=[],
            assumptions=[],
            references=self._json_references(reusable_plan.retrieved_references_json),
            timeout_seconds=job.timeout_seconds,
            review_required=False,
            fingerprint=self._fingerprint(
                job.software_name,
                context.platform,
                context.version,
                "REUSED",
                reusable_plan.id,
            ),
        )

        return self._persist_plan_row(
            job=job,
            payload=payload,
            source=PlanSource.REUSED,
            ai_request_id=None,
            ai_response_id=None,
            reused_plan_id=reusable_plan.id,
        )

    def _try_deterministic_plan(
        self,
        job: Job,
        context: PlanningContext,
    ) -> Optional[ExecutionPlanPayload]:
        sop = (
            self.db.query(SOPRepository)
            .filter(
                SOPRepository.software_name == job.software_name,
                SOPRepository.platform == context.platform,
                SOPRepository.status == "ACTIVE",
            )
            .order_by(SOPRepository.created_at.desc())
            .first()
        )

        if sop is None or not sop.content_raw:
            return None

        chunk_rows = (
            self.db.query(KnowledgeChunk)
            .filter(
                KnowledgeChunk.document_kind == "SOP",
                KnowledgeChunk.sop_id == sop.id,
                KnowledgeChunk.status == "ACTIVE",
            )
            .order_by(KnowledgeChunk.chunk_index.asc())
            .all()
        )

        if not chunk_rows:
            return None

        references = [
            PlanReference(
                source_type="SOP",
                reference_id=sop.id,
                reference_title=sop.name,
                source_path=sop.source_path,
                chunk_id=str(chunk.id),
                chunk_index=chunk.chunk_index,
                excerpt=chunk.chunk_text[:400],
            )
            for chunk in chunk_rows[:3]
        ]

        return ExecutionPlanPayload(
            software_name=job.software_name,
            platform=context.platform,
            version=context.version,
            request_type=context.request_type,
            plan_source=PlanSource.SOP_DIRECT,
            reusable=False,
            summary=f"Deterministic SOP-based plan for {job.software_name} on {context.platform}",
            prechecks=[
                "Confirm target host is reachable",
                "Confirm correct account and permissions are available",
                "Confirm package source and prerequisites",
            ],
            install_steps=[
                "Follow the approved SOP steps from the matched repository document",
            ],
            verify_steps=[
                "Confirm the software is installed",
                "Confirm the application responds as expected",
            ],
            rollback_steps=[
                "Refer to the approved SOP rollback or removal steps if required",
            ],
            risks=[
                "SOP must remain approved and applicable to the target platform/version",
            ],
            approved_parameters=[
                f"software_name={job.software_name}",
                f"platform={context.platform}",
            ],
            warnings=[],
            assumptions=["The matched SOP is current and approved"],
            references=references,
            timeout_seconds=job.timeout_seconds,
            review_required=False,
            fingerprint=self._fingerprint(
                job.software_name,
                context.platform,
                context.version,
                "SOP_DIRECT",
                sop.id,
            ),
        )

    def _retrieve_grounding(self, job: Job) -> tuple[str, list[PlanReference], str]:
        query = f"{job.software_name or ''} {job.os_type or ''} {job.software_version or ''}".strip()
        if not query:
            return "", [], "INSUFFICIENT"

        try:
            query_embedding = embed_text(query)
        except Exception:
            return "", [], "INSUFFICIENT"

        rows = (
            self.db.query(KnowledgeChunk)
            .filter(
                KnowledgeChunk.status == "ACTIVE",
                KnowledgeChunk.platform == (job.os_type or "").lower(),
            )
            .order_by(KnowledgeChunk.chunk_index.asc())
            .limit(settings.AI_TOP_K)
            .all()
        )

        references: list[PlanReference] = []
        chunks: list[str] = []

        for row in rows:
            references.append(
                PlanReference(
                    source_type=row.document_kind,
                    reference_id=row.sop_id or row.knowledge_article_id,
                    reference_title=None,
                    source_path=row.source_reference,
                    chunk_id=str(row.id),
                    chunk_index=row.chunk_index,
                    excerpt=row.chunk_text[:500],
                )
            )
            chunks.append(row.chunk_text)

        if not chunks:
            return "", [], "INSUFFICIENT"

        return "\n\n---\n\n".join(chunks), references, "PARTIAL"

    def _generate_grounded_plan(
        self,
        job: Job,
        context: PlanningContext,
    ) -> PlanningResult:
        prompt = build_grounded_planning_prompt(
            software_name=job.software_name,
            platform=context.platform,
            version=context.version,
            request_type=context.request_type,
            retrieved_context=context.retrieved_context,
        )

        ai_request = AIRequest(
            job_id=job.id,
            request_type="PLANNING",
            prompt_version=PLANNING_PROMPT_VERSION,
            model_name=settings.AZURE_OPENAI_GPT_DEPLOYMENT,
            deployment_name=settings.AZURE_OPENAI_GPT_DEPLOYMENT,
            input_context_json=json.dumps(
                {
                    "software_name": job.software_name,
                    "platform": context.platform,
                    "version": context.version,
                    "request_type": context.request_type,
                    "prompt": prompt,
                }
            ),
            retrieved_chunk_ids_json=json.dumps([ref.chunk_id for ref in context.references if ref.chunk_id]),
            trace_id=job.trace_id,
        )
        self.db.add(ai_request)
        self.db.flush()

        client = get_azure_openai_client()

        response = client.chat.completions.create(
            model=settings.AZURE_OPENAI_GPT_DEPLOYMENT,
            messages=[
                {"role": "system", "content": "Return valid JSON only."},
                {"role": "user", "content": prompt},
            ],
            temperature=0.2,
        )

        raw_text = response.choices[0].message.content if response.choices else ""
        parsed = self._parse_json_response(raw_text)
        result = validate_planning_result(parsed)

        ai_response = AIResponse(
            ai_request_id=ai_request.id,
            job_id=job.id,
            response_type="PLANNING_PLAN" if result.outcome != PlanSource.REVIEW_REQUIRED else "PLANNING_REVIEW",
            response_json=json.dumps(parsed),
            review_status="REVIEW_REQUIRED" if result.outcome == PlanSource.REVIEW_REQUIRED else "APPROVED",
            grounded=result.outcome != PlanSource.REVIEW_REQUIRED,
            operator_review_required=result.outcome == PlanSource.REVIEW_REQUIRED,
        )
        self.db.add(ai_response)
        self.db.flush()

        result.ai_request_id = ai_request.id
        result.ai_response_id = ai_response.id
        return result

    def _persist_approved_plan(
        self,
        job: Job,
        plan: ExecutionPlanPayload,
        source: PlanSource,
    ) -> PlanningResult:
        existing_ai_request_id = None
        existing_ai_response_id = None

        plan_row = ExecutionPlan(
            job_id=job.id,
            ai_request_id=existing_ai_request_id,
            ai_response_id=existing_ai_response_id,
            summary=plan.summary,
            target_platform=plan.platform,
            preconditions_json=json.dumps(plan.prechecks),
            install_steps_json=json.dumps(plan.install_steps),
            verify_steps_json=json.dumps(plan.verify_steps),
            rollback_steps_json=json.dumps(plan.rollback_steps),
            risks_json=json.dumps(plan.risks),
            selected_sop_reference=plan.references[0].reference_id if plan.references else None,
            retrieved_references_json=json.dumps([ref.model_dump() for ref in plan.references]),
            review_status="APPROVED",
            approved_for_execution=True,
        )
        self.db.add(plan_row)
        self.db.flush()

        attach_plan_to_job(db=self.db, job=job, execution_plan_id=plan_row.id)

        update_job_status(
            db=self.db,
            job=job,
            new_status=JobStatus.PLAN_READY,
            message="Execution plan ready.",
        )

        return PlanningResult(
            outcome=source,
            plan=plan,
            execution_plan_id=plan_row.id,
        )

    def _persist_plan_row(
        self,
        job: Job,
        payload: ExecutionPlanPayload,
        source: PlanSource,
        ai_request_id: str | None,
        ai_response_id: str | None,
        reused_plan_id: str | None = None,
    ) -> PlanningResult:
        plan_row = ExecutionPlan(
            job_id=job.id,
            ai_request_id=ai_request_id,
            ai_response_id=ai_response_id,
            summary=payload.summary,
            target_platform=payload.platform,
            preconditions_json=json.dumps(payload.prechecks),
            install_steps_json=json.dumps(payload.install_steps),
            verify_steps_json=json.dumps(payload.verify_steps),
            rollback_steps_json=json.dumps(payload.rollback_steps),
            risks_json=json.dumps(payload.risks),
            selected_sop_reference=payload.references[0].reference_id if payload.references else reused_plan_id,
            retrieved_references_json=json.dumps([ref.model_dump() for ref in payload.references]),
            review_status="APPROVED",
            approved_for_execution=True,
        )
        self.db.add(plan_row)
        self.db.flush()

        attach_plan_to_job(db=self.db, job=job, execution_plan_id=plan_row.id)

        update_job_status(
            db=self.db,
            job=job,
            new_status=JobStatus.PLAN_READY,
            message="Execution plan ready.",
        )

        return PlanningResult(
            outcome=source,
            plan=payload,
            execution_plan_id=plan_row.id,
            ai_request_id=ai_request_id,
            ai_response_id=ai_response_id,
        )

    def _create_review_required_result(
        self,
        job: Job,
        context: PlanningContext,
        failure_reason: str,
        grounding_status: str,
        advisory: ReviewAdvisoryPayload | None = None,
    ) -> PlanningResult:
        if advisory is None:
            advisory_prompt = build_review_advisory_prompt(
                software_name=job.software_name,
                platform=context.platform,
                version=context.version,
                request_type=context.request_type,
                failure_reason=failure_reason,
                retrieved_context=context.retrieved_context,
            )

            advisory = ReviewAdvisoryPayload(
                software_name=job.software_name,
                platform=context.platform,
                version=context.version,
                request_type=context.request_type,
                review_required=True,
                failure_reason=failure_reason,
                grounding_status=grounding_status,
                advisory_recommendations=[
                    "Use an approved software name from execution policy.",
                    "Select a matching approved SOP reference if available.",
                    "Confirm the request is supported for the target platform before execution.",
                ],
                suggested_operator_action="Manual review required before execution.",
                confidence_note="Planning rejected the request because the software is not approved for this platform.",
                references=context.references,
                raw_model_output=advisory_prompt,
            )

        mark_review_required(
            db=self.db,
            job=job,
            reason=failure_reason,
        )

        return PlanningResult(
            outcome=PlanSource.REVIEW_REQUIRED,
            review=advisory,
        )

    @staticmethod
    def _parse_json_response(raw_text: str) -> dict[str, Any]:
        if not raw_text:
            raise ValueError("Empty AI response")
        text = raw_text.strip()
        if text.startswith("```"):
            text = text.strip("`")
        return json.loads(text)

    @staticmethod
    def _json_list(raw: str | None) -> list:
        if not raw:
            return []
        try:
            value = json.loads(raw)
            return value if isinstance(value, list) else []
        except Exception:
            return []

    @staticmethod
    def _json_references(raw: str | None) -> list[PlanReference]:
        if not raw:
            return []
        try:
            data = json.loads(raw)
            if not isinstance(data, list):
                return []
            return [PlanReference.model_validate(item) for item in data]
        except Exception:
            return []

    @staticmethod
    def _fingerprint(*parts: Any) -> str:
        joined = "|".join("" if p is None else str(p) for p in parts)
        return hashlib.sha256(joined.encode("utf-8")).hexdigest()


def plan_job(db: Session, job: Job) -> PlanningResult:
    service = PlanningService(db)
    return service.plan_for_job(job)