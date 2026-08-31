from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.models.catalogue import SoftwareCatalogue
from app.models.job import Job
from app.services.catalogue_rules import is_source_allowed


def create_job_from_catalogue(db: Session, payload):
    catalogue_item = (
        db.query(SoftwareCatalogue)
        .filter(SoftwareCatalogue.id == payload.catalogue_id)
        .first()
    )

    if not catalogue_item:
        raise HTTPException(status_code=404, detail="Catalogue item not found")

    if catalogue_item.status != "ACTIVE":
        raise HTTPException(status_code=400, detail="Catalogue item is inactive")

    if not is_source_allowed(catalogue_item.request_source, payload.request_source):
        raise HTTPException(
            status_code=400,
            detail="Request source is not allowed for this catalogue item",
        )

    job = Job(
        software_name=catalogue_item.name,
        software_version=catalogue_item.version,
        os_type=catalogue_item.os_type,
        target_port=catalogue_item.target_port,
        connection_method=catalogue_item.connection_method,
        requested_by=payload.requested_by,
        request_source=payload.request_source,
        request_reference=payload.request_reference,
        notes=payload.notes,
        status="REQUESTED",
        target_host=payload.target_host,
    )

    db.add(job)
    db.commit()
    db.refresh(job)

    return job