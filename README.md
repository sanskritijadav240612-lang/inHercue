# inHERcue / HerSignal

> **Comprehensive Women's Healthcare & Wellness Platform**
> *Full-stack Flutter & Node.js application featuring personalized health tracking, clinical safety triage, and private health records.*

---

## Overview

**inHERcue (HerSignal)** is a full-stack women's healthcare and wellness application designed to support women through personalized cycle tracking, daily physical and mental symptom monitoring, context-aware lifestyle guidance, evidence-backed education, and deterministic clinical safety triage.

The project features a responsive **Flutter** frontend mirroring the Figma design system, connected to a **Node.js/Express** backend backed by **MongoDB**.

> **Project Status:**  
> The core integration between the Flutter frontend and the Express/MongoDB backend is **fully implemented and verified**. This includes user authentication, onboarding, Health Passport persistence, Daily Check-in logging, deterministic safety triage evaluations, and verified regional emergency helplines.

---

## System Architecture & Tech Stack

```
┌────────────────────────────────────────────────────────┐
│               Flutter Frontend (Web/Mobile)            │
│  - Presentation Layer: 17 Figma-Faithful Screens       │
│  - State Management: AuthState (ChangeNotifier)        │
│  - Network & Client: ApiClient (Typed Exceptions, JWT) │
│  - Session Storage: Platform-Adaptive (Web & Io Cache) │
└───────────────────────────┬────────────────────────────┘
                            │ HTTP / JSON REST (/api/v1)
                            ▼
┌────────────────────────────────────────────────────────┐
│               Node.js & Express REST API               │
│  - Middleware: Bearer Auth, Rate Limiting, Safe CORS   │
│  - Controllers: Auth, Passport, Symptom, Safety        │
│  - Service Layer: Deterministic Clinical Safety Triage │
└───────────────────────────┬────────────────────────────┘
                            │ Mongoose ODM
                            ▼
┌────────────────────────────────────────────────────────┐
│                  MongoDB Database                      │
│  - Collections: users, healthpassports, symptomlogs    │
│  - Indexes: Unique email, composite { userId, date }   │
└────────────────────────────────────────────────────────┘
```

### Technology Components
- **Frontend:** [Flutter](https://flutter.dev) (Dart 3.13.5+) targeting Web (`build/web`), Desktop, and Mobile.
  - Dependencies: `http`, `google_fonts`, `cupertino_icons`.
  - Architecture: Layered Clean Architecture (`lib/core/`, `lib/data/`, `lib/screens/`, `lib/state/`, `lib/widgets/`).
- **Backend Server:** [Node.js](https://nodejs.org) (v20+) with [Express.js](https://expressjs.com) (v4.22+).
  - Security & Utilities: `jsonwebtoken`, `bcryptjs` (12 rounds), `cors`, `dotenv`, `express-rate-limit`.
- **Database:** [MongoDB](https://www.mongodb.com/) with [Mongoose](https://mongoosejs.com/) ODM (v8.13+).
- **Automated Testing:** `node:test` + `supertest` for backend API; `flutter_test` for frontend widget, model, and service suites.

---

## Feature Matrix: Working vs. Client-Side Modules

To ensure transparency, the table below clearly distinguishes **working backend-connected features** from **client-side / interactive demo screens**:

| Feature / Screen | Route | Implementation Level | Data Persistence / Backend Integration |
| :--- | :--- | :--- | :--- |
| **User Registration** | `/auth` | **Working Backend Integration** | Validates credentials, hashes password (bcrypt), persists to MongoDB `users` collection. |
| **User Authentication** | `/auth` | **Working Backend Integration** | Issues signed JWT; validates Bearer token via `GET /api/v1/auth/me`; auto-hydrates session. |
| **Profile Setup / Onboarding** | `/profile-setup` | **Working Backend Integration** | Pre-loads profile, saves focus/cycle via `PUT /api/v1/passport`, sets `onboardingCompleted: true`. |
| **Health Passport** | `/passport` | **Working Backend Integration** | Persists conditions, allergies, medications, and emergency contacts to MongoDB `healthpassports`. |
| **Daily Symptom Check-in** | `/checkin` | **Working Backend Integration** | Multiselect symptoms, severity, flow, pain, hydration, mood logged to MongoDB `symptomlogs`. |
| **Clinical Safety Triage** | `/urgent` | **Working Backend Integration** | Deterministic rule-based evaluation via `POST /api/v1/safety/triage`; embeds red flags. |
| **Home Dashboard** | `/home` | **Working Backend Integration** | Hydrates latest check-in badge and passport focus from API; falls back to demo mode for guests. |
| **Regional Helplines** | `/urgent` | **Working Client Configuration** | Configurable, verified hotlines for India (112, 14416 Tele-MANAS), US/CA (911, 988), and UK (999, 111). |
| **Period Tracker** | `/period` | *Client-Side Demo* | Interactive 4-phase cycle calculator computed from standard 28-day baseline; not dynamically tied to history. |
| **Mental Wellness** | `/mental` | *Client-Side Demo* | Interactive reflection diary with pre-canned prompt responses; operates in local widget state. |
| **Self-Care Studio** | `/selfcare` | *Client-Side Interactive* | Interactive 4-7-8 breathing timer and activity checklist; runs client-side. |
| **Symptom Tracker History** | `/symptoms` | *Client-Side Demo* | Displays sample baseline cards; `SymptomApiService.getHistory()` is implemented for API consumption. |
| **Find a Doctor** | `/doctors` | *Mocked Sample Directory* | Clinician cards rendered from static sample data; no real-time provider discovery API exists. |
| **Community Feed** | `/community` | *Mocked Sample Forum* | Interactive demonstration of topics and bookmarking using in-memory sample posts. |
| **Health Reports Preview** | `/reports` | *Mocked On-Screen Preview* | Generates on-screen report layout preview; does not export real PDF/CSV files from the server. |
| **Myth vs Fact Quiz** | `/myths` | *Static Educational Content* | 7 evidence-backed categories with instant answer reveals and source citations. |

---

## Local Setup & Development Instructions

### Prerequisites
- **Node.js** (v20.x or higher) & **npm** (v10.x or higher)
- **MongoDB** running locally on port `27017` (e.g. `mongodb://127.0.0.1:27017/hersignal_dev`) or a remote MongoDB connection string
- **Flutter SDK** (v3.13.5+ stable channel) with Chrome installed

---

### 1. Backend Setup

1. Open a terminal in the `backend/` directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm ci
   ```

3. Configure environment variables using the provided template:
   ```bash
   # On Windows (Command Prompt / PowerShell):
   copy .env.example .env

   # On macOS / Linux:
   cp .env.example .env
   ```

4. Inspect `backend/.env` and update the connection values if necessary:
   * `PORT=5000` (default backend port)
   * `NODE_ENV=development`
   * `MONGODB_URI=mongodb://127.0.0.1:27017/hersignal_dev`
   * `TEST_MONGODB_URI=mongodb://127.0.0.1:27017/hersignal_test`
   * `JWT_SECRET=your_development_jwt_secret_placeholder_do_not_use_in_prod`
   * `CORS_ORIGIN=*` (or `http://localhost:port` for restricted origins)
   > **Security Notice:** Never print, copy, or commit real secrets, database passwords, or `.env` files to Git. The `.gitignore` file is configured to strictly exclude `.env`.

5. Start the backend development server:
   ```bash
   npm run dev
   # Alternatively: npm start
   ```

6. Verify that the server is operational:
   * **Health Check URL:** [http://localhost:5000/api/v1/health](http://localhost:5000/api/v1/health)
   * Expected response:
     ```json
     {
       "success": true,
       "message": "HerSignal API is operational",
       "data": {
         "service": "HerSignal API",
         "status": "healthy"
       }
     }
     ```

---

### 2. Frontend Setup (Flutter)

1. Open a new terminal in the `frontend/` directory:
   ```bash
   cd frontend
   ```

2. Install Flutter package dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application in Google Chrome:
   ```bash
   flutter run -d chrome
   ```

   * *Note on API connectivity:* By default, the web client communicates with `http://localhost:5000/api/v1`. To point to a custom server port or remote deployment, provide `--dart-define`:
     ```bash
     flutter run -d chrome --dart-define=API_URL=http://localhost:5000/api/v1
     ```

---

## Testing & Quality Assurance

The codebase includes comprehensive automated test suites for both backend and frontend layers:

### Running Backend Tests
From the `backend/` directory:
```bash
npm test
```
* Runs all 46 native Node.js tests (`node:test` + `supertest`) covering authentication, Health Passport CRUD, symptom check-in isolation, deterministic safety triage, rate limiting, and CORS security.

### Running Flutter Tests
From the `frontend/` directory:
```bash
flutter test
```
* Runs all 86 Flutter unit, model, service, and widget tests across 11 test suites.

### Running Static Code Analysis
From the `frontend/` directory:
```bash
flutter analyze
```
* Validates Dart code against lint rules defined in `analysis_options.yaml` (0 warnings, 0 errors).

### Compiling Web Production Bundle
From the `frontend/` directory:
```bash
flutter build web
```
* Compiles the release web bundle to `frontend/build/web/` for deployment.

---

## Clinical Safety & Medical Disclaimer

> ### IMPORTANT CLINICAL NOTICE
> **inHERcue / HerSignal is an educational tracking and self-monitoring prototype. It does NOT provide medical diagnoses, clinical treatment, or prescriptions.**
>
> - **Never Delay Urgent Care:** If you or someone you know is experiencing severe acute bleeding, sudden unmanageable pelvic pain, high fever with pelvic tenderness, or signs of shock, seek emergency medical care immediately.
> - **Pre-Clinical Status:** The symptom thresholds and triage rules implemented in this repository are prototype representations created for demonstration. **Before this system can be deployed for clinical use with real human patients, all safety rules, symptom thresholds, and guidance copy must undergo formal clinical review and sign-off by a licensed, board-certified Obstetrician/Gynecologist (OB/GYN).**

---

## Documentation Quick Links

Detailed technical and clinical specifications are available in the repository's `docs/` folder:

- [API Contract Specification](docs/api-contract.md) — Complete REST endpoint schemas, headers, request/response structures, and status codes.
- [System Architecture & Roadmap](docs/architecture.md) — Component architecture, state machines, and milestone breakdown.
- [Clinical Safety Guidelines](docs/safety-guidelines.md) — Explicit boolean logic for acute red-flag triage and crisis protocols.
- [Data Privacy & Security Specification](docs/data-privacy-spec.md) — Tenant isolation, encryption requirements, and data governance.

---

## License

This project is developed for educational and hackathon demonstration purposes.
