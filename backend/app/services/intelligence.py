"""
Intelligence layer — four AI features:
  AI-001  compute_skill_score     pure algorithm
  AI-002  auto_tag_observations   Claude Haiku
  AI-003  match_therapists        pure algorithm
  AI-004  generate_narrative_report  Claude Haiku (falls back to template)
"""
import json
import logging
from typing import Optional

from app.models.child import Child
from app.models.session_notes import SessionNotes
from app.models.therapist import TherapistProfile
from app.models.user import User

logger = logging.getLogger(__name__)

# ── AI-001: Skill Scoring ─────────────────────────────────────────────────────

_WEIGHTS = {
    "progress_score": 1.5,
    "attention_score": 1.0,
    "participation_score": 1.0,
    "mood_score": 0.75,
    "behavior_score": 0.75,
}


def _weighted_note_score(note: SessionNotes) -> Optional[float]:
    total, w_sum = 0.0, 0.0
    for field, weight in _WEIGHTS.items():
        val = getattr(note, field, None)
        if val is not None:
            total += val * weight
            w_sum += weight
    return round(total / w_sum, 3) if w_sum > 0 else None


def compute_skill_score(child: Child, notes: list[SessionNotes]) -> dict:
    sorted_notes = sorted(notes, key=lambda n: n.created_at)
    timeline = [s for n in sorted_notes if (s := _weighted_note_score(n)) is not None]

    if not timeline:
        return {
            "composite_score": None,
            "skill_level": None,
            "trend": None,
            "dimension_scores": {f: None for f in _WEIGHTS},
            "sessions_analyzed": 0,
        }

    composite = round(sum(timeline) / len(timeline), 2)

    # Trend: compare first half vs second half (need ≥ 4 points for significance)
    if len(timeline) >= 4:
        mid = len(timeline) // 2
        delta = sum(timeline[mid:]) / (len(timeline) - mid) - sum(timeline[:mid]) / mid
    elif len(timeline) >= 2:
        delta = timeline[-1] - timeline[0]
    else:
        delta = 0.0

    trend = "improving" if delta > 0.25 else "declining" if delta < -0.25 else "stable"
    level = (
        "Advanced" if composite >= 4.0
        else "Proficient" if composite >= 3.0
        else "Developing" if composite >= 2.0
        else "Emerging"
    )

    dim = {}
    for field in _WEIGHTS:
        vals = [getattr(n, field) for n in notes if getattr(n, field) is not None]
        dim[field] = round(sum(vals) / len(vals), 2) if vals else None

    return {
        "composite_score": composite,
        "skill_level": level,
        "trend": trend,
        "dimension_scores": dim,
        "sessions_analyzed": len(timeline),
    }


# ── AI-003: Therapist-Child Matching ─────────────────────────────────────────

def match_therapists(
    child: Child,
    profiles: list[tuple[TherapistProfile, User]],
) -> list[dict]:
    diag_kw = set((child.diagnosis or "").lower().split())
    goal_kw: set[str] = set()
    for goal in child.therapy_goals or []:
        goal_kw.update(goal.lower().split())

    results = []
    for profile, user in profiles:
        score = 0
        reasons: list[str] = []

        # Specialization match → 0-50 pts
        if profile.specialization:
            spec_kw = set(profile.specialization.lower().split())
            pts = min(50, len(diag_kw & spec_kw) * 15 + len(goal_kw & spec_kw) * 5)
            score += pts
            if pts > 0:
                reasons.append(f"Specializes in {profile.specialization}")

        # Experience → 0-20 pts (2 pts/year)
        exp = profile.years_of_experience or 0
        score += min(20, exp * 2)
        if exp > 0:
            reasons.append(f"{exp} years of experience")

        # Rating → 0-20 pts
        rating = profile.rating or 0.0
        score += round((rating / 5.0) * 20)
        if rating > 0:
            reasons.append(f"Rated {rating:.1f}/5.0")

        # Session volume → 0-10 pts (1 pt per 10 sessions)
        score += min(10, (profile.total_sessions or 0) // 10)

        results.append({
            "therapist_id": str(user.id),
            "therapist_name": user.name,
            "specialization": profile.specialization,
            "years_of_experience": exp,
            "rating": rating,
            "match_score": score,
            "match_reasons": reasons or ["Available therapist"],
        })

    results.sort(key=lambda x: x["match_score"], reverse=True)
    return results[:5]


# ── AI-002: Auto-tagging via Claude Haiku ────────────────────────────────────

async def auto_tag_observations(text: str, api_key: str) -> list[str]:
    if not api_key or not text.strip():
        return []
    try:
        from anthropic import AsyncAnthropic
        client = AsyncAnthropic(api_key=api_key)
        msg = await client.messages.create(
            model="claude-haiku-4-5-20251001",
            max_tokens=150,
            messages=[{
                "role": "user",
                "content": (
                    "You are a pediatric therapy assistant. Extract up to 5 concise therapy "
                    "target tags from this therapist observation. Return ONLY a valid JSON array "
                    "of short strings (2-4 words each). "
                    "Example: [\"Eye contact\", \"Verbal initiation\", \"Turn-taking\"]\n\n"
                    f"Observation: \"{text}\"\n\nTags:"
                ),
            }],
        )
        return json.loads(msg.content[0].text.strip())
    except Exception as exc:
        logger.warning("auto_tag_observations failed: %s", exc)
        return []


# ── AI-004: Narrative Report Generator ───────────────────────────────────────

def _template_report(data: dict, period: str) -> str:
    goals_str = ", ".join(data["goals"]) if data["goals"] else "various therapy targets"
    return (
        f"{data['child_name']} had {data['sessions_completed']} session(s) this {period}. "
        f"Average progress score: {data['avg_progress']}/5. "
        f"Goals worked on: {goals_str}. "
        f"Parent-reported mood: {data['avg_feedback_mood']}/5."
    )


async def generate_narrative_report(data: dict, period: str, api_key: str) -> str:
    if not api_key:
        return _template_report(data, period)
    try:
        from anthropic import AsyncAnthropic
        client = AsyncAnthropic(api_key=api_key)
        prompt = (
            f"Write a warm, professional {period} therapy progress report for parents and therapists.\n\n"
            f"Child: {data['child_name']}\n"
            f"Sessions completed: {data['sessions_completed']}\n"
            f"Average progress score: {data['avg_progress']}/5\n"
            f"Strongest area: {data['strongest']}\n"
            f"Area needing attention: {data['weakest']}\n"
            f"Goals worked on: {', '.join(data['goals']) or 'various goals'}\n"
            f"Parent-reported mood average: {data['avg_feedback_mood']}/5\n"
            f"Latest therapist note: {data['latest_note'] or 'N/A'}\n\n"
            f"Write exactly 3 short paragraphs: "
            f"(1) overall {period} summary, "
            f"(2) specific achievements and focus areas, "
            f"(3) recommendations for the coming {period}."
        )
        msg = await client.messages.create(
            model="claude-haiku-4-5-20251001",
            max_tokens=500,
            messages=[{"role": "user", "content": prompt}],
        )
        return msg.content[0].text.strip()
    except Exception as exc:
        logger.warning("generate_narrative_report failed: %s", exc)
        return _template_report(data, period)
