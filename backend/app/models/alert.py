import uuid
import enum
from datetime import datetime
from sqlalchemy import Column, String, Text, DateTime, ForeignKey, Enum, Boolean
from sqlalchemy.orm import relationship
from app.core.database import Base


class AlertType(str, enum.Enum):
    SESSION_REMINDER = "session_reminder"
    FEEDBACK_DUE = "feedback_due"
    PROGRESS_UPDATE = "progress_update"
    SYSTEM = "system"


class Alert(Base):
    __tablename__ = "alerts"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    alert_type = Column(Enum(AlertType), nullable=False)
    title = Column(String(255), nullable=False)
    message = Column(Text, nullable=True)
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", foreign_keys=[user_id])
