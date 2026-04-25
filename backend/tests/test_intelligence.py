"""
Intelligence layer tests.
Claude API calls (AI-002, AI-004) return degraded results when ANTHROPIC_API_KEY
is empty, so no mocking needed — all 12 tests are fully deterministic.
"""
from datetime import datetime, timedelta, timezone


def _future(days):
    return (datetime.now(timezone.utc) + timedelta(days=days)).isoformat()


def _session_with_notes(client, headers, child_id, day_offset, scores, observations=""):
    create = client.post("/api/v1/sessions/", json={
        "child_id": child_id,
        "scheduled_at": _future(day_offset),
        "session_type": "Speech Therapy",
        "duration_minutes": 45,
    }, headers=headers)
    sid = create.json()["id"]
    client.post(f"/api/v1/sessions/{sid}/notes", json={
        **scores,
        "observations": observations,
        "goals_worked_on": ["Eye contact", "Verbal requests"],
    }, headers=headers)
    return sid


# ── AI-001: Skill Score ───────────────────────────────────────────────────────

def test_skill_score_no_data(client, therapist_headers, child_id):
    res = client.get(f"/api/v1/intelligence/skill-score/{child_id}", headers=therapist_headers)
    assert res.status_code == 200
    data = res.json()
    assert data["child_id"] == child_id
    assert data["sessions_analyzed"] == 0
    assert data["composite_score"] is None
    assert data["skill_level"] is None


def test_skill_score_with_notes(client, therapist_headers, child_id):
    _session_with_notes(client, therapist_headers, child_id, 30, {
        "attention_score": 4, "participation_score": 3,
        "mood_score": 4, "progress_score": 4, "behavior_score": 3,
    })
    res = client.get(f"/api/v1/intelligence/skill-score/{child_id}", headers=therapist_headers)
    assert res.status_code == 200
    data = res.json()
    assert data["composite_score"] is not None
    assert data["composite_score"] > 0
    assert data["skill_level"] in ("Emerging", "Developing", "Proficient", "Advanced")
    assert data["trend"] in ("improving", "stable", "declining")
    assert data["sessions_analyzed"] >= 1


def test_skill_score_level_boundaries(client, therapist_headers, child_id):
    # Score all 5s → Advanced
    _session_with_notes(client, therapist_headers, child_id, 35, {
        "attention_score": 5, "participation_score": 5,
        "mood_score": 5, "progress_score": 5, "behavior_score": 5,
    })
    res = client.get(f"/api/v1/intelligence/skill-score/{child_id}", headers=therapist_headers)
    assert res.json()["skill_level"] == "Advanced"


def test_skill_score_unknown_child(client, therapist_headers):
    res = client.get("/api/v1/intelligence/skill-score/no-such-id", headers=therapist_headers)
    assert res.status_code == 404


# ── AI-003: Therapist Matching ────────────────────────────────────────────────

def test_match_therapist_returns_list(client, therapist_headers, child_id):
    res = client.get(f"/api/v1/intelligence/match-therapist/{child_id}", headers=therapist_headers)
    assert res.status_code == 200
    data = res.json()
    assert data["child_id"] == child_id
    assert isinstance(data["matches"], list)
    assert isinstance(data["therapy_goals"], list)


def test_match_therapist_with_profile(client, therapist_headers, child_id):
    # Create a therapist profile so the matcher has something to score
    client.post("/api/v1/therapist/profile", json={
        "specialization": "ASD Speech Delay",
        "years_of_experience": 5,
        "qualification": "MSc SLP",
        "clinic_name": "HopeCare",
        "languages": ["English", "Urdu"],
    }, headers=therapist_headers)
    res = client.get(f"/api/v1/intelligence/match-therapist/{child_id}", headers=therapist_headers)
    assert res.status_code == 200
    matches = res.json()["matches"]
    assert len(matches) >= 1
    top = matches[0]
    assert "therapist_id" in top
    assert "match_score" in top
    assert isinstance(top["match_reasons"], list)


def test_match_therapist_unknown_child(client, therapist_headers):
    res = client.get("/api/v1/intelligence/match-therapist/no-such-id", headers=therapist_headers)
    assert res.status_code == 404


# ── AI-002: Auto-tag ─────────────────────────────────────────────────────────

def test_auto_tag_no_api_key_returns_empty(client, therapist_headers, child_id):
    sid = _session_with_notes(
        client, therapist_headers, child_id, 40,
        {"attention_score": 3, "participation_score": 3,
         "mood_score": 3, "progress_score": 3, "behavior_score": 3},
        observations="Child practiced pincer grasp and made good eye contact.",
    )
    res = client.post(f"/api/v1/intelligence/auto-tag/{sid}", headers=therapist_headers)
    assert res.status_code == 200
    data = res.json()
    assert data["session_id"] == sid
    assert isinstance(data["tags"], list)   # [] without API key — graceful degradation


def test_auto_tag_no_notes_returns_404(client, therapist_headers, child_id):
    create = client.post("/api/v1/sessions/", json={
        "child_id": child_id,
        "scheduled_at": _future(45),
        "session_type": "OT",
        "duration_minutes": 30,
    }, headers=therapist_headers)
    sid = create.json()["id"]
    res = client.post(f"/api/v1/intelligence/auto-tag/{sid}", headers=therapist_headers)
    assert res.status_code == 404


# ── AI-004: Narrative Report ──────────────────────────────────────────────────

def test_generate_report_weekly(client, therapist_headers, child_id):
    res = client.get(
        f"/api/v1/intelligence/generate-report/{child_id}?period=weekly",
        headers=therapist_headers,
    )
    assert res.status_code == 200
    data = res.json()
    assert data["child_id"] == child_id
    assert data["period"] == "weekly"
    assert isinstance(data["narrative"], str)
    assert len(data["narrative"]) > 10


def test_generate_report_monthly(client, therapist_headers, child_id):
    res = client.get(
        f"/api/v1/intelligence/generate-report/{child_id}?period=monthly",
        headers=therapist_headers,
    )
    assert res.status_code == 200
    assert res.json()["period"] == "monthly"


def test_generate_report_unknown_child(client, therapist_headers):
    res = client.get(
        "/api/v1/intelligence/generate-report/no-such-id?period=weekly",
        headers=therapist_headers,
    )
    assert res.status_code == 404


# ── Auth guard ────────────────────────────────────────────────────────────────

def test_intelligence_requires_auth(client, child_id):
    assert client.get(f"/api/v1/intelligence/skill-score/{child_id}").status_code == 401
    assert client.get(f"/api/v1/intelligence/match-therapist/{child_id}").status_code == 401
    assert client.get(f"/api/v1/intelligence/generate-report/{child_id}").status_code == 401
    assert client.post(f"/api/v1/intelligence/auto-tag/any-id").status_code == 401
