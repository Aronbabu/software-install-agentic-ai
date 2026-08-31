from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.db import get_db
from app.models.catalogue import SoftwareCatalogue

router = APIRouter(prefix="/api/v1/catalogue", tags=["catalogue"])


@router.get("")
def list_catalogue(
    db: Session = Depends(get_db),
    request_source: str | None = Query(default=None),
    os_type: str | None = Query(default=None),
    status: str | None = Query(default="ACTIVE"),
):
    query = db.query(SoftwareCatalogue)

    if request_source:
        query = query.filter(SoftwareCatalogue.request_source == request_source)

    if os_type:
        query = query.filter(SoftwareCatalogue.os_type == os_type)

    if status:
        query = query.filter(SoftwareCatalogue.status == status)

    items = query.order_by(SoftwareCatalogue.name.asc()).all()

    return {
        "items": [
            {
                "id": item.id,
                "name": item.name,
                "version": item.version,
                "os_type": item.os_type,
                "request_source": item.request_source,
                "execution_mode": item.execution_mode,
                "target_port": item.target_port,
                "connection_method": item.connection_method,
                "status": item.status,
                "notes": item.notes,
                "created_at": item.created_at,
                "updated_at": item.updated_at,
            }
            for item in items
        ],
        "total": len(items),
    }


@router.get("/{catalogue_id}")
def get_catalogue_item(catalogue_id: str, db: Session = Depends(get_db)):
    item = (
        db.query(SoftwareCatalogue)
        .filter(SoftwareCatalogue.id == catalogue_id)
        .first()
    )

    if not item:
        return {"detail": "Catalogue item not found"}

    return {
        "id": item.id,
        "name": item.name,
        "version": item.version,
        "os_type": item.os_type,
        "request_source": item.request_source,
        "execution_mode": item.execution_mode,
        "target_port": item.target_port,
        "connection_method": item.connection_method,
        "status": item.status,
        "notes": item.notes,
        "created_at": item.created_at,
        "updated_at": item.updated_at,
    }