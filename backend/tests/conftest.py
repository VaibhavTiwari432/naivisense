import os
os.environ["ENVIRONMENT"] = "testing"  # disable rate limiter before app is imported

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.database import Base, get_db
from app.main import app

TEST_DB_URL = "sqlite:///./test_naivisense.db"

engine = create_engine(TEST_DB_URL, connect_args={"check_same_thread": False})
TestingSession = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def override_get_db():
    db = TestingSession()
    try:
        yield db
    finally:
        db.close()


@pytest.fixture(scope="session", autouse=True)
def setup_db():
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)
    engine.dispose()
    import os, time
    for _ in range(3):
        try:
            if os.path.exists("test_naivisense.db"):
                os.remove("test_naivisense.db")
            break
        except PermissionError:
            time.sleep(0.5)


@pytest.fixture(scope="session")
def client(setup_db):
    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()


@pytest.fixture(scope="session")
def therapist_token(client):
    client.post("/api/v1/auth/register", json={
        "name": "Test Therapist",
        "phone": "03001110001",
        "password": "Password123",
        "role": "therapist",
    })
    res = client.post("/api/v1/auth/login", json={
        "phone": "03001110001",
        "password": "Password123",
    })
    return res.json()["access_token"]


@pytest.fixture(scope="session")
def parent_token(client):
    client.post("/api/v1/auth/register", json={
        "name": "Test Parent",
        "phone": "03002220002",
        "password": "Password123",
        "role": "parent",
    })
    res = client.post("/api/v1/auth/login", json={
        "phone": "03002220002",
        "password": "Password123",
    })
    return res.json()["access_token"]


@pytest.fixture(scope="session")
def therapist_headers(therapist_token):
    return {"Authorization": f"Bearer {therapist_token}"}


@pytest.fixture(scope="session")
def parent_headers(parent_token):
    return {"Authorization": f"Bearer {parent_token}"}


@pytest.fixture(scope="session")
def child_id(client, therapist_headers):
    res = client.post("/api/v1/children/", json={
        "name": "Test Child",
        "date_of_birth": "2018-06-15",
        "gender": "Male",
        "diagnosis": "ASD",
        "therapy_goals": ["Speech", "Focus"],
        "emergency_contact": {
            "severity": "Moderate",
            "mother_name": "Test Mom",
            "father_name": "Test Dad",
            "contact_number": "03001111111",
            "city": "Karachi",
        },
    }, headers=therapist_headers)
    assert res.status_code == 201
    return res.json()["id"]
