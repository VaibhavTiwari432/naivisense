from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session as DBSession
from typing import List
from app.core.database import get_db
from app.crud import session as crud_session
from app.schemas.session import SessionCreate, SessionResponse, SessionNotesCreate, SessionNotesResponse
from app.api.deps import get_current_user

router = APIRouter()


@router.get("/", response_model=List[SessionResponse])
async def list_sessions(current_user=Depends(get_current_user), db: DBSession = Depends(get_db)):
    return crud_session.get_sessions_by_therapist(db, current_user.id)


@router.get("/upcoming", response_model=List[SessionResponse])
async def upcoming_sessions(current_user=Depends(get_current_user), db: DBSession = Depends(get_db)):
    return crud_session.get_upcoming_sessions(db, current_user.id)


@router.post("/", response_model=SessionResponse)
async def create_session(
    data: SessionCreate,
    current_user=Depends(get_current_user),
    db: DBSession = Depends(get_db),
):
    return crud_session.create_session(db, current_user.id, data)


@router.post("/{session_id}/complete", response_model=SessionResponse)
async def complete_session(
    session_id: str,
    current_user=Depends(get_current_user),
    db: DBSession = Depends(get_db),
):
    session = crud_session.complete_session(db, session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    return session


@router.post("/{session_id}/notes", response_model=SessionNotesResponse)
async def add_session_notes(
    session_id: str,
    data: SessionNotesCreate,
    current_user=Depends(get_current_user),
    db: DBSession = Depends(get_db),
):
    session = crud_session.get_session_by_id(db, session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    return crud_session.create_session_notes(db, session_id, current_user.id, data)


@router.get("/{session_id}/notes", response_model=SessionNotesResponse)
async def get_session_notes(
    session_id: str,
    current_user=Depends(get_current_user),
    db: DBSession = Depends(get_db),
):
    notes = crud_session.get_session_notes(db, session_id)
    if not notes:
        raise HTTPException(status_code=404, detail="Notes not found")
    return notes
