import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from app.core.limiter import limiter
from app.api.v1 import auth, therapist, children, sessions, feedback, tasks, reports, intelligence, admin
from app.core.config import settings
from app.core.database import Base, engine

logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL.upper(), logging.INFO),
    format="%(asctime)s | %(levelname)-8s | %(name)s | %(message)s",
)
logger = logging.getLogger(__name__)


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
        logger.info("PostgreSQL detected — running Alembic migrations")
        _run_migrations()
    else:
        logger.info("SQLite detected — running create_all")
        Base.metadata.create_all(bind=engine)
    logger.info("NaiviSense API started (env=%s)", settings.ENVIRONMENT)
    yield


app = FastAPI(
    title="NaiviSense API",
    description="AI-Powered Therapy Coordination Platform",
    version="1.0.0",
    lifespan=lifespan,
)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
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
app.include_router(intelligence.router, prefix="/api/v1/intelligence", tags=["Intelligence"])
app.include_router(admin.router, prefix="/api/v1/admin", tags=["Admin"])


@app.get("/")
async def root():
    return {"message": "NaiviSense API", "status": "running"}


@app.get("/health")
async def health():
    return {"status": "healthy"}
