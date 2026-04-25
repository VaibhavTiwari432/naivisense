from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.session_notes import SessionNotes
from app.models.session import Session as SessionModel
from app.models.feedback import DailyFeedback
from app.crud import child as crud_child
from app.api.deps import get_current_user

router = APIRouter()


@router.get("/progress/{child_id}")
async def get_progress_report(
    child_id: str,
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db),
):
    child = crud_child.get_child_by_id(db, child_id)
    if not child:
        return {"error": "Child not found"}

    sessions = (
        db.query(SessionModel)
        .filter(SessionModel.child_id == child_id)
        .order_by(SessionModel.scheduled_at.desc())
        .limit(10)
        .all()
    )

    session_ids = [s.id for s in sessions]
    notes = db.query(SessionNotes).filter(SessionNotes.session_id.in_(session_ids)).all()

    feedbacks = (
        db.query(DailyFeedback)
        .filter(DailyFeedback.child_id == child_id)
        .order_by(DailyFeedback.feedback_date.desc())
        .limit(30)
        .all()
    )

    avg_scores = {}
    if notes:
        score_fields = ["attention_score", "participation_score", "mood_score", "progress_score", "behavior_score"]
        for field in score_fields:
            values = [getattr(n, field) for n in notes if getattr(n, field) is not None]
            avg_scores[field] = round(sum(values) / len(values), 2) if values else None

    sessions_completed = sum(1 for s in sessions if s.status.value == "completed")
    sessions_scheduled = len(sessions)
    attendance_percent = round(sessions_completed / sessions_scheduled * 100) if sessions_scheduled > 0 else 0

    all_score_values = [v for v in avg_scores.values() if v is not None]
    average_progress = round(sum(all_score_values) / len(all_score_values), 2) if all_score_values else 0.0

    progress_trend = [
        {"label": f"W{i + 1}", "score": float(n.progress_score or 0)}
        for i, n in enumerate(reversed(notes[:8]))
    ]

    therapist_note = notes[0].next_session_plan if notes and notes[0].next_session_plan else None

    return {
        "child_id": str(child_id),
        "child_name": child.name,
        "sessions_completed": sessions_completed,
        "sessions_scheduled": sessions_scheduled,
        "attendance_percent": attendance_percent,
        "average_progress": average_progress,
        "average_therapy_scores": avg_scores,
        "total_feedback_entries": len(feedbacks),
        "progress_trend": progress_trend,
        "therapist_note": therapist_note,
    }
