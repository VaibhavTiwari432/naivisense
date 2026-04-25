from sqlalchemy import or_
from sqlalchemy.orm import Session
from app.models.child import Child
from app.schemas.child import ChildCreate, ChildUpdate


def get_children_by_parent(db: Session, parent_id):
    return db.query(Child).filter(Child.parent_id == parent_id).all()


def get_children_by_therapist(db: Session, therapist_id):
    return db.query(Child).filter(
        or_(Child.therapist_id == therapist_id, Child.parent_id == therapist_id)
    ).all()


def get_child_by_id(db: Session, child_id):
    return db.query(Child).filter(Child.id == child_id).first()


def create_child(db: Session, parent_id, data: ChildCreate):
    child = Child(parent_id=parent_id, **data.model_dump())
    db.add(child)
    db.commit()
    db.refresh(child)
    return child


def update_child(db: Session, child_id, data: ChildUpdate):
    child = get_child_by_id(db, child_id)
    if not child:
        return None
    for field, value in data.model_dump(exclude_unset=True).items():
        setattr(child, field, value)
    db.commit()
    db.refresh(child)
    return child
