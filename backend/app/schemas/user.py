from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime


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
    id: str
    is_verified: bool
    created_at: Optional[datetime] = None

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
