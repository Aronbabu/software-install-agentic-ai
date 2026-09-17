from __future__ import annotations

from typing import Any

from app.schemas.ai_plan import (
    ExecutionPlanPayload,
    PlanningResult,
    PlanReference,
    PlanSource,
    ReviewAdvisoryPayload,
)


def _ensure_list(value: Any, field_name: str) -> list:
    if value is None:
        return []
    if not isinstance(value, list):
        raise ValueError(f"{field_name} must be a list")
    return value


def _ensure_plan_references(value: Any) -> list[PlanReference]:
    refs = _ensure_list(value, "references")
    return [PlanReference.model_validate(item) for item in refs]


def validate_execution_plan_payload(payload: Any) -> ExecutionPlanPayload:
    if isinstance(payload, ExecutionPlanPayload):
        plan = payload
    else:
        if not isinstance(payload, dict):
            raise ValueError("Execution plan payload must be a dict")
        payload = dict(payload)

        payload["prechecks"] = _ensure_list(payload.get("prechecks"), "prechecks")
        payload["install_steps"] = _ensure_list(payload.get("install_steps"), "install_steps")
        payload["verify_steps"] = _ensure_list(payload.get("verify_steps"), "verify_steps")
        payload["rollback_steps"] = _ensure_list(payload.get("rollback_steps"), "rollback_steps")
        payload["risks"] = _ensure_list(payload.get("risks"), "risks")
        payload["approved_parameters"] = _ensure_list(payload.get("approved_parameters"), "approved_parameters")
        payload["warnings"] = _ensure_list(payload.get("warnings"), "warnings")
        payload["assumptions"] = _ensure_list(payload.get("assumptions"), "assumptions")
        payload["references"] = _ensure_plan_references(payload.get("references"))

        plan = ExecutionPlanPayload.model_validate(payload)

    if not plan.summary.strip():
        raise ValueError("Execution plan summary cannot be empty")
    if not plan.software_name.strip():
        raise ValueError("software_name is required")
    if not plan.platform.strip():
        raise ValueError("platform is required")
    if not plan.install_steps:
        raise ValueError("install_steps cannot be empty")
    if not plan.verify_steps:
        raise ValueError("verify_steps cannot be empty")
    if plan.review_required:
        raise ValueError("Approved execution plan cannot be review_required")
    if plan.plan_source not in {PlanSource.AI, PlanSource.SOP_DIRECT, PlanSource.REUSED}:
        raise ValueError("Invalid plan_source for execution plan")
    if not plan.references:
        raise ValueError("Execution plan must include at least one reference")

    return plan


def validate_review_advisory_payload(payload: Any) -> ReviewAdvisoryPayload:
    if isinstance(payload, ReviewAdvisoryPayload):
        review = payload
    else:
        if not isinstance(payload, dict):
            raise ValueError("Review advisory payload must be a dict")
        payload = dict(payload)
        payload["references"] = _ensure_plan_references(payload.get("references"))
        payload["advisory_recommendations"] = _ensure_list(
            payload.get("advisory_recommendations"),
            "advisory_recommendations",
        )

        review = ReviewAdvisoryPayload.model_validate(payload)

    if not review.failure_reason.strip():
        raise ValueError("failure_reason cannot be empty")
    if not review.review_required:
        raise ValueError("Review advisory payload must set review_required=True")
    if not review.advisory_recommendations:
        raise ValueError("Review advisory payload must include recommendations")

    return review


def validate_planning_result(payload: Any) -> PlanningResult:
    if isinstance(payload, PlanningResult):
        result = payload
    else:
        if not isinstance(payload, dict):
            raise ValueError("Planning result must be a dict")

        outcome = payload.get("outcome")
        plan_data = payload.get("plan")
        review_data = payload.get("review")

        plan = validate_execution_plan_payload(plan_data) if plan_data else None
        review = validate_review_advisory_payload(review_data) if review_data else None

        result = PlanningResult(
            outcome=PlanSource(outcome),
            plan=plan,
            review=review,
            ai_request_id=payload.get("ai_request_id"),
            ai_response_id=payload.get("ai_response_id"),
            execution_plan_id=payload.get("execution_plan_id"),
        )

    if result.outcome in {PlanSource.AI, PlanSource.SOP_DIRECT, PlanSource.REUSED}:
        if result.plan is None:
            raise ValueError("Approved planning outcome requires a plan")
        if result.review is not None:
            raise ValueError("Approved planning outcome cannot include review payload")

    if result.outcome == PlanSource.REVIEW_REQUIRED:
        if result.review is None:
            raise ValueError("Review-required outcome requires a review payload")
        if result.plan is not None:
            raise ValueError("Review-required outcome cannot include an approved plan")

    return result