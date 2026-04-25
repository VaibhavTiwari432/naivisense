from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.v1 import auth, therapist, children, sessions, feedback, tasks, reports
from app.core.config import settings
from app.core.database import Base, engine


def _run_migrations():
    from alembic.config import Config
    from alembic import command
    import os
    cfg = Config(os.path.join(os.path.dirname(__file__), '..', 'alembic.ini'))
    cfg.set_main_option('sqlalchemy.url', settings.DATABASE_URL)
    command.upgrade(cfg, 'head')


@asynccontextmanager
async def lifespan(app: FastAPI):
    if settings.DATABASE_URL.startswith('postgresql'):
        _run_migrations()
    else:
        Base.metadata.create_all(bind=engine)
    yield


app = FastAPI(
    title="NaiviSense API",
    description="AI-Powered Therapy Coordination Platform",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/api/v1/auth", tags=["Authentication"])
app.include_router(therapist.router, prefix="/api/v1/therapist", tags=["Therapist"])
app.include_router(children.router, prefix="/api/v1/children", tags=["Children"])
app.include_router(sessions.router, prefix="/api/v1/sessions", tags=["Sessions"])
app.include_router(feedback.router, prefix="/api/v1/feedback", tags=["Feedback"])
app.include_router(tasks.router, prefix="/api/v1/tasks", tags=["Tasks"])
app.include_router(reports.router, prefix="/api/v1/reports", tags=["Reports"])


@app.get("/")
async def root():
    return {"message": "NaiviSense API", "status": "running"}


@app.get("/health")
async def health():
    return {"status": "healthy"}
