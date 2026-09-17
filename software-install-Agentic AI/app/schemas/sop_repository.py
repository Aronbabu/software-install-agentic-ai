from __future__ import annotations

from datetime import datetime
from typing import Optional, List

from pydantic import BaseModel, Field


class SOPRepositorySummaryResponse(BaseModel):
    id: str
    name: str
    software_name: str
    software_version: Optional[str] = None
    platform: str
    document_type: str
    source_path: Optional[str] = None
    owner: Optional[str] = None
    status: str
    version: Optional[str] = None
    last_updated_at: Optional[datetime] = None
    created_at: datetime

    model_config = {"from_attributes": True}


class SOPRepositoryListResponse(BaseModel):
    items: List[SOPRepositorySummaryResponse] = Field(default_factory=list)
    total: int