import pytest


def test_progress_report_no_sessions(client, therapist_headers, child_id):
    res = client.get(f"/api/v1/reports/progress/{child_id}", headers=therapist_headers)
    assert res.status_code == 200
    data = res.json()
    assert data["child_id"] == child_id
    assert data["sessions_completed"] == 0
    assert data["attendance_percent"] == 0
    assert isinstance(data["progress_trend"], list)


def test_progress_report_with_sessions(client, therapist_headers, child_id):
    from datetime import datetime, timedelta

    # Create and complete 2 sessions with notes
    for i in range(2):
        sched = (datetime.utcnow() - timedelta(days=i + 1)).isoformat()
        create = client.post("/api/v1/sessions/", json={
            "child_id": child_id,
            "scheduled_at": sched,
            "session_type": "Speech Therapy",
            "duration_minutes": 45,
        }, headers=therapist_headers)
        sid = create.json()["id"]
        client.post(f"/api/v1/sessions/{sid}/complete", headers=therapist_headers)
        client.post(f"/api/v1/sessions/{sid}/notes", json={
            "attention_score": 4,
            "participation_score": 4,
            "mood_score": 5,
            "progress_score": 4,
            "behavior_score": 3,
            "observations": f"Session {i + 1} notes.",
            "goals_worked_on": ["Speech"],
        }, headers=therapist_headers)

    res = client.get(f"/api/v1/reports/progress/{child_id}", headers=therapist_headers)
    assert res.status_code == 200
    data = res.json()
    assert data["sessions_completed"] >= 2
    assert data["average_progress"] > 0
    assert len(data["progress_trend"]) >= 2


def test_progress_report_unknown_child(client, therapist_headers):
    res = client.get("/api/v1/reports/progress/nonexistent-id", headers=therapist_headers)
    assert res.status_code == 200
    assert "error" in res.json()


def test_progress_report_requires_auth(client, child_id):
    res = client.get(f"/api/v1/reports/progress/{child_id}")
    assert res.status_code == 401


def test_tasks_for_child(client, therapist_headers, child_id):
    client.post("/api/v1/tasks/", json={
        "child_id": child_id,
        "title": "Practice vowel sounds",
        "description": "10 minutes daily",
        "is_home_task": True,
    }, headers=therapist_headers)

    res = client.get(f"/api/v1/tasks/?child_id={child_id}", headers=therapist_headers)
    assert res.status_code == 200
    tasks = res.json()
    assert isinstance(tasks, list)
    assert any(t["title"] == "Practice vowel sounds" for t in tasks)


def test_update_task_status(client, therapist_headers, child_id):
    create = client.post("/api/v1/tasks/", json={
        "child_id": child_id,
        "title": "Flashcard practice",
        "is_home_task": False,
    }, headers=therapist_headers)
    task_id = create.json()["id"]

    res = client.put(f"/api/v1/tasks/{task_id}", json={
        "status": "completed",
    }, headers=therapist_headers)
    assert res.status_code == 200
    assert res.json()["status"] == "completed"
