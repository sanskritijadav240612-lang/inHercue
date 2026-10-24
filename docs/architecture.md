# HerSignal Architecture & Technical Specification

## 1. System Overview & Technology Stack

HerSignal is architected as a clean, decoupled full-stack application designed for reliability, fast iteration, and strong data boundaries:

```text
+-------------------------------------------------------+
|                 Mobile Client (Flutter)               |
|      - UI Screens & Navigation (Dart)                 |
|      - Local Secure Storage (Auth Tokens, Offline)    |
|      - Deterministic Client-side UI State             |
+-------------------------------------------------------+
                            │
               HTTPS / JSON API Boundary
                  (Bearer JWT Tokens)
                            │
                            ▼
+-------------------------------------------------------+
|                 Backend Server (Node.js)              |
|      - Express.js HTTP Application Server             |
|      - JWT Authentication & Authorization Guard       |
|      - Deterministic Safety Rules Engine              |
|      - Request Validation & Error Handling            |
+-------------------------------------------------------+
                            │
                   Mongoose ODM / TCP
                            │
                            ▼
+-------------------------------------------------------+
|                 Database (MongoDB)                    |
|      - Users & Credentials                            |
|      - Health Passports (Baseline Records)            |
|      - Daily Symptom & Mood Logs                      |
|      - Educational Resources & Myth Busters           |
+-------------------------------------------------------+
```

### 1.1 Technology Choices & Roles
1. **Frontend (Flutter & Dart):**
   - Cross-platform mobile client providing a responsive, fluid interface for Android and iOS.
   - Responsible for rendering cycle tracking, symptom input sliders, red-flag alert modals, and doctor summary visualizations.
   - Communicates with the backend exclusively via RESTful JSON over HTTP(S).
2. **Backend (Node.js & Express):**
   - Lightweight, event-driven web framework handling routing, business rules, token verification, and deterministic safety evaluation.
   - All endpoints are prefixed under `/api/v1`.
3. **Database (MongoDB & Mongoose):**
   - Flexible NoSQL document database ideal for evolving health records, varied symptom arrays, and user-configurable health passports.

---

## 2. Planned Repository Structure

All development takes place within the Git repository root (`inHercue/`):

```text
inHercue/
├── docs/                                  # Project documentation & contracts
│   ├── api-contract.md                    # Canonical API specifications
│   ├── architecture.md                    # This document
│   ├── safety-guidelines.md               # Clinical red-flags & emergency protocols
│   └── data-privacy-spec.md               # Sensitive health data storage rules
│
├── backend/                               # Node.js + Express + MongoDB
│   ├── src/
│   │   ├── config/                        # Database connection & environment configuration
│   │   ├── constants/                     # Safety rules, symptom taxonomy, static content
│   │   ├── controllers/                   # Route handlers (auth, passport, symptoms, etc.)
│   │   ├── middleware/                    # Auth token verification, input validation, error handling
│   │   ├── models/                        # Mongoose schemas (User, Passport, SymptomLog, etc.)
│   │   ├── routes/                        # Express routers matching the API contract
│   │   ├── services/                      # Deterministic safety triage & summary generation
│   │   └── app.js                         # Express application setup
│   ├── .env.example                       # Safe environment variable template
│   ├── package.json                       # Dependencies & npm scripts
│   └── server.js                          # HTTP server entry point
│
├── frontend/                              # Flutter mobile app
│   ├── lib/
│   │   ├── core/                          # API HTTP client, theme, route definitions
│   │   ├── models/                        # Dart data classes matching backend JSON schemas
│   │   ├── services/                      # API service classes (AuthService, SymptomService, etc.)
│   │   ├── screens/                       # App views (Onboarding, Passport, Symptoms, SOS, etc.)
│   │   ├── widgets/                       # Reusable UI components
│   │   └── main.dart                      # Flutter app entry point
│   ├── pubspec.yaml                       # Flutter dependencies
│   └── .gitignore                         # Flutter build ignores
│
├── .gitignore                             # Root gitignore
└── README.md                              # Main project overview
```

---

## 3. Recommended Implementation Sequence

To ensure stable progress during the hackathon, we follow a milestone-driven implementation sequence:

### Phase 1: Foundation & Contracts (Current Phase)
- Establish documentation, API contracts, safety rules, and gitignore.
- Align on data models and validation boundaries.

### Phase 2: Backend Core & Database
1. Initialize `backend/package.json` with Express, Mongoose, bcryptjs, jsonwebtoken, cors, and dotenv.
2. Establish MongoDB connection with fallback graceful degradation.
3. Implement `authMiddleware` and User Authentication (`/api/v1/auth/*`).
4. Implement Health Passport and Symptom Check-in endpoints (`/api/v1/passport`, `/api/v1/symptoms/*`).
5. Implement deterministic Safety Triage (`/api/v1/safety/triage`) with rule-based logic.

### Phase 3: Frontend Foundation & Core Screens
1. Initialize Flutter project in `frontend/`.
2. Configure basic theme, routing, and HTTP API client with secure token persistence.
3. Build Onboarding & Health Passport entry screen.
4. Build Daily Symptom & Mood logging screen.
5. Build Safety Alert UI modal (triggering immediate emergency banner when red-flags are detected).

### Phase 4: Educational Features & Doctor-Ready Summary
1. Seed educational resources and Myth-vs-Fact catalog (`/api/v1/education/*`).
2. Implement Doctor-Ready Health Summary generator (`/api/v1/reports/doctor-summary`).
3. Connect frontend view for Doctor Summary.

### Phase 5: Privacy Controls & Polish
1. Implement Data Export (`/api/v1/privacy/export`) and Account Deletion (`/api/v1/privacy/delete-account`).
2. Add end-to-end integration tests and clean documentation.

---

## 4. Resilience & Optional Integrations

In a hackathon setting, external integrations can fail, time out, or require unavailable API keys. The architecture strictly isolates essential features from optional integrations:

| Component / Integration | Criticality | Startup Behavior If Unavailable |
| :--- | :--- | :--- |
| **Node.js HTTP Server** | **Critical** | App cannot function without the backend server. |
| **MongoDB Connection** | **Core** | Server attempts connection; if offline, development mock mode or in-memory fallback can be utilized for testing without crashing. |
| **Deterministic Safety Rules** | **Critical** | Runs entirely in-memory using hardcoded rules; **never relies on external network calls or external AI APIs**. Always available. |
| **SMS / Push Notifications** | **Optional** | Must not block check-in. If notification services are unconfigured, logs a warning and proceeds normally. |
| **External AI / LLM APIs** | **Optional** | If an optional AI assistant is integrated later for general conversational education, it must be behind a feature flag. If unavailable, the app falls back to static reviewed educational content. |
| **PDF Generation for Summary** | **Optional** | Summary is returned first as clean JSON. Client-side rendering or backend PDF generator failure falls back gracefully to JSON display. |
