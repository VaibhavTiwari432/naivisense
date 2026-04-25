import uuid
import enum
from datetime import datetime
from sqlalchemy import Column, String, DateTime, ForeignKey, Enum, Integer
from sqlalchemy.orm import relationship
from app.core.database import Base


class SessionStatus(str, enum.Enum):
    SCHEDULED = "scheduled"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    CANCELLED = "cancelled"


class Session(Base):
    __tablename__ = "sessions"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    child_id = Column(String(36), ForeignKey("children.id"), nullable=False)
    therapist_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    scheduled_at = Column(DateTime, nullable=False)
    duration_minutes = Column(Integer, default=60)
    status = Column(Enum(SessionStatus), default=SessionStatus.SCHEDULED)
    session_type = Column(String(100), nullable=True)
    location = Column(String(255), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    child = relationship("Child", foreign_keys=[child_id])
    therapist = relationship("User", foreign_keys=[therapist_id])
