from sqlalchemy.orm import Session
from app.models.user import User
from app.schemas.user import UserCreate, UserUpdate
from app.core.security import get_password_hash


def get_user_by_phone(db: Session, phone: str):
    return db.query(User).filter(User.phone == phone).first()


def get_user_by_id(db: Session, user_id):
    return db.query(User).filter(User.id == user_id).first()


def create_user(db: Session, user: UserCreate):
    db_user = User(
        phone=user.phone,
        email=user.email,
        name=user.name,
        role=user.role,
        password_hash=get_password_hash(user.password),
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


def update_user(db: Session, user_id, data: UserUpdate):
    db_user = get_user_by_id(db, user_id)
    if not db_user:
        return None
    for field, value in data.model_dump(exclude_unset=True).items():
        setattr(db_user, field, value)
    db.commit()
    db.refresh(db_user)
    return db_user
