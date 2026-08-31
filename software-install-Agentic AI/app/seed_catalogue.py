from app.db.session import SessionLocal
from app.models.catalogue import SoftwareCatalogue

SEED_ITEMS = [
    {
        "name": "curl",
        "version": "latest",
        "os_type": "linux",
        "request_source": "BOTH",
        "execution_mode": "immediate",
        "target_port": "2222",
        "connection_method": "openssh",
        "status": "ACTIVE",
        "notes": "Used for Linux install validation/testing.",
    },
    {
        "name": "Git",
        "version": "2.45",
        "os_type": "linux",
        "request_source": "ADMIN_PORTAL",
        "execution_mode": "immediate",
        "target_port": "2221",
        "connection_method": "openssh",
        "status": "ACTIVE",
        "notes": "Portal testing and developer utility.",
    },
    {
        "name": "7-Zip",
        "version": "23.01",
        "os_type": "windows",
        "request_source": "SERVICENOW",
        "execution_mode": "immediate",
        "target_port": "22",
        "connection_method": "openssh",
        "status": "ACTIVE",
        "notes": "Windows package install request item.",
    },
    {
        "name": "Visual Studio Code",
        "version": "1.92",
        "os_type": "windows",
        "request_source": "BOTH",
        "execution_mode": "immediate",
        "target_port": "22",
        "connection_method": "openssh",
        "status": "ACTIVE",
        "notes": "Common editor package for portal and ServiceNow requests.",
    },
    {
        "name": "Notepad++",
        "version": "8.6",
        "os_type": "windows",
        "request_source": "ADMIN_PORTAL",
        "execution_mode": "immediate",
        "target_port": "22",
        "connection_method": "openssh",
        "status": "ACTIVE",
        "notes": "Useful for internal portal-driven testing.",
    },
]


def main():
    db = SessionLocal()
    try:
        existing = {item.name for item in db.query(SoftwareCatalogue.name).all()}

        inserted = 0
        for item in SEED_ITEMS:
            if item["name"] in existing:
                continue

            db.add(SoftwareCatalogue(**item))
            inserted += 1

        db.commit()
        print(f"Seed completed. Inserted {inserted} catalogue item(s).")
    except Exception as exc:
        db.rollback()
        print(f"Seed failed: {exc}")
        raise
    finally:
        db.close()


if __name__ == "__main__":
    main()