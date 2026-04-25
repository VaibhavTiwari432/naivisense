import pytest

CHILD_PAYLOAD = {
    "name": "Aarav Khan",
    "date_of_birth": "2019-03-10",
    "gender": "Male",
    "diagnosis": "Speech Delay",
    "therapy_goals": ["Speech Therapy", "Eye Contact"],
    "emergency_contact": {
        "severity": "Mild",
        "mother_name": "Sara Khan",
        "father_name": "Ali Khan",
        "contact_number": "03001234567",
        "city": "Lahore",
    },
}


def test_create_child(client, therapist_headers):
    res = client.post("/api/v1/children/", json=CHILD_PAYLOAD, headers=therapist_headers)
    assert res.status_code == 200
    data = res.json()
    assert data["name"] == "Aarav Khan"
    assert "id" in data
    assert data["therapist_id"] is None  # assigned separately


def test_list_children_as_therapist(client, therapist_headers, child_id):
    res = client.get("/api/v1/children/", headers=therapist_headers)
    assert res.status_code == 200
    children = res.json()
    assert isinstance(children, list)
    ids = [c["id"] for c in children]
    assert child_id in ids


def test_get_child_by_id(client, therapist_headers, child_id):
    res = client.get(f"/api/v1/children/{child_id}", headers=therapist_headers)
    assert res.status_code == 200
    assert res.json()["id"] == child_id


def test_get_child_not_found(client, therapist_headers):
    res = client.get("/api/v1/children/nonexistent-id", headers=therapist_headers)
    assert res.status_code == 404


def test_list_children_requires_auth(client):
    res = client.get("/api/v1/children/")
    assert res.status_code == 401


def test_create_child_requires_auth(client):
    res = client.post("/api/v1/children/", json=CHILD_PAYLOAD)
    assert res.status_code == 401


def test_update_child(client, therapist_headers, child_id):
    res = client.put(f"/api/v1/children/{child_id}", json={
        "diagnosis": "ASD, Speech Delay",
        "therapy_goals": ["Speech Therapy", "Social Skills"],
    }, headers=therapist_headers)
    assert res.status_code == 200
    assert "ASD" in res.json()["diagnosis"]


def test_list_children_as_parent_sees_own(client, parent_headers):
    res = client.get("/api/v1/children/", headers=parent_headers)
    assert res.status_code == 200
    assert isinstance(res.json(), list)
