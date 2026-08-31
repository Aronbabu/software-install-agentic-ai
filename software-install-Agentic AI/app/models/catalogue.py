import uuid
from sqlalchemy import Column, String, DateTime, Text, func
from app.db.base import Base


class SoftwareCatalogue(Base):
    __tablename__ = "software_catalogue"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String(255), nullable=False, index=True)
    version = Column(String(100), nullable=False, default="latest")
    os_type = Column(String(50), nullable=False, index=True)  # linux, windows
    request_source = Column(String(50), nullable=False, index=True)  # ADMIN_PORTAL, SERVICENOW, BOTH
    execution_mode = Column(String(50), nullable=False, default="immediate")  # immediate, scheduled
    target_port = Column(String(20), nullable=True)
    connection_method = Column(String(50), nullable=True)  # openssh, winrm, etc.
    status = Column(String(50), nullable=False, default="ACTIVE", index=True)  # ACTIVE, INACTIVE
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)