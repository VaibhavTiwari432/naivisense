import uuid
from datetime import datetime
from sqlalchemy import Column, String, Integer, Text, DateTime, ForeignKey, JSON
from sqlalchemy.orm import relationship
from app.core.database import Base


class SessionNotes(Base):
    __tablename__ = "session_notes"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    session_id = Column(String(36), ForeignKey("sessions.id"), unique=True, nullable=False)
    therapist_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    attention_score = Column(Integer, nullable=True)
    participation_score = Column(Integer, nullable=True)
    mood_score = Column(Integer, nullable=True)
    progress_score = Column(Integer, nullable=True)
    behavior_score = Column(Integer, nullable=True)
    observations = Column(Text, nullable=True)
    goals_worked_on = Column(JSON, default=list)
    next_session_plan = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    session = relationship("Session", foreign_keys=[session_id])
    therapist = relationship("User", foreign_keys=[therapist_id])
