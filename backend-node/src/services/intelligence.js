const Anthropic = require('@anthropic-ai/sdk');

// AI-001: Skill Scoring
const WEIGHTS = {
  progress_score: 1.5,
  attention_score: 1.0,
  participation_score: 1.0,
  mood_score: 0.75,
  behavior_score: 0.75,
};

function weightedNoteScore(note) {
  let total = 0, wSum = 0;
  for (const [field, weight] of Object.entries(WEIGHTS)) {
    const val = note[field];
    if (val != null) {
      total += val * weight;
      wSum += weight;
    }
  }
  return wSum > 0 ? Math.round((total / wSum) * 1000) / 1000 : null;
}

function computeSkillScore(child, notes) {
  const sorted = [...notes].sort((a, b) => new Date(a.created_at) - new Date(b.created_at));
  const timeline = sorted.map(n => weightedNoteScore(n)).filter(s => s != null);

  if (!timeline.length) {
    return {
      composite_score: null,
      skill_level: null,
      trend: null,
      dimension_scores: Object.fromEntries(Object.keys(WEIGHTS).map(k => [k, null])),
      sessions_analyzed: 0,
    };
  }

  const composite = Math.round((timeline.reduce((a, b) => a + b, 0) / timeline.length) * 100) / 100;

  let delta = 0;
  if (timeline.length >= 4) {
    const mid = Math.floor(timeline.length / 2);
    const firstHalf = timeline.slice(0, mid);
    const secondHalf = timeline.slice(mid);
    delta = secondHalf.reduce((a, b) => a + b, 0) / secondHalf.length
          - firstHalf.reduce((a, b) => a + b, 0) / firstHalf.length;
  } else if (timeline.length >= 2) {
    delta = timeline[timeline.length - 1] - timeline[0];
  }

  const trend = delta > 0.25 ? 'improving' : delta < -0.25 ? 'declining' : 'stable';
  const level = composite >= 4.0 ? 'Advanced'
    : composite >= 3.0 ? 'Proficient'
    : composite >= 2.0 ? 'Developing'
    : 'Emerging';

  const dim = {};
  for (const field of Object.keys(WEIGHTS)) {
    const vals = notes.map(n => n[field]).filter(v => v != null);
    dim[field] = vals.length ? Math.round((vals.reduce((a, b) => a + b, 0) / vals.length) * 100) / 100 : null;
  }

  return { composite_score: composite, skill_level: level, trend, dimension_scores: dim, sessions_analyzed: timeline.length };
}

// AI-003: Therapist Matching
function matchTherapists(child, profiles) {
  const diagKw = new Set((child.diagnosis || '').toLowerCase().split(/\s+/));
  const goalKw = new Set();
  for (const goal of (child.therapy_goals || [])) {
    for (const w of goal.toLowerCase().split(/\s+/)) goalKw.add(w);
  }

  const results = profiles.map(({ profile, user }) => {
    let score = 0;
    const reasons = [];

    if (profile.specialization) {
      const specKw = new Set(profile.specialization.toLowerCase().split(/\s+/));
      const diagIntersect = [...diagKw].filter(w => specKw.has(w)).length;
      const goalIntersect = [...goalKw].filter(w => specKw.has(w)).length;
      const pts = Math.min(50, diagIntersect * 15 + goalIntersect * 5);
      score += pts;
      if (pts > 0) reasons.push(`Specializes in ${profile.specialization}`);
    }

    const exp = profile.years_of_experience || 0;
    score += Math.min(20, exp * 2);
    if (exp > 0) reasons.push(`${exp} years of experience`);

    const rating = profile.rating || 0;
    score += Math.round((rating / 5.0) * 20);
    if (rating > 0) reasons.push(`Rated ${rating.toFixed(1)}/5.0`);

    score += Math.min(10, Math.floor((profile.total_sessions || 0) / 10));

    return {
      therapist_id: user.id,
      therapist_name: user.name,
      specialization: profile.specialization,
      years_of_experience: exp,
      rating,
      match_score: score,
      match_reasons: reasons.length ? reasons : ['Available therapist'],
    };
  });

  return results.sort((a, b) => b.match_score - a.match_score).slice(0, 5);
}

// AI-002: Auto-tag via Claude Haiku
async function autoTagObservations(text, apiKey) {
  if (!apiKey || !text.trim()) return [];
  try {
    const client = new Anthropic({ apiKey });
    const msg = await client.messages.create({
      model: 'claude-haiku-4-5-20251001',
      max_tokens: 150,
      messages: [{
        role: 'user',
        content: `You are a pediatric therapy assistant. Extract up to 5 concise therapy target tags from this therapist observation. Return ONLY a valid JSON array of short strings (2-4 words each). Example: ["Eye contact", "Verbal initiation", "Turn-taking"]\n\nObservation: "${text}"\n\nTags:`,
      }],
    });
    return JSON.parse(msg.content[0].text.trim());
  } catch (err) {
    console.warn('autoTagObservations failed:', err.message);
    return [];
  }
}

// AI-004: Narrative Report
function templateReport(data, period) {
  const goals = data.goals.length ? data.goals.join(', ') : 'various therapy targets';
  return `${data.child_name} had ${data.sessions_completed} session(s) this ${period}. Average progress score: ${data.avg_progress}/5. Goals worked on: ${goals}. Parent-reported mood: ${data.avg_feedback_mood}/5.`;
}

async function generateNarrativeReport(data, period, apiKey) {
  if (!apiKey) return templateReport(data, period);
  try {
    const client = new Anthropic({ apiKey });
    const prompt = `Write a warm, professional ${period} therapy progress report for parents and therapists.\n\nChild: ${data.child_name}\nSessions completed: ${data.sessions_completed}\nAverage progress score: ${data.avg_progress}/5\nStrongest area: ${data.strongest}\nArea needing attention: ${data.weakest}\nGoals worked on: ${data.goals.join(', ') || 'various goals'}\nParent-reported mood average: ${data.avg_feedback_mood}/5\nLatest therapist note: ${data.latest_note || 'N/A'}\n\nWrite exactly 3 short paragraphs: (1) overall ${period} summary, (2) specific achievements and focus areas, (3) recommendations for the coming ${period}.`;
    const msg = await client.messages.create({
      model: 'claude-haiku-4-5-20251001',
      max_tokens: 500,
      messages: [{ role: 'user', content: prompt }],
    });
    return msg.content[0].text.trim();
  } catch (err) {
    console.warn('generateNarrativeReport failed:', err.message);
    return templateReport(data, period);
  }
}

module.exports = { computeSkillScore, matchTherapists, autoTagObservations, generateNarrativeReport };
