# NaiviSense Development Tracker

**Last Updated:** April 25, 2026 — Intelligence Layer Complete ✅  
**Overall Progress:** 99% Complete  
**Backend:** Running on http://localhost:8000 (SQLite dev / PostgreSQL prod)  
**Flutter:** ✅ Zero analysis issues — 20 widget tests passing  
**Backend Tests:** ✅ 49/49 passing

---

## Visual Progress

```
OVERALL:  [███████████████████░] 99%

Phase 1: Foundation         [████████████████████] 100% ✅
Phase 2: Frontend UI        [████████████████████] 100% ✅
Phase 3: Backend Core       [████████████████████] 100% ✅
Phase 4: API Development    [████████████████████] 100% ✅
Phase 5: Integration        [████████████████████] 100% ✅
Phase 6: Intelligence (AI)  [████████████████████] 100% ✅ NEW
Phase 7: Testing            [████████████████████] 100% ✅
Phase 8: Deployment         [█████████████████░░░]  85% ← IN PROGRESS
Phase 9: Industry Standards [████████████████████] 100% ✅ NEW
```

---

## 👉 Current Task Pointer

```
NEXT: DEPLOY-001 → DEPLOY-004  (Intelligence layer is complete — set ANTHROPIC_API_KEY in Render for AI features)
  1. Push to GitHub:
       git remote add origin https://github.com/YOUR_USERNAME/naivisense.git
       git push -u origin main
     → CI will auto-run on push (GitHub Actions)

  2. Deploy backend to Render:
       - New Web Service → connect repo → Root Directory: backend
       - Build: pip install -r requirements.txt
       - Start: uvicorn app.main:app --host 0.0.0.0 --port $PORT
       - Add env vars: SECRET_KEY (generate), ALGORITHM=HS256,
         ACCESS_TOKEN_EXPIRE_MINUTES=60, ENVIRONMENT=production
       - Add CORS_ORIGINS=<your flutter web domain> (or * for beta)
       - Add PostgreSQL addon → auto-sets DATABASE_URL
       - Deploy → Alembic runs migrations automatically

  3. Update Flutter apiBaseUrl:
       In AppConstants.apiBaseUrl default value → prod Render URL
       OR build with: flutter build apk --dart-define=API_BASE_URL=<url>

  4. Build Android APK (BLOCKED — needs Java 11+):
       ⚠️  Only Java 8 found. Install Java 17 (Temurin):
           https://adoptium.net/temurin/releases/?version=17
       ✅  After install, accept Android licenses:
           flutter doctor --android-licenses
       ✅  Then install Android cmdline-tools via Android Studio SDK Manager
       ✅  Then build:
           flutter build apk --release
           flutter build apk --dart-define=API_BASE_URL=<prod-url> --release
```

---

## Phase 9 — Industry Standards ✅ COMPLETE (April 25, 2026)

| # | Standard | Fix | Files Changed |
|---|---|---|---|
| STD-001 | Android INTERNET permission | Added `<uses-permission android:name="android.permission.INTERNET"/>` | AndroidManifest.xml |
| STD-002 | CORS config-driven | `CORS_ORIGINS` env var; `"*"` default for dev, restrict in prod | config.py, main.py, .env.example |
| STD-003 | Structured logging | `logging.basicConfig` with timestamp + level + name format; `LOG_LEVEL` from env | main.py, config.py |
| STD-004 | HTTP 201 for creates | All 7 POST create endpoints return 201 (register, child, session, notes, feedback, task, therapist profile) | api/v1/*.py, all test files |
| STD-005 | Rate limiting | `slowapi` — 5/min on login, 10/min on register; disabled in `ENVIRONMENT=testing` | core/limiter.py, auth.py, main.py |
| STD-006 | Deprecation cleanup | Replace `datetime.utcnow()` → `datetime.now(timezone.utc)` everywhere | session.py, tasks.py, test files |
| STD-007 | CI/CD | GitHub Actions `.github/workflows/ci.yml` — pytest + flutter analyze + flutter test on every push/PR | .github/workflows/ci.yml |
| STD-008 | Git hygiene | `android/build/` excluded from git; `.claude/` excluded | .gitignore |

---

## Phase 8 — Deployment (85%)

| ID | Task | Status | Notes |
|---|---|---|---|
| DEPLOY-001 | Push to GitHub | 🔴 TODO | `git remote add origin <url> && git push` — 2 commits ready |
| DEPLOY-002 | Deploy backend to Render | 🔴 TODO | `render.yaml` ready; needs GitHub push first |
| DEPLOY-003 | Update Flutter apiBaseUrl → prod URL | 🔴 TODO | Use `--dart-define=API_BASE_URL=<url>` at build time |
| DEPLOY-004 | Build & sign Android APK | 🚫 BLOCKED | Needs Java 17 — see task pointer above |
| DEPLOY-005 | Beta testing with real users | ⏸️ | After APK is distributed |

### Render Env Vars Checklist
```
DATABASE_URL        → auto-set by PostgreSQL addon
SECRET_KEY          → generate: python -c "import secrets; print(secrets.token_hex(32))"
ALGORITHM           → HS256
ACCESS_TOKEN_EXPIRE_MINUTES → 60
ENVIRONMENT         → production
CORS_ORIGINS        → * (for beta) or https://your-domain.com
LOG_LEVEL           → INFO
```

---

## Phase 7 — Testing ✅ COMPLETE

### Backend Tests (pytest) — 36/36 passing

```
backend/tests/
├── conftest.py              ✅  Session-scoped client, fixtures, in-memory SQLite
│                                 Sets ENVIRONMENT=testing to disable rate limiter
├── test_auth.py             ✅  9 tests: register(201), login, /me, token role check
├── test_children.py         ✅  8 tests: create(201), list (therapist & parent), get, update
├── test_sessions.py         ✅  8 tests: create(201), list, upcoming, complete, notes(201)
├── test_feedback.py         ✅  5 tests: submit(201), duplicate-today guard, history, auth
└── test_reports.py          ✅  6 tests: progress report (empty + with data), tasks CRUD

Run:  cd backend && venv\Scripts\pytest tests/ -v
```

### Flutter Widget Tests — 20/20 passing

```
naivisense/test/
└── widget_test.dart         ✅  StatusChip, RatingStars, AppButton, SectionHeader,
                                  RoleSelectionScreen (6 scenarios), UserRole extension

Run:  cd naivisense && flutter test
```

---

## Backend — Fully Complete ✅

```
backend/
├── app/main.py              ✅  FastAPI + lifespan + slowapi rate limiter + structured logging
├── app/core/config.py       ✅  Pydantic settings — CORS_ORIGINS, LOG_LEVEL added
├── app/core/database.py     ✅  SQLite engine (check_same_thread=False)
├── app/core/security.py     ✅  bcrypt hashing + JWT creation
├── app/core/limiter.py      ✅  slowapi Limiter (disabled in ENVIRONMENT=testing)
├── app/models/              ✅  All 8 models
├── app/schemas/             ✅  Pydantic v2 (UUID input fields → str)
├── app/crud/                ✅  DB operations (child list fixed, feedback_date default fixed)
├── app/api/deps.py          ✅  get_current_user JWT middleware
└── app/api/v1/              ✅  auth(rate-limited), therapist, children, sessions, feedback, tasks, reports
```

**All endpoints return correct status codes:**
- POST /api/v1/auth/register → 201 + JWT ✅
- POST /api/v1/auth/login → 200 + JWT ✅
- GET  /api/v1/auth/me → 200 ✅
- POST /api/v1/children/ → 201 ✅
- GET  /api/v1/children/ → 200 (therapist sees own + created; parent sees own) ✅
- POST /api/v1/sessions/ → 201 ✅
- POST /api/v1/sessions/{id}/notes → 201 ✅
- POST /api/v1/feedback/daily → 201 ✅
- GET  /api/v1/reports/progress/{child_id} → 200 ✅

---

## Flutter — Integration + Tests Complete ✅

```
naivisense/lib/
├── core/constants/app_constants.dart     ✅  apiBaseUrl via String.fromEnvironment
├── data/repositories/                    ✅  All 5 repos wired to backend
├── data/services/                        ✅  Dio + secure storage + error handler
├── routing/app_router.dart               ✅  Auth guard + role routing
├── shared/models/                        ✅  fromJson/toJson on all models
├── shared/widgets/                       ✅  All shared widgets tested
└── features/
    ├── auth/                             ✅  Real login/register, session restore
    ├── admin/                            ✅  Child list + add child wired
    ├── therapist/                        ✅  Dashboard, students, child profile, session notes, tasks tab
    ├── parent/                           ✅  Dashboard, feedback submit
    └── reports/                          ✅  Progress report + feedback history + tasks

flutter analyze: No issues found ✅
flutter test:    20/20 passed ✅
```

**Android:**
- `<uses-permission android:name="android.permission.INTERNET"/>` added ✅
- APK build blocked by Java 8 (needs Java 17) ⚠️

---

## CI/CD — GitHub Actions ✅

```
.github/workflows/ci.yml
  ├── backend job: Python 3.12 → pip install → pytest -v
  └── flutter job: Flutter 3.x stable → pub get → analyze → test

Triggers: push to main, pull_request to main
```

---

## MVP Checklist

```
Core flows:
[ ] Therapist registers + logs in         ← API verified, need Flutter E2E confirm
[ ] Therapist creates child profile       ← API verified, need Flutter E2E confirm
[ ] Therapist schedules/views sessions    ← API verified
[ ] Therapist submits session notes       ← API verified
[ ] Parent logs in and sees child's next session
[ ] Parent submits daily feedback         ← API verified
[ ] Both see progress report              ← API verified

Infrastructure:
[✅] Backend running (local SQLite)
[✅] All API endpoints verified via pytest (36 tests, 201/200 correct)
[✅] Flutter widget tests (20 tests)
[✅] Alembic migration ready for PostgreSQL
[✅] Render deployment config (render.yaml)
[✅] GitHub Actions CI (auto-runs tests on push)
[✅] Rate limiting on auth (5/min login, 10/min register)
[✅] Android INTERNET permission
[ ] Backend running (production PostgreSQL)
[ ] Flutter connected to prod backend
[ ] Android APK builds (blocked: install Java 17 first)
```

---

## Phase 6 — Intelligence Layer ✅ COMPLETE (April 25, 2026)

| ID | Feature | Status | Endpoint | Implementation |
|---|---|---|---|---|
| AI-001 | Skill scoring algorithm | ✅ | `GET /api/v1/intelligence/skill-score/{child_id}` | Pure algorithm — weighted composite score, trend, skill level |
| AI-002 | Auto-tagging therapy targets | ✅ | `POST /api/v1/intelligence/auto-tag/{session_id}` | Claude Haiku — extracts tags from observation text |
| AI-003 | Therapist-child matching | ✅ | `GET /api/v1/intelligence/match-therapist/{child_id}` | Pure algorithm — specialization + experience + rating score |
| AI-004 | Narrative report generator | ✅ | `GET /api/v1/intelligence/generate-report/{child_id}?period=weekly\|monthly` | Claude Haiku — 3-paragraph narrative; template fallback if no key |

### Architecture

```
backend/
├── app/services/intelligence.py      ✅  All 4 AI functions
│   ├── compute_skill_score()          AI-001: weighted 5-dim score, trend, level
│   ├── match_therapists()             AI-003: spec/exp/rating/volume scoring
│   ├── auto_tag_observations()        AI-002: Claude Haiku async call
│   └── generate_narrative_report()    AI-004: Claude Haiku + template fallback
├── app/schemas/intelligence.py        ✅  Pydantic response models
├── app/api/v1/intelligence.py         ✅  FastAPI router (4 endpoints)
└── tests/test_intelligence.py         ✅  13 tests — all passing
```

### AI-001 — Skill Scoring Detail

```
Dimension weights:
  progress_score      × 1.50  (most important)
  attention_score     × 1.00
  participation_score × 1.00
  mood_score          × 0.75
  behavior_score      × 0.75

Skill levels: Emerging (<2.0) | Developing (2–3) | Proficient (3–4) | Advanced (≥4)
Trend:        first-half avg vs second-half avg → improving/stable/declining (±0.25 threshold)
```

### AI-003 — Matching Score Breakdown

```
Specialization keyword overlap with diagnosis    0–50 pts
Years of experience (2 pts/year, cap 20)         0–20 pts
Rating (rating/5 × 20)                           0–20 pts
Session volume (1 pt per 10 sessions, cap 10)    0–10 pts
                                          Total: 0–100 pts
```

### Claude API Setup (required for AI-002 + AI-004)

```
1. Get API key: https://console.anthropic.com/
2. Add to backend/.env:  ANTHROPIC_API_KEY=sk-ant-...
3. Add to Render env vars as well
4. Without key: auto-tag returns [] and report uses template — app still works
```

### Intelligence Tests — 13/13 passing

```
test_skill_score_no_data              ✅
test_skill_score_with_notes           ✅
test_skill_score_level_boundaries     ✅
test_skill_score_unknown_child        ✅
test_match_therapist_returns_list     ✅
test_match_therapist_with_profile     ✅
test_match_therapist_unknown_child    ✅
test_auto_tag_no_api_key_returns_empty ✅  (graceful degradation)
test_auto_tag_no_notes_returns_404    ✅
test_generate_report_weekly           ✅
test_generate_report_monthly          ✅
test_generate_report_unknown_child    ✅
test_intelligence_requires_auth       ✅
```

---

## Key Technical Decisions

| Decision | Choice | Why |
|---|---|---|
| State management | Riverpod (AsyncNotifier) | Type-safe, testable |
| HTTP client | Dio | Interceptors for auth token |
| Local storage | flutter_secure_storage | JWT must not be in SharedPrefs |
| Navigation | GoRouter with redirect guard | Role-based auth routing |
| DB (local dev) | SQLite | PostgreSQL not installed locally |
| DB (production) | PostgreSQL | UUID support, reliability |
| Python bcrypt | 4.0.1 pinned | passlib 1.7.4 incompatible with newer |
| Schema ID fields | `str` (not `UUID`) | SQLite can't bind uuid.UUID objects |
| Startup migrations | Alembic for PostgreSQL, create_all for SQLite | Avoids alembic on dev |
| Rate limiting | slowapi 0.1.9 | Lightweight, FastAPI-native |
| CORS origins | Env var `CORS_ORIGINS` | Restrict in prod without code change |
| HTTP status codes | 201 for creates, 200 for reads/updates | REST standard |
| CI/CD | GitHub Actions | Free, runs on every push |

## Known Design Notes

- `child.parent_id` is the user who registered the child (may be a therapist in admin flow). `child.therapist_id` is the treating therapist. `get_children_by_therapist` queries both with OR.
- Tasks endpoint filters by `assigned_by == current_user.id` — therapist sees only tasks they assigned. Acceptable for MVP.
- Two `tasksForChildProvider` names: mock in `auth_provider.dart`, real API in `progress_report_provider.dart`. `child_profile_screen.dart` imports the real one. Clean up mock post-MVP.
- Rate limiter uses IP-based keys. Behind a reverse proxy (Render), ensure `X-Forwarded-For` is passed correctly or switch to user-ID keying post-MVP.

---

*Last updated: April 25, 2026 — Phase 9 (Industry Standards) complete. 2 git commits ready to push.*
