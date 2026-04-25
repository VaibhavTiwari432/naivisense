import uuid
import enum
from datetime import datetime
from sqlalchemy import Column, String, Boolean, DateTime, Enum
from app.core.database import Base


class UserRole(str, enum.Enum):
    THERAPIST = "therapist"
    PARENT = "parent"
    ADMIN = "admin"


class User(Base):
    __tablename__ = "users"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    role = Column(Enum(UserRole), nullable=False)
    phone = Column(String(15), unique=True, nullable=False, index=True)
    email = Column(String(255), unique=True, nullable=True)
    password_hash = Column(String(255), nullable=False)
    name = Column(String(255), nullable=False)
    photo_url = Column(String(500), nullable=True)
    is_verified = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
