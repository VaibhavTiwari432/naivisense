from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.security import create_access_token
from app.crud import user as crud_user
from app.schemas.user import UserCreate, Token
from app.api.deps import get_current_user

router = APIRouter()


def _require_admin(current_user=Depends(get_current_user)):
    if current_user.role != 'admin':
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN,
                            detail="Admin access required")
    return current_user


@router.post("/create-user", response_model=Token, status_code=201)
async def admin_create_user(
    user: UserCreate,
    db: Session = Depends(get_db),
    _: object = Depends(_require_admin),
):
    if crud_user.get_user_by_phone(db, user.phone):
        raise HTTPException(status_code=400, detail="Phone number already registered")
    db_user = crud_user.create_user(db, user)
    token = create_access_token(data={"sub": str(db_user.id), "role": db_user.role})
    return {"access_token": token, "token_type": "bearer", "user": db_user}
