from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from app.core.database import get_db
from app.models.task import Task, TaskStatus
from app.schemas.task import TaskCreate, TaskUpdate, TaskResponse
from app.api.deps import get_current_user
from datetime import datetime

router = APIRouter()


@router.get("/", response_model=List[TaskResponse])
async def list_tasks(
    child_id: Optional[str] = None,
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db),
):
    query = db.query(Task).filter(Task.assigned_by == current_user.id)
    if child_id:
        query = query.filter(Task.child_id == child_id)
    return query.all()


@router.post("/", response_model=TaskResponse)
async def create_task(
    data: TaskCreate,
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db),
):
    task = Task(assigned_by=current_user.id, **data.model_dump())
    db.add(task)
    db.commit()
    db.refresh(task)
    return task


@router.put("/{task_id}", response_model=TaskResponse)
async def update_task(
    task_id: str,
    data: TaskUpdate,
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db),
):
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    for field, value in data.model_dump(exclude_unset=True).items():
        setattr(task, field, value)
    if data.status == TaskStatus.COMPLETED:
        task.completed_at = datetime.utcnow()
    db.commit()
    db.refresh(task)
    return task
