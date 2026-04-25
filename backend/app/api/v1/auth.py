from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.security import verify_password, create_access_token
from app.crud import user as crud_user
from app.schemas.user import UserCreate, UserLogin, Token, UserResponse
from app.api.deps import get_current_user

router = APIRouter()


@router.post("/register", response_model=Token)
async def register(user: UserCreate, db: Session = Depends(get_db)):
    if crud_user.get_user_by_phone(db, user.phone):
        raise HTTPException(status_code=400, detail="Phone number already registered")
    db_user = crud_user.create_user(db, user)
    access_token = create_access_token(data={"sub": str(db_user.id), "role": db_user.role})
    return {"access_token": access_token, "token_type": "bearer", "user": db_user}


@router.post("/login", response_model=Token)
async def login(credentials: UserLogin, db: Session = Depends(get_db)):
    user = crud_user.get_user_by_phone(db, credentials.phone)
    if not user or not verify_password(credentials.password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Incorrect phone or password")
    access_token = create_access_token(data={"sub": str(user.id), "role": user.role})
    return {"access_token": access_token, "token_type": "bearer", "user": user}


@router.get("/me", response_model=UserResponse)
async def get_me(current_user=Depends(get_current_user)):
    return current_user
