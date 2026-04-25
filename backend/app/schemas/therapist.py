from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from uuid import UUID


class TherapistProfileBase(BaseModel):
    specialization: Optional[str] = None
    years_of_experience: Optional[int] = 0
    qualification: Optional[str] = None
    clinic_name: Optional[str] = None
    clinic_address: Optional[str] = None
    languages: Optional[List[str]] = []


class TherapistProfileCreate(TherapistProfileBase):
    pass


class TherapistProfileUpdate(TherapistProfileBase):
    pass


class TherapistProfileResponse(TherapistProfileBase):
    id: UUID
    user_id: UUID
    rating: float
    total_sessions: int
    created_at: datetime

    class Config:
        from_attributes = True
