from typing import Optional
from pydantic import BaseModel


class DimensionScores(BaseModel):
    attention_score: Optional[float] = None
    participation_score: Optional[float] = None
    mood_score: Optional[float] = None
    progress_score: Optional[float] = None
    behavior_score: Optional[float] = None


class SkillScoreResponse(BaseModel):
    child_id: str
    child_name: str
    composite_score: Optional[float] = None
    skill_level: Optional[str] = None        # Emerging / Developing / Proficient / Advanced
    trend: Optional[str] = None              # improving / stable / declining
    dimension_scores: DimensionScores
    sessions_analyzed: int


class TherapistMatch(BaseModel):
    therapist_id: str
    therapist_name: str
    specialization: Optional[str] = None
    years_of_experience: int
    rating: float
    match_score: int
    match_reasons: list[str]


class MatchingResponse(BaseModel):
    child_id: str
    child_name: str
    diagnosis: Optional[str] = None
    therapy_goals: list[str]
    matches: list[TherapistMatch]


class AutoTagResponse(BaseModel):
    session_id: str
    tags: list[str]


class NarrativeReportResponse(BaseModel):
    child_id: str
    child_name: str
    period: str
    narrative: str
