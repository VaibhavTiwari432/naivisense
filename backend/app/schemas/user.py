from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime
from uuid import UUID


class UserBase(BaseModel):
    phone: str
    email: Optional[EmailStr] = None
    name: str
    role: str


class UserCreate(UserBase):
    password: str


class UserLogin(BaseModel):
    phone: str
    password: str


class UserResponse(UserBase):
    id: UUID
    is_verified: bool
    created_at: datetime

    class Config:
        from_attributes = True


class Token(BaseModel):
    access_token: str
    token_type: str
    user: UserResponse


class UserUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[EmailStr] = None
    photo_url: Optional[str] = None
