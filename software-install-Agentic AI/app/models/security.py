from datetime import datetime
import uuid
import sqlalchemy as sa

from sqlalchemy import (
    Column,
    String,
    Boolean,
    DateTime,
    ForeignKey,
    Text,
)

from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.db.base import Base


# =====================================================
# USERS
# =====================================================

class AppUser(Base):
    __tablename__ = "app_users"

    id = Column(
    UUID(as_uuid=True),
    primary_key=True,
    default=uuid.uuid4,
    server_default=sa.text("gen_random_uuid()")
    )

    username = Column(
        String(100),
        nullable=False,
        unique=True,
    )

    email = Column(
        String(255),
        nullable=False,
        unique=True,
    )

    auth_type = Column(
        String(50),
        nullable=False,
        default="local",
    )

    active = Column(
        Boolean,
        nullable=False,
        default=True,
    )

    created_at = Column(
        DateTime,
        nullable=False,
        default=datetime.utcnow,
        server_default=sa.text("CURRENT_TIMESTAMP")
    )

    updated_at = Column(
        DateTime,
        nullable=False,
        default=datetime.utcnow,
        server_default=sa.text("CURRENT_TIMESTAMP")
    )

    roles = relationship(
        "AppUserRole",
        back_populates="user",
    )


# =====================================================
# ROLES
# =====================================================

class AppRole(Base):
    __tablename__ = "app_roles"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
    )

    role_name = Column(
        String(50),
        nullable=False,
        unique=True,
    )

    description = Column(
        String(255),
        nullable=True,
    )

    created_at = Column(
        DateTime,
        nullable=False,
        default=datetime.utcnow,
        server_default=sa.text("CURRENT_TIMESTAMP")
    )

    user_roles = relationship(
        "AppUserRole",
        back_populates="role",
    )


# =====================================================
# USER ROLE MAPPING
# =====================================================

class AppUserRole(Base):
    __tablename__ = "app_user_roles"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
    )

    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("app_users.id"),
        nullable=False,
    )

    role_id = Column(
        UUID(as_uuid=True),
        ForeignKey("app_roles.id"),
        nullable=False,
    )

    created_at = Column(
        DateTime,
        nullable=False,
        default=datetime.utcnow,
        server_default=sa.text("CURRENT_TIMESTAMP")
    )

    user = relationship(
        "AppUser",
        back_populates="roles",
    )

    role = relationship(
        "AppRole",
        back_populates="user_roles",
    )


# =====================================================
# AUTHORIZATION DECISIONS
# =====================================================

class AuthorizationDecision(Base):
    __tablename__ = "authorization_decisions"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
    )

    # Job linkage
    job_id = Column(
        UUID(as_uuid=True),
        nullable=True,
    )

    # User linkage
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("app_users.id"),
        nullable=True,
    )

    # ==========================
    # Future-Proof Context
    # ==========================

    request_source = Column(
        String(50),
        nullable=False,
    )

    # Examples:
    # RITM9001234
    # PORTAL-001
    # AI-REQ-001
    request_reference = Column(
        String(255),
        nullable=True,
    )

    # ==========================
    # Authorization Context
    # ==========================

    action = Column(
        String(100),
        nullable=False,
    )

    target_host = Column(
        String(255),
        nullable=True,
    )

    connection_method = Column(
        String(50),
        nullable=True,
    )

    # ==========================
    # Result
    # ==========================

    decision = Column(
        String(20),
        nullable=False,
    )

    # ALLOW / DENY reason
    reason = Column(
        Text,
        nullable=True,
    )

    created_at = Column(
        DateTime,
        nullable=False,
        default=datetime.utcnow,
    )