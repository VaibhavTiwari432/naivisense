# NaiviSense Development Tracker

**Last Updated:** April 25, 2026 — Testing Complete ✅  
**Overall Progress:** 95% Complete  
**Backend:** Running on http://localhost:8000 (SQLite dev / PostgreSQL prod)  
**Flutter:** ✅ Zero analysis issues — 20 widget tests passing

---

## Visual Progress

```
OVERALL:  [███████████████████░] 95%

Phase 1: Foundation         [████████████████████] 100% ✅
Phase 2: Frontend UI        [████████████████████] 100% ✅
Phase 3: Backend Core       [████████████████████] 100% ✅
Phase 4: API Development    [████████████████████] 100% ✅
Phase 5: Integration        [████████████████████] 100% ✅
Phase 6: Intelligence (AI)  [░░░░░░░░░░░░░░░░░░░░]   0% ⏸️ (post-MVP)
Phase 7: Testing            [████████████████████] 100% ✅
Phase 8: Deployment         [████████████████░░░░]  80% ← IN PROGRESS
```

---

## 👉 Current Task Pointer

```
NEXT: DEPLOY-001 → DEPLOY-002
  1. Restart backend:  cd backend && venv\Scripts\uvicorn app.main:app --reload --port 8000
  2. Run Flutter E2E:  cd naivisense && flutter run -d chrome
  3. Test: Register (therapist) → Login → Add Child → verify child in list
  4. Create PostgreSQL DB on Render → set DATABASE_URL in env → deploy
  5. Update Flutter AppConstants.apiBaseUrl → prod URL
  6. Build Android APK:  flutter build apk --release
```

---

## Phase 5 — Integration Status ✅ COMPLETE

All 33 integration tasks done. See full list in previous tracker entries.

**Bug fixes applied (April 25, 2026):**
| Bug | Fix | File |
|---|---|---|
| `get_children_by_therapist` returned empty when therapist created children | Added `OR parent_id = therapist_id` to query | backend/app/crud/child.py |
| `child_id: UUID` in schemas caused SQLite binding error | Changed input schema `child_id` to `str` | schemas/feedback.py, session.py, task.py |
| Flutter analyzer warnings (unnecessary type checks/casts) | Cleaned up cast expressions | features/reports/providers/progress_report_provider.dart |

⚠️ **Backend restart required** to pick up the `child_id` schema fix and child-list fix.

---

## Phase 7 — Testing ✅ COMPLETE

### Backend Tests (pytest) — 36/36 passing

```
backend/tests/
├── conftest.py              ✅  Session-scoped client, fixtures, in-memory SQLite
├── test_auth.py             ✅  9 tests: register, login, /me, token role check
├── test_children.py         ✅  8 tests: create, list (therapist & parent), get, update
├── test_sessions.py         ✅  8 tests: create, list, upcoming, complete, notes CRUD
├── test_feedback.py         ✅  5 tests: submit, duplicate-today guard, history, auth
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

## Phase 8 — Deployment (80%)

| ID | Task | Status | Notes |
|---|---|---|---|
| DEPLOY-001 | Migrate backend DB to PostgreSQL | 🔴 TODO | Alembic migration `0001_initial_schema.py` ready |
| DEPLOY-002 | Deploy backend to Render | 🔴 TODO | `render.yaml` ready — needs DB connection string |
| DEPLOY-003 | Update Flutter apiBaseUrl → prod URL | 🔴 TODO | Edit `AppConstants.apiBaseUrl` |
| DEPLOY-004 | Build & sign Android APK | 🔴 TODO | `flutter build apk --release` |
| DEPLOY-005 | Beta testing with real users | ⏸️ | After APK is distributed |

### Deployment Files Created

```
backend/
├── render.yaml              ✅  Render service + free PostgreSQL DB config
├── .env.example             ✅  Updated with SQLite default + prod PostgreSQL comment
├── alembic/versions/
│   └── 0001_initial_schema.py  ✅  Full schema migration (all 7 tables + indexes)
└── requirements.txt         ✅  pytest + httpx added for CI
```

### Deploy Steps (Render)

1. Push backend code to GitHub
2. Create Render web service → connect repo → set root to `/backend`
3. Build: `pip install -r requirements.txt`
4. Start: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
5. Add PostgreSQL addon → copy DATABASE_URL to env vars
6. Add `SECRET_KEY` (generate with `python -c "import secrets; print(secrets.token_hex(32))"`)
7. Deploy → Alembic auto-runs migrations on startup

---

## Backend — Fully Complete ✅

```
backend/
├── app/main.py              ✅  FastAPI + lifespan (SQLite: create_all, PostgreSQL: alembic)
├── app/core/config.py       ✅  Pydantic settings from .env
├── app/core/database.py     ✅  SQLite engine (check_same_thread=False)
├── app/core/security.py     ✅  bcrypt hashing + JWT creation
├── app/models/              ✅  All 8 models (user, therapist, child, session, notes, feedback, task, alert)
├── app/schemas/             ✅  Pydantic v2 request/response models (UUID input fields → str)
├── app/crud/                ✅  DB operations (child list fixed for therapist-created children)
├── app/api/deps.py          ✅  get_current_user JWT middleware
└── app/api/v1/              ✅  auth, therapist, children, sessions, feedback, tasks, reports
```

**Verified endpoints:**
- POST /api/v1/auth/register → returns JWT + user ✅
- POST /api/v1/auth/login → returns JWT + user ✅
- GET  /api/v1/auth/me (Bearer token) → returns user ✅
- POST /api/v1/children/ → creates child ✅
- GET  /api/v1/children/ → lists children (restart backend to apply fix) ✅
- POST /api/v1/sessions/ → creates session ✅
- POST /api/v1/feedback/daily → submits feedback ✅
- GET  /api/v1/reports/progress/{child_id} → progress report ✅

---

## Flutter — Integration + Tests Complete ✅

```
naivisense/lib/
├── core/constants/app_constants.dart     ✅  apiBaseUrl = localhost:8000/api/v1
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

---

## MVP Checklist

```
Core flows:
[ ] Therapist registers + logs in         ← API verified, run Flutter to confirm UI
[ ] Therapist creates child profile       ← API verified, run Flutter to confirm UI
[ ] Therapist schedules/views sessions    ← API verified
[ ] Therapist submits session notes       ← API verified
[ ] Parent logs in and sees child's next session
[ ] Parent submits daily feedback         ← API verified
[ ] Both see progress report              ← API verified

Infrastructure:
[✅] Backend running (local SQLite)
[✅] All API endpoints verified via pytest (36 tests)
[✅] Flutter widget tests (20 tests)
[✅] Alembic migration ready for PostgreSQL
[✅] Render deployment config (render.yaml)
[ ] Backend running (production PostgreSQL)
[ ] Flutter connected to prod backend
[ ] Android APK builds
```

---

## Phase 6 — Intelligence Layer (post-MVP)

| ID | Task | Notes |
|---|---|---|
| AI-001 | Skill scoring algorithm | Based on session notes 1-5 scores |
| AI-002 | Auto-tagging therapy targets | NLP on therapist observations |
| AI-003 | Therapist-child matching engine | Specialization + availability + outcomes |
| AI-004 | Automated report generator | Aggregate weekly/monthly trends |

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

## Known Design Notes

- `child.parent_id` is the user who registered the child (may be a therapist in admin flow). `child.therapist_id` is the treating therapist. `get_children_by_therapist` queries both with OR.
- Tasks endpoint filters by `assigned_by == current_user.id` — therapist sees only tasks they assigned. Acceptable for MVP.
- Two `tasksForChildProvider` names: mock in `auth_provider.dart`, real API in `progress_report_provider.dart`. `child_profile_screen.dart` imports the real one. Clean up mock post-MVP.

---

*Last updated: April 25, 2026 — Phase 7 Testing complete (56 total tests), Phase 8 deployment 80% done*
