from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.crud import child as crud_child
from app.schemas.child import ChildCreate, ChildUpdate, ChildResponse
from app.api.deps import get_current_user

router = APIRouter()


@router.get("/", response_model=List[ChildResponse])
async def list_children(current_user=Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.role == "parent":
        return crud_child.get_children_by_parent(db, current_user.id)
    elif current_user.role in ("therapist", "admin"):
        return crud_child.get_children_by_therapist(db, current_user.id)
    return []


@router.post("/", response_model=ChildResponse, status_code=201)
async def create_child(
    data: ChildCreate,
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return crud_child.create_child(db, current_user.id, data)


@router.get("/{child_id}", response_model=ChildResponse)
async def get_child(child_id: str, current_user=Depends(get_current_user), db: Session = Depends(get_db)):
    child = crud_child.get_child_by_id(db, child_id)
    if not child:
        raise HTTPException(status_code=404, detail="Child not found")
    return child


@router.put("/{child_id}", response_model=ChildResponse)
async def update_child(
    child_id: str,
    data: ChildUpdate,
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db),
):
    child = crud_child.update_child(db, child_id, data)
    if not child:
        raise HTTPException(status_code=404, detail="Child not found")
    return child
