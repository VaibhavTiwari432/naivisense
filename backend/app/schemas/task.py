from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from uuid import UUID


class TaskBase(BaseModel):
    child_id: str
    title: str
    description: Optional[str] = None
    is_home_task: Optional[bool] = False
    due_date: Optional[datetime] = None


class TaskCreate(TaskBase):
    pass


class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    status: Optional[str] = None
    due_date: Optional[datetime] = None


class TaskResponse(TaskBase):
    id: UUID
    assigned_by: UUID
    status: str
    completed_at: Optional[datetime] = None
    created_at: datetime

    class Config:
        from_attributes = True
