from pydantic import BaseModel
from typing import Optional, List, Any
from datetime import datetime, date
from uuid import UUID


class ChildBase(BaseModel):
    name: str
    date_of_birth: Optional[date] = None
    gender: Optional[str] = None
    diagnosis: Optional[str] = None
    photo_url: Optional[str] = None
    therapy_goals: Optional[List[str]] = []
    medical_notes: Optional[str] = None
    emergency_contact: Optional[Any] = None


class ChildCreate(ChildBase):
    pass


class ChildUpdate(BaseModel):
    name: Optional[str] = None
    diagnosis: Optional[str] = None
    therapy_goals: Optional[List[str]] = None
    medical_notes: Optional[str] = None
    therapist_id: Optional[UUID] = None


class ChildResponse(ChildBase):
    id: UUID
    parent_id: UUID
    therapist_id: Optional[UUID] = None
    created_at: datetime

    class Config:
        from_attributes = True
