from sqlalchemy.orm import Session
from app.models.therapist import TherapistProfile
from app.schemas.therapist import TherapistProfileCreate, TherapistProfileUpdate


def get_profile_by_user(db: Session, user_id):
    return db.query(TherapistProfile).filter(TherapistProfile.user_id == user_id).first()


def create_profile(db: Session, user_id, data: TherapistProfileCreate):
    profile = TherapistProfile(user_id=user_id, **data.model_dump())
    db.add(profile)
    db.commit()
    db.refresh(profile)
    return profile


def update_profile(db: Session, user_id, data: TherapistProfileUpdate):
    profile = get_profile_by_user(db, user_id)
    if not profile:
        return None
    for field, value in data.model_dump(exclude_unset=True).items():
        setattr(profile, field, value)
    db.commit()
    db.refresh(profile)
    return profile
