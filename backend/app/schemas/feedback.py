from pydantic import BaseModel
from typing import Optional
from datetime import datetime, date
from uuid import UUID


class FeedbackBase(BaseModel):
    child_id: str
    feedback_date: Optional[date] = None
    mood_score: Optional[int] = None
    sleep_score: Optional[int] = None
    appetite_score: Optional[int] = None
    cooperation_score: Optional[int] = None
    home_practice_done: Optional[bool] = False
    notes: Optional[str] = None


class FeedbackCreate(FeedbackBase):
    pass


class FeedbackResponse(FeedbackBase):
    id: UUID
    parent_id: UUID
    created_at: datetime

    class Config:
        from_attributes = True
