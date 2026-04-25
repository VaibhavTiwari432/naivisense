from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from uuid import UUID


class SessionBase(BaseModel):
    child_id: str
    scheduled_at: datetime
    duration_minutes: Optional[int] = 60
    session_type: Optional[str] = None
    location: Optional[str] = None


class SessionCreate(SessionBase):
    pass


class SessionResponse(SessionBase):
    id: UUID
    therapist_id: UUID
    status: str
    created_at: datetime

    class Config:
        from_attributes = True


class SessionNotesBase(BaseModel):
    attention_score: Optional[int] = None
    participation_score: Optional[int] = None
    mood_score: Optional[int] = None
    progress_score: Optional[int] = None
    behavior_score: Optional[int] = None
    observations: Optional[str] = None
    goals_worked_on: Optional[List[str]] = []
    next_session_plan: Optional[str] = None


class SessionNotesCreate(SessionNotesBase):
    pass


class SessionNotesResponse(SessionNotesBase):
    id: UUID
    session_id: UUID
    therapist_id: UUID
    created_at: datetime

    class Config:
        from_attributes = True
