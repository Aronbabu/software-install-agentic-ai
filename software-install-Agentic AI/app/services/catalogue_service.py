from sqlalchemy.orm import Session
from app.models.catalogue import SoftwareCatalogue


class CatalogueService:
    @staticmethod
    def list_items(
        db: Session,
        request_source: str | None = None,
        os_type: str | None = None,
        status: str = "ACTIVE",
    ):
        query = db.query(SoftwareCatalogue)

        if request_source:
            query = query.filter(SoftwareCatalogue.request_source == request_source)

        if os_type:
            query = query.filter(SoftwareCatalogue.os_type == os_type)

        if status:
            query = query.filter(SoftwareCatalogue.status == status)

        return query.order_by(SoftwareCatalogue.name.asc()).all()

    @staticmethod
    def get_item(db: Session, catalogue_id: str):
        return (
            db.query(SoftwareCatalogue)
            .filter(SoftwareCatalogue.id == catalogue_id)
            .first()
        )