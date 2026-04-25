from datetime import datetime, timedelta, timezone
from typing import Literal

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.core.config import settings
from app.core.database import get_db
from app.crud import child as crud_child
from app.models.feedback import DailyFeedback
from app.models.session import Session as SessionModel
from app.models.session_notes import SessionNotes
from app.models.therapist import TherapistProfile
from app.models.user import User
from app.schemas.intelligence import (
    AutoTagResponse,
    MatchingResponse,
    NarrativeReportResponse,
    SkillScoreResponse,
    TherapistMatch,
)
from app.services import intelligence as svc

router = APIRouter()


# ── AI-001: Skill Score ───────────────────────────────────────────────────────

@router.get("/skill-score/{child_id}", response_model=SkillScoreResponse)
async def get_skill_score(
    child_id: str,
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db),
):
    child = crud_child.get_child_by_id(db, child_id)
    if not child:
        raise HTTPException(status_code=404, detail="Child not found")

    session_ids = [
        s.id
        for s in db.query(SessionModel).filter(SessionModel.child_id == child_id).all()
    ]
    notes = (
        db.query(SessionNotes)
        .filter(SessionNotes.session_id.in_(session_ids))
        .all()
        if session_ids else []
    )

    result = svc.compute_skill_score(child, notes)
    return SkillScoreResponse(child_id=child_id, child_name=child.name, **result)


# ── AI-003: Therapist Matching ────────────────────────────────────────────────

@router.get("/match-therapist/{child_id}", response_model=MatchingResponse)
async def match_therapist(
    child_id: str,
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db),
):
    child = crud_child.get_child_by_id(db, child_id)
    if not child:
        raise HTTPException(status_code=404, detail="Child not found")

    profiles = (
        db.query(TherapistProfile, User)
        .join(User, User.id == TherapistProfile.user_id)
        .filter(User.role == "therapist")
        .all()
    )

    matches = svc.match_therapists(child, profiles)
    return MatchingResponse(
        child_id=child_id,
        child_name=child.name,
        diagnosis=child.diagnosis,
        therapy_goals=child.therapy_goals or [],
        matches=[TherapistMatch(**m) for m in matches],
    )


# ── AI-002: Auto-tag Session Notes ───────────────────────────────────────────

@router.post("/auto-tag/{session_id}", response_model=AutoTagResponse)
async def auto_tag_session(
    session_id: str,
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db),
):
    notes = (
        db.query(SessionNotes)
        .filter(SessionNotes.session_id == session_id)
        .first()
    )
    if not notes:
        raise HTTPException(status_code=404, detail="Session notes not found")
    if not notes.observations:
        return AutoTagResponse(session_id=session_id, tags=[])

    tags = await svc.auto_tag_observations(notes.observations, settings.ANTHROPIC_API_KEY)
    return AutoTagResponse(session_id=session_id, tags=tags)


# ── AI-004: Narrative Report Generator ───────────────────────────────────────

@router.get("/generate-report/{child_id}", response_model=NarrativeReportResponse)
async def generate_report(
    child_id: str,
    period: Literal["weekly", "monthly"] = "weekly",
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db),
):
    child = crud_child.get_child_by_id(db, child_id)
    if not child:
        raise HTTPException(status_code=404, detail="Child not found")

    days = 7 if period == "weekly" else 30
    since = datetime.now(timezone.utc) - timedelta(days=days)

    sessions = (
        db.query(SessionModel)
        .filter(SessionModel.child_id == child_id, SessionModel.scheduled_at >= since)
        .all()
    )
    session_ids = [s.id for s in sessions]
    notes = (
        db.query(SessionNotes).filter(SessionNotes.session_id.in_(session_ids)).all()
        if session_ids else []
    )
    feedbacks = (
        db.query(DailyFeedback)
        .filter(
            DailyFeedback.child_id == child_id,
            DailyFeedback.feedback_date >= since.date(),
        )
        .all()
    )

    completed = sum(1 for s in sessions if s.status.value == "completed")

    score_fields = [
        "attention_score", "participation_score",
        "mood_score", "progress_score", "behavior_score",
    ]
    dim_avgs: dict[str, float] = {}
    for field in score_fields:
        vals = [getattr(n, field) for n in notes if getattr(n, field) is not None]
        dim_avgs[field] = round(sum(vals) / len(vals), 2) if vals else 0.0

    avg_progress = dim_avgs.get("progress_score", 0.0)
    non_zero = {k: v for k, v in dim_avgs.items() if v > 0}
    strongest = max(non_zero, key=non_zero.get) if non_zero else "N/A"
    weakest = min(non_zero, key=non_zero.get) if non_zero else "N/A"

    goals = list({g for n in notes for g in (n.goals_worked_on or [])})[:5]
    latest_note = notes[0].next_session_plan if notes else None

    fb_mood = [f.mood_score for f in feedbacks if f.mood_score is not None]
    avg_feedback_mood = round(sum(fb_mood) / len(fb_mood), 1) if fb_mood else 0.0

    data = {
        "child_name": child.name,
        "sessions_completed": completed,
        "avg_progress": avg_progress,
        "strongest": strongest.replace("_score", "").replace("_", " "),
        "weakest": weakest.replace("_score", "").replace("_", " "),
        "goals": goals,
        "latest_note": latest_note,
        "avg_feedback_mood": avg_feedback_mood,
    }

    narrative = await svc.generate_narrative_report(data, period, settings.ANTHROPIC_API_KEY)
    return NarrativeReportResponse(
        child_id=child_id,
        child_name=child.name,
        period=period,
        narrative=narrative,
    )
