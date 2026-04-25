import pytest


def test_register_therapist(client):
    res = client.post("/api/v1/auth/register", json={
        "name": "New Therapist",
        "phone": "03009990001",
        "password": "Password123",
        "role": "therapist",
    })
    assert res.status_code == 201
    data = res.json()
    assert "access_token" in data
    assert data["user"]["name"] == "New Therapist"
    assert data["user"]["role"] == "therapist"


def test_register_parent(client):
    res = client.post("/api/v1/auth/register", json={
        "name": "New Parent",
        "phone": "03009990002",
        "password": "Password123",
        "role": "parent",
    })
    assert res.status_code == 201
    data = res.json()
    assert data["user"]["role"] == "parent"


def test_register_duplicate_phone(client):
    payload = {
        "name": "Dup User",
        "phone": "03009990003",
        "password": "Password123",
        "role": "therapist",
    }
    client.post("/api/v1/auth/register", json=payload)
    res = client.post("/api/v1/auth/register", json=payload)
    assert res.status_code == 400


def test_login_success(client):
    client.post("/api/v1/auth/register", json={
        "name": "Login User",
        "phone": "03009990004",
        "password": "Secret456",
        "role": "therapist",
    })
    res = client.post("/api/v1/auth/login", json={
        "phone": "03009990004",
        "password": "Secret456",
    })
    assert res.status_code == 200
    assert "access_token" in res.json()


def test_login_wrong_password(client):
    res = client.post("/api/v1/auth/login", json={
        "phone": "03009990004",
        "password": "WrongPassword",
    })
    assert res.status_code == 401


def test_login_unknown_phone(client):
    res = client.post("/api/v1/auth/login", json={
        "phone": "03000000000",
        "password": "Password123",
    })
    assert res.status_code == 401


def test_get_me(client, therapist_headers):
    res = client.get("/api/v1/auth/me", headers=therapist_headers)
    assert res.status_code == 200
    data = res.json()
    assert "id" in data
    assert data["role"] == "therapist"


def test_get_me_no_token(client):
    res = client.get("/api/v1/auth/me")
    assert res.status_code == 401


def test_token_contains_role(client):
    client.post("/api/v1/auth/register", json={
        "name": "Role Check",
        "phone": "03009990005",
        "password": "Password123",
        "role": "parent",
    })
    res = client.post("/api/v1/auth/login", json={
        "phone": "03009990005",
        "password": "Password123",
    })
    import base64, json
    token = res.json()["access_token"]
    payload = token.split(".")[1]
    payload += "=" * (-len(payload) % 4)
    decoded = json.loads(base64.b64decode(payload))
    assert decoded["role"] == "parent"
