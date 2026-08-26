from pydantic import BaseModel
from typing import Optional


class ExecutionResult(BaseModel):
    success: bool
    exit_code: int
    stdout: Optional[str] = None
    stderr: Optional[str] = None
    duration_seconds: Optional[float] = None
    transport: Optional[str] = None