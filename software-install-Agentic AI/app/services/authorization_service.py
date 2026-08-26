from sqlalchemy.orm import Session

from app.models.security import (
    AppUser,
    AppRole,
    AppUserRole,
    AuthorizationDecision,
)


class AuthorizationService:

    @staticmethod
    def get_user_roles(
        db: Session,
        user_id
    ):
        roles = (
            db.query(AppRole)
            .join(
                AppUserRole,
                AppRole.id == AppUserRole.role_id
            )
            .filter(
                AppUserRole.user_id == user_id
            )
            .all()
        )

        return [
            role.role_name
            for role in roles
        ]


    @staticmethod
    def check_permission(
        roles,
        action
    ):

        if "Admin" in roles:
            return True

        if (
            "Operator" in roles
            and action == "EXECUTE"
        ):
            return True

        return False
    @staticmethod
    def record_decision(
        db: Session,
        *,
        user_id,
        job_id,
        request_source,
        request_reference,
        action,
        target_host,
        connection_method,
        decision,
        reason,
    ):

        record = AuthorizationDecision(
            user_id=user_id,
            job_id=job_id,

            request_source=request_source,
            request_reference=request_reference,

            action=action,

            target_host=target_host,
            connection_method=connection_method,

            decision=decision,
            reason=reason,
        )

        db.add(record)
        db.commit()

        return record

