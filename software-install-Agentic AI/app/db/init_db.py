from sqlalchemy.orm import Session

from app.db.session import SessionLocal
from app.models.security import AppRole


def seed_roles(db: Session) -> None:

    roles = [
        {
            "role_name": "Admin",
            "description": "Full administrative access",
        },
        {
            "role_name": "Operator",
            "description": "Can execute approved operations",
        },
        {
            "role_name": "Viewer",
            "description": "Read-only access",
        },
    ]

    for role in roles:

        existing = (
            db.query(AppRole)
            .filter(
                AppRole.role_name == role["role_name"]
            )
            .first()
        )

        if not existing:
            db.add(
                AppRole(
                    role_name=role["role_name"],
                    description=role["description"],
                )
            )

    db.commit()

    print("Roles seeded successfully")


def main():

    db = SessionLocal()

    try:
        seed_roles(db)

    finally:
        db.close()


if __name__ == "__main__":
    main()