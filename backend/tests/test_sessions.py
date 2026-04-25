import pytest
from datetime import datetime, timedelta, timezone


def _future(days=1):
    return (datetime.now(timezone.utc) + timedelta(days=days)).isoformat()


def test_create_session(client, therapist_headers, child_id):
    res = client.post("/api/v1/sessions/", json={
        "child_id": child_id,
        "scheduled_at": _future(1),
        "session_type": "Speech Therapy",
        "duration_minutes": 45,
    }, headers=therapist_headers)
    assert res.status_code == 201
    data = res.json()
    assert data["child_id"] == child_id
    assert data["status"] in ("scheduled", "upcoming")


def test_list_sessions(client, therapist_headers, child_id):
    client.post("/api/v1/sessions/", json={
        "child_id": child_id,
        "scheduled_at": _future(2),
        "session_type": "OT",
        "duration_minutes": 30,
    }, headers=therapist_headers)
    res = client.get("/api/v1/sessions/", headers=therapist_headers)
    assert res.status_code == 200
    assert isinstance(res.json(), list)
    assert len(res.json()) >= 1


def test_upcoming_sessions(client, therapist_headers, child_id):
    res = client.get("/api/v1/sessions/upcoming", headers=therapist_headers)
    assert res.status_code == 200
    assert isinstance(res.json(), list)


def test_complete_session(client, therapist_headers, child_id):
    create = client.post("/api/v1/sessions/", json={
        "child_id": child_id,
        "scheduled_at": _future(3),
        "session_type": "Behavior",
        "duration_minutes": 60,
    }, headers=therapist_headers)
    session_id = create.json()["id"]

    res = client.post(f"/api/v1/sessions/{session_id}/complete", headers=therapist_headers)
    assert res.status_code == 200
    assert res.json()["status"] == "completed"


def test_add_session_notes(client, therapist_headers, child_id):
    create = client.post("/api/v1/sessions/", json={
        "child_id": child_id,
        "scheduled_at": _future(4),
        "session_type": "Speech Therapy",
        "duration_minutes": 45,
    }, headers=therapist_headers)
    session_id = create.json()["id"]

    res = client.post(f"/api/v1/sessions/{session_id}/notes", json={
        "attention_score": 4,
        "participation_score": 3,
        "mood_score": 5,
        "progress_score": 4,
        "behavior_score": 3,
        "observations": "Good session today.",
        "goals_worked_on": ["Eye contact", "Verbal responses"],
        "next_session_plan": "Focus on two-word phrases.",
    }, headers=therapist_headers)
    assert res.status_code == 201
    data = res.json()
    assert data["attention_score"] == 4
    assert data["observations"] == "Good session today."


def test_get_session_notes(client, therapist_headers, child_id):
    create = client.post("/api/v1/sessions/", json={
        "child_id": child_id,
        "scheduled_at": _future(5),
        "session_type": "OT",
        "duration_minutes": 30,
    }, headers=therapist_headers)
    session_id = create.json()["id"]
    client.post(f"/api/v1/sessions/{session_id}/notes", json={
        "attention_score": 3,
        "participation_score": 4,
        "mood_score": 3,
        "progress_score": 3,
        "behavior_score": 4,
        "observations": "Decent progress.",
        "goals_worked_on": [],
    }, headers=therapist_headers)

    res = client.get(f"/api/v1/sessions/{session_id}/notes", headers=therapist_headers)
    assert res.status_code == 200
    assert res.json()["observations"] == "Decent progress."


def test_get_notes_not_found(client, therapist_headers, child_id):
    create = client.post("/api/v1/sessions/", json={
        "child_id": child_id,
        "scheduled_at": _future(6),
        "session_type": "Speech Therapy",
        "duration_minutes": 45,
    }, headers=therapist_headers)
    session_id = create.json()["id"]
    res = client.get(f"/api/v1/sessions/{session_id}/notes", headers=therapist_headers)
    assert res.status_code == 404


def test_sessions_require_auth(client):
    assert client.get("/api/v1/sessions/").status_code == 401
    assert client.get("/api/v1/sessions/upcoming").status_code == 401
