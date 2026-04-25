from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.crud import therapist as crud_therapist
from app.schemas.therapist import TherapistProfileCreate, TherapistProfileUpdate, TherapistProfileResponse
from app.api.deps import get_current_user

router = APIRouter()


@router.get("/profile", response_model=TherapistProfileResponse)
async def get_profile(current_user=Depends(get_current_user), db: Session = Depends(get_db)):
    profile = crud_therapist.get_profile_by_user(db, current_user.id)
    if not profile:
        raise HTTPException(status_code=404, detail="Therapist profile not found")
    return profile


@router.post("/profile", response_model=TherapistProfileResponse, status_code=201)
async def create_profile(
    data: TherapistProfileCreate,
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db),
):
    existing = crud_therapist.get_profile_by_user(db, current_user.id)
    if existing:
        raise HTTPException(status_code=400, detail="Profile already exists")
    return crud_therapist.create_profile(db, current_user.id, data)


@router.put("/profile", response_model=TherapistProfileResponse)
async def update_profile(
    data: TherapistProfileUpdate,
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db),
):
    profile = crud_therapist.update_profile(db, current_user.id, data)
    if not profile:
        raise HTTPException(status_code=404, detail="Therapist profile not found")
    return profile
