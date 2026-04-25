from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.crud import feedback as crud_feedback
from app.schemas.feedback import FeedbackCreate, FeedbackResponse
from app.api.deps import get_current_user

router = APIRouter()


@router.post("/daily", response_model=FeedbackResponse)
async def submit_feedback(
    data: FeedbackCreate,
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db),
):
    existing = crud_feedback.get_feedback_today(db, data.child_id, current_user.id)
    if existing:
        raise HTTPException(status_code=400, detail="Feedback already submitted for today")
    return crud_feedback.create_feedback(db, current_user.id, data)


@router.get("/history/{child_id}", response_model=List[FeedbackResponse])
async def feedback_history(
    child_id: str,
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return crud_feedback.get_feedback_by_child(db, child_id)
