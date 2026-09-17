from __future__ import annotations

PLANNING_PROMPT_VERSION = "slice3_v1"


def build_grounded_planning_prompt(
    *,
    software_name: str,
    platform: str,
    version: str | None,
    request_type: str | None,
    retrieved_context: str,
) -> str:
    return f"""
You are a strict software installation planning assistant.

You must generate a grounded execution plan only from the approved context provided below.

RULES:
- Do not invent steps not supported by context.
- Do not claim execution approval.
- Do not include unsafe or autonomous actions.
- If grounding is weak, output a review-required advisory instead of a plan.
- Return valid JSON only.
- Include references used from the provided context.
- Keep the plan structured and concise.

REQUEST CONTEXT:
- software_name: {software_name}
- platform: {platform}
- version: {version or ""}
- request_type: {request_type or ""}

APPROVED CONTEXT:
{retrieved_context}

RESPONSE FORMAT:
Return JSON with these top-level keys:
- outcome
- plan
- review

If a valid plan can be produced:
- outcome must be "AI", "SOP_DIRECT", or "REUSED"
- plan must contain the execution plan object
- review must be null

If grounding is insufficient:
- outcome must be "REVIEW_REQUIRED"
- plan must be null
- review must contain advisory guidance and failure reason
""".strip()


def build_review_advisory_prompt(
    *,
    software_name: str | None,
    platform: str | None,
    version: str | None,
    request_type: str | None,
    failure_reason: str,
    retrieved_context: str,
) -> str:
    return f"""
You are a strict software installation review advisor.

The request cannot be turned into an approved execution plan safely.

Your task:
- explain why review is required
- give operator-facing recommendations
- mention any grounded context that may help
- do not invent unsupported steps
- do not claim execution approval
- return valid JSON only

REQUEST CONTEXT:
- software_name: {software_name or ""}
- platform: {platform or ""}
- version: {version or ""}
- request_type: {request_type or ""}

FAILURE REASON:
{failure_reason}

APPROVED CONTEXT:
{retrieved_context}

RESPONSE FORMAT:
Return JSON with these top-level keys:
- outcome = "REVIEW_REQUIRED"
- plan = null
- review = review advisory object
""".strip()