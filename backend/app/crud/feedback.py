from datetime import date
from sqlalchemy.orm import Session
from app.models.feedback import DailyFeedback
from app.schemas.feedback import FeedbackCreate


def get_feedback_by_child(db: Session, child_id, limit: int = 30):
    return (
        db.query(DailyFeedback)
        .filter(DailyFeedback.child_id == child_id)
        .order_by(DailyFeedback.feedback_date.desc())
        .limit(limit)
        .all()
    )


def get_feedback_today(db: Session, child_id, parent_id):
    return (
        db.query(DailyFeedback)
        .filter(
            DailyFeedback.child_id == child_id,
            DailyFeedback.parent_id == parent_id,
            DailyFeedback.feedback_date == date.today(),
        )
        .first()
    )


def create_feedback(db: Session, parent_id, data: FeedbackCreate):
    dump = data.model_dump()
    if not dump.get('feedback_date'):
        dump['feedback_date'] = date.today()
    feedback = DailyFeedback(parent_id=parent_id, **dump)
    db.add(feedback)
    db.commit()
    db.refresh(feedback)
    return feedback
