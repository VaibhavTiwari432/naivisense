import uuid
from datetime import datetime, date
from sqlalchemy import Column, Integer, Text, DateTime, Date, ForeignKey, Boolean, String
from sqlalchemy.orm import relationship
from app.core.database import Base


class DailyFeedback(Base):
    __tablename__ = "daily_feedback"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    child_id = Column(String(36), ForeignKey("children.id"), nullable=False)
    parent_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    feedback_date = Column(Date, default=date.today)
    mood_score = Column(Integer, nullable=True)
    sleep_score = Column(Integer, nullable=True)
    appetite_score = Column(Integer, nullable=True)
    cooperation_score = Column(Integer, nullable=True)
    home_practice_done = Column(Boolean, default=False)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    child = relationship("Child", foreign_keys=[child_id])
    parent = relationship("User", foreign_keys=[parent_id])
