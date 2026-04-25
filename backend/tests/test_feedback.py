import pytest


def test_submit_feedback(client, parent_headers, child_id):
    from datetime import date
    res = client.post("/api/v1/feedback/daily", json={
        "child_id": child_id,
        "feedback_date": str(date.today()),
        "mood_score": 4,
        "sleep_score": 5,
        "appetite_score": 4,
        "cooperation_score": 3,
        "home_practice_done": True,
        "notes": "Had a great day, practiced well.",
    }, headers=parent_headers)
    assert res.status_code == 200
    data = res.json()
    assert data["sleep_score"] == 5
    assert data["notes"] == "Had a great day, practiced well."


def test_submit_feedback_duplicate_today(client, parent_headers, child_id):
    from datetime import date
    payload = {
        "child_id": child_id,
        "feedback_date": str(date.today()),
        "sleep_score": 3,
        "appetite_score": 3,
    }
    client.post("/api/v1/feedback/daily", json=payload, headers=parent_headers)
    res = client.post("/api/v1/feedback/daily", json=payload, headers=parent_headers)
    assert res.status_code == 400


def test_feedback_history(client, therapist_headers, child_id):
    res = client.get(f"/api/v1/feedback/history/{child_id}", headers=therapist_headers)
    assert res.status_code == 200
    assert isinstance(res.json(), list)
    assert len(res.json()) >= 1


def test_feedback_history_empty_for_unknown_child(client, therapist_headers):
    res = client.get("/api/v1/feedback/history/nonexistent-id", headers=therapist_headers)
    assert res.status_code == 200
    assert res.json() == []


def test_feedback_requires_auth(client, child_id):
    from datetime import date
    assert client.post("/api/v1/feedback/daily", json={
        "child_id": child_id,
        "feedback_date": str(date.today()),
    }).status_code == 401
    assert client.get(f"/api/v1/feedback/history/{child_id}").status_code == 401
