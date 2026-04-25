import uuid
from datetime import datetime
from sqlalchemy import Column, String, Integer, Float, DateTime, ForeignKey, JSON
from sqlalchemy.orm import relationship
from app.core.database import Base


class TherapistProfile(Base):
    __tablename__ = "therapist_profiles"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id"), unique=True, nullable=False)
    specialization = Column(String(255), nullable=True)
    years_of_experience = Column(Integer, default=0)
    qualification = Column(String(255), nullable=True)
    clinic_name = Column(String(255), nullable=True)
    clinic_address = Column(String(500), nullable=True)
    rating = Column(Float, default=0.0)
    total_sessions = Column(Integer, default=0)
    languages = Column(JSON, default=list)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    user = relationship("User", foreign_keys=[user_id])
