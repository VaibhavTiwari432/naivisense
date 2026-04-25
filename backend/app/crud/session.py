from datetime import datetime, timezone
from sqlalchemy.orm import Session as DBSession
from app.models.session import Session, SessionStatus
from app.models.session_notes import SessionNotes
from app.schemas.session import SessionCreate, SessionNotesCreate


def get_sessions_by_therapist(db: DBSession, therapist_id):
    return db.query(Session).filter(Session.therapist_id == therapist_id).all()


def get_sessions_by_child(db: DBSession, child_id):
    return db.query(Session).filter(Session.child_id == child_id).all()


def get_upcoming_sessions(db: DBSession, therapist_id):
    return (
        db.query(Session)
        .filter(
            Session.therapist_id == therapist_id,
            Session.status == SessionStatus.SCHEDULED,
            Session.scheduled_at >= datetime.now(timezone.utc),
        )
        .order_by(Session.scheduled_at)
        .all()
    )


def get_session_by_id(db: DBSession, session_id):
    return db.query(Session).filter(Session.id == session_id).first()


def create_session(db: DBSession, therapist_id, data: SessionCreate):
    session = Session(therapist_id=therapist_id, **data.model_dump())
    db.add(session)
    db.commit()
    db.refresh(session)
    return session


def complete_session(db: DBSession, session_id):
    session = get_session_by_id(db, session_id)
    if session:
        session.status = SessionStatus.COMPLETED
        db.commit()
        db.refresh(session)
    return session


def create_session_notes(db: DBSession, session_id, therapist_id, data: SessionNotesCreate):
    notes = SessionNotes(session_id=session_id, therapist_id=therapist_id, **data.model_dump())
    db.add(notes)
    db.commit()
    db.refresh(notes)
    return notes


def get_session_notes(db: DBSession, session_id):
    return db.query(SessionNotes).filter(SessionNotes.session_id == session_id).first()
