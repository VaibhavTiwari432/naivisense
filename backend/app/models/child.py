import uuid
from datetime import datetime
from sqlalchemy import Column, String, Integer, Date, DateTime, ForeignKey, JSON, Text
from sqlalchemy.orm import relationship
from app.core.database import Base


class Child(Base):
    __tablename__ = "children"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    parent_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    therapist_id = Column(String(36), ForeignKey("users.id"), nullable=True)
    name = Column(String(255), nullable=False)
    date_of_birth = Column(Date, nullable=True)
    gender = Column(String(10), nullable=True)
    diagnosis = Column(String(255), nullable=True)
    photo_url = Column(String(500), nullable=True)
    therapy_goals = Column(JSON, default=list)
    medical_notes = Column(Text, nullable=True)
    emergency_contact = Column(JSON, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    parent = relationship("User", foreign_keys=[parent_id])
    therapist = relationship("User", foreign_keys=[therapist_id])
