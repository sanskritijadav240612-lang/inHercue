# HerSignal API Contract & Specification

> **Status Notice:**
> **IMPLEMENTED ENDPOINTS:**
> - `GET /api/v1/health` (Service health check)
> - `POST /api/v1/auth/register` (User registration)
> - `POST /api/v1/auth/login` (User login)
> - `GET /api/v1/auth/me` (Authenticated current user profile)
>
> **ALL OTHER MODULES (Modules 2 through 9) REMAIN PROPOSED / NOT IMPLEMENTED.**
> None of the clinical or safety guidance content in those proposals has been clinically reviewed or validated.

---

## 1. Global API Conventions

- **Base URL Prefix:** `/api/v1`
- **Data Format:** All request and response bodies use `application/json` (UTF-8 encoding).
- **Authentication Scheme:** JSON Web Token (JWT) transmitted via HTTP header:
  ```http
  Authorization: Bearer <jwt_token>
  ```
- **Tenant & Privacy Boundary:** Every authenticated request is tied strictly to the authenticated user's `userId` extracted from the verified JWT. **A user can only access, view, modify, export, or delete their own private health records.** Cross-user data access is strictly forbidden.
- **Example Data:** All names, emails, phone numbers, and clinical metrics in this document are entirely fictional.

---

## 2. Standard Response Envelopes

### 2.1 Standard Success Envelope
All successful responses (HTTP 200, 201) adhere to this schema:

```json
{
  "success": true,
  "message": "Human-readable summary of the completed operation",
  "data": {}
}
```

### 2.2 Standard Error Envelope
All error responses (HTTP 400, 401, 403, 404, 422, 500) adhere to this schema:

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR | UNAUTHORIZED | FORBIDDEN | NOT_FOUND | RATE_LIMIT_EXCEEDED | INTERNAL_ERROR",
    "message": "User-friendly description of the error",
    "details": [
      {
        "field": "password",
        "issue": "Password must be at least 8 characters with at least one number and special character"
      }
    ]
  }
}
```

---

## 3. Endpoints by Module

---

### Foundation: Health Check

#### 0.1 Service Health Check
- **Status:** `[IMPLEMENTED]`
- **Method & Path:** `GET /api/v1/health`
- **Access Level:** Public
- **Description:** Returns service operational status and database readiness without leaking credentials.

---

### Module 1: Authentication & Onboarding

#### 1.1 Register New User
- **Status:** `[IMPLEMENTED]`
- **Method & Path:** `POST /api/v1/auth/register`
- **Access Level:** Public
- **Description:** Registers a new user account with hashed password and initial profile.
- **Validation Rules:**
  - `email`: Required, valid email format, unique.
  - `password`: Required, minimum 8 characters, must contain at least 1 number and 1 special symbol.
  - `name`: Required, string, 2–60 characters.
  - `age`: Optional, integer between 13 and 120.
- **Request Example:**
  ```json
  {
    "email": "priya.sharma.sample@example.com",
    "password": "StrongPassword99!",
    "name": "Priya Sharma",
    "age": 23
  }
  ```
- **Response Example (`201 Created`):**
  ```json
  {
    "success": true,
    "message": "Account created successfully",
    "data": {
      "userId": "671a9101f82c4a001a111111",
      "email": "priya.sharma.sample@example.com",
      "name": "Priya Sharma",
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.fictionalTokenString",
      "onboardingCompleted": false
    }
  }
  ```
- **Error Codes:** `400 Bad Request` (duplicate email), `422 Unprocessable Entity` (validation failure).

#### 1.2 User Login
- **Status:** `[IMPLEMENTED]`
- **Method & Path:** `POST /api/v1/auth/login`
- **Access Level:** Public
- **Request Example:**
  ```json
  {
    "email": "priya.sharma.sample@example.com",
    "password": "StrongPassword99!"
  }
  ```
- **Response Example (`200 OK`):**
  ```json
  {
    "success": true,
    "message": "Login successful",
    "data": {
      "userId": "671a9101f82c4a001a111111",
      "email": "priya.sharma.sample@example.com",
      "name": "Priya Sharma",
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.fictionalTokenString",
      "onboardingCompleted": true
    }
  }
  ```
- **Error Codes:** `401 Unauthorized` (invalid credentials), `422 Unprocessable Entity`.

#### 1.3 Get Current Authenticated User Profile
- **Status:** `[IMPLEMENTED]`
- **Method & Path:** `GET /api/v1/auth/me`
- **Access Level:** Authenticated (Bearer Token)
- **Response Example (`200 OK`):**
  ```json
  {
    "success": true,
    "message": "User profile retrieved",
    "data": {
      "userId": "671a9101f82c4a001a111111",
      "email": "priya.sharma.sample@example.com",
      "name": "Priya Sharma",
      "createdAt": "2026-10-24T12:00:00.000Z"
    }
  }
  ```
- **Error Codes:** `401 Unauthorized`.

---

### Module 2: Women's Health Passport

#### 2.1 Get Health Passport
- **Status:** `[PROPOSED / NOT IMPLEMENTED]`
- **Method & Path:** `GET /api/v1/passport`
- **Access Level:** Authenticated (Bearer Token)
- **Description:** Retrieves the caller's baseline health records, cycle parameters, allergies, and emergency contacts.
- **Response Example (`200 OK`):**
  ```json
  {
    "success": true,
    "message": "Health passport retrieved",
    "data": {
      "bloodGroup": "O+",
      "averageCycleDays": 29,
      "typicalPeriodDurationDays": 5,
      "lastPeriodStartDate": "2026-10-10",
      "diagnosedConditions": ["PCOS"],
      "allergies": ["Penicillin", "Latex"],
      "currentMedications": ["Metformin 500mg daily", "Vitamin D3"],
      "emergencyContacts": [
        {
          "name": "Ananya Sharma",
          "relationship": "Sister",
          "phone": "+91-9876543210"
        }
      ],
      "updatedAt": "2026-10-24T10:00:00.000Z"
    }
  }
  ```
- **Error Codes:** `401 Unauthorized`, `404 Not Found` (passport not initialized yet).

#### 2.2 Upsert Health Passport
- **Status:** `[PROPOSED / NOT IMPLEMENTED]`
- **Method & Path:** `PUT /api/v1/passport`
- **Access Level:** Authenticated (Bearer Token)
- **Request Example:**
  ```json
  {
    "bloodGroup": "O+",
    "averageCycleDays": 29,
    "typicalPeriodDurationDays": 5,
    "lastPeriodStartDate": "2026-10-10",
    "diagnosedConditions": ["PCOS"],
    "allergies": ["Penicillin"],
    "currentMedications": ["Metformin 500mg daily"]
  }
  ```
- **Response Example (`200 OK`):**
  ```json
  {
    "success": true,
    "message": "Health passport updated successfully",
    "data": {
      "updatedAt": "2026-10-24T12:15:00.000Z"
    }
  }
  ```
- **Error Codes:** `400 Bad Request`, `401 Unauthorized`, `422 Unprocessable Entity`.

---

### Module 3: Symptom Check-in & History

#### 3.1 Daily Symptom Check-in
- **Status:** `[PROPOSED / NOT IMPLEMENTED]`
- **Method & Path:** `POST /api/v1/symptoms/check-in`
- **Access Level:** Authenticated (Bearer Token)
- **Validation Rules:**
  - `date`: Required, ISO 8601 YYYY-MM-DD.
  - `flow`: Enum (`none`, `spotting`, `light`, `medium`, `heavy`).
  - `painScale`: Integer from 0 (none) to 10 (worst imaginable).
  - `symptoms`: Array of symptom objects `{ type: string, severity: "mild" | "moderate" | "severe" }`.
- **Request Example:**
  ```json
  {
    "date": "2026-10-24",
    "flow": "medium",
    "painScale": 4,
    "symptoms": [
      { "type": "cramping", "severity": "moderate" },
      { "type": "bloating", "severity": "mild" }
    ],
    "notes": "Mild fatigue after dinner"
  }
  ```
- **Response Example (`201 Created`):**
  ```json
  {
    "success": true,
    "message": "Symptom check-in saved",
    "data": {
      "logId": "671a9300f82c4a001a222222",
      "date": "2026-10-24",
      "safetyAssessment": {
        "isEmergency": false,
        "advice": "Logged successfully. Routine self-care applies."
      }
    }
  }
  ```
- **Error Codes:** `400 Bad Request`, `401 Unauthorized`, `422 Unprocessable Entity`.

#### 3.2 Symptom History Query
- **Status:** `[PROPOSED / NOT IMPLEMENTED]`
- **Method & Path:** `GET /api/v1/symptoms/history`
- **Access Level:** Authenticated (Bearer Token)
- **Query Parameters:** `?startDate=2026-10-01&endDate=2026-10-24`
- **Response Example (`200 OK`):**
  ```json
  {
    "success": true,
    "message": "Symptom history retrieved",
    "data": {
      "logs": [
        {
          "logId": "671a9300f82c4a001a222222",
          "date": "2026-10-24",
          "flow": "medium",
          "painScale": 4,
          "symptoms": [
            { "type": "cramping", "severity": "moderate" }
          ]
        }
      ]
    }
  }
  ```
- **Error Codes:** `400 Bad Request` (invalid dates), `401 Unauthorized`.

---

### Module 4: Context-Aware Health Guidance

#### 4.1 Get Daily Context-Aware Wellness Guidance
- **Status:** `[PROPOSED / NOT IMPLEMENTED]`
- **Method & Path:** `GET /api/v1/guidance/daily`
- **Access Level:** Authenticated (Bearer Token)
- **Description:** Delivers lifestyle, hydration, rest, and nutritional advice calculated deterministically from the user's cycle day, symptom trends, and pre-reviewed educational content.
- **Response Example (`200 OK`):**
  ```json
  {
    "success": true,
    "message": "Daily guidance retrieved",
    "data": {
      "cyclePhase": "Luteal Phase (Day 22)",
      "hydrationGoalMl": 2400,
      "lifestyleTips": [
        "Progesterone rises during the luteal phase; prioritize 7-8 hours of sleep and lower-impact exercise."
      ],
      "nutritionalSuggestions": [
        "Complex carbohydrates and magnesium-rich foods can help stabilize energy levels."
      ],
      "disclaimer": "This information is for general wellness and lifestyle education only. It is not medical advice, diagnosis, or treatment."
    }
  }
  ```
- **Error Codes:** `401 Unauthorized`.

---

### Module 5: Safety Alerts & Urgent-Care Guidance (Safety-Critical)

> **Safety Notice:** This endpoint uses **explicit, deterministic clinical triage rules**. It does **NOT** delegate emergency classification to an unverified generative AI model.

#### 5.1 Evaluate Safety & Acute Symptoms
- **Status:** `[PROPOSED / NOT IMPLEMENTED]`
- **Method & Path:** `POST /api/v1/safety/triage`
- **Access Level:** Authenticated (Bearer Token)
- **Request Example (High-Urgency Warning Signs):**
  ```json
  {
    "acuteSymptoms": [
      "severe_lower_abdominal_pain",
      "fainting_or_dizziness"
    ],
    "painScale": 9,
    "bleedingRate": "soaking_two_pads_an_hour"
  }
  ```
- **Response Example (`200 OK - Red Flag Detected`):**
  ```json
  {
    "success": true,
    "message": "Safety assessment completed",
    "data": {
      "triageLevel": "EMERGENCY_RED_FLAG",
      "isRedFlag": true,
      "alertHeadline": "URGENT MEDICAL EVALUATION RECOMMENDED",
      "explanation": "Severe abdominal pain coupled with dizziness or heavy bleeding (soaking multiple pads per hour) may indicate an acute condition requiring in-person medical care.",
      "actionRequired": "Please seek emergency medical attention or have someone drive you to the nearest urgent care or emergency room.",
      "emergencyHelpline": "112 (National Emergency Number in India) or local equivalent",
      "recommendedSteps": [
        "Do not drive yourself if dizzy or faint",
        "Alert an emergency contact",
        "Present your Health Passport to the emergency medical team"
      ],
      "disclaimer": "HerSignal provides triage warnings based on standard red-flag indicators. It does not replace an in-person physical examination by a licensed medical provider."
    }
  }
  ```
- **Error Codes:** `400 Bad Request`, `401 Unauthorized`.

#### 5.2 Emergency Contacts Management
- **Status:** `[PROPOSED / NOT IMPLEMENTED]`
- **Method & Path:** `GET /api/v1/safety/emergency-contacts`
- **Access Level:** Authenticated (Bearer Token)
- **Response Example (`200 OK`):**
  ```json
  {
    "success": true,
    "data": {
      "nationalHelplines": [
        { "label": "National Emergency Number (India)", "number": "112" },
        { "label": "Women Helpline", "number": "1091" },
        { "label": "KIRAN Mental Health Helpline", "number": "1800-599-0019" }
      ],
      "personalContacts": [
        { "name": "Ananya Sharma", "relationship": "Sister", "phone": "+91-9876543210" }
      ]
    }
  }
  ```

---

### Module 6: Mental Wellness & Mood Tracking

#### 6.1 Log Mood & Emotional State
- **Status:** `[PROPOSED / NOT IMPLEMENTED]`
- **Method & Path:** `POST /api/v1/wellness/mood-log`
- **Access Level:** Authenticated (Bearer Token)
- **Request Example:**
  ```json
  {
    "date": "2026-10-24",
    "mood": "anxious",
    "energyLevel": 3,
    "stressScore": 7,
    "sleepHours": 5.5,
    "journalSnippet": "Felt overwhelmed with work deadlines"
  }
  ```
- **Response Example (`201 Created`):**
  ```json
  {
    "success": true,
    "message": "Mood check-in recorded",
    "data": {
      "logId": "671a9400f82c4a001a333333",
      "suggestedGroundingActivity": {
        "title": "4-7-8 Relaxation Breathing",
        "durationMinutes": 3,
        "instructions": "Inhale through nose for 4s, hold breath for 7s, exhale completely through mouth for 8s."
      }
    }
  }
  ```

#### 6.2 Get Mood Trends
- **Status:** `[PROPOSED / NOT IMPLEMENTED]`
- **Method & Path:** `GET /api/v1/wellness/mood-trends`
- **Access Level:** Authenticated (Bearer Token)
- **Query Parameters:** `?days=30`
- **Response Example (`200 OK`):** Aggregated mood counts, average stress by cycle phase.

---

### Module 7: Doctor-Ready Health Summary

#### 7.1 Generate Doctor-Ready Health Summary
- **Status:** `[PROPOSED / NOT IMPLEMENTED]`
- **Method & Path:** `GET /api/v1/reports/doctor-summary`
- **Access Level:** Authenticated (Bearer Token)
- **Query Parameters:** `?timeframe=90_days`
- **Description:** Compiles user's logged symptoms, cycle regularities, pain trends, and medication adherence into a concise clinical briefing for healthcare appointments.
- **Response Example (`200 OK`):**
  ```json
  {
    "success": true,
    "message": "Doctor-ready summary compiled",
    "data": {
      "reportId": "DOC-2026-SAMPLE-01",
      "generatedAt": "2026-10-24T12:00:00.000Z",
      "patientProfile": {
        "name": "Priya Sharma",
        "age": 23,
        "bloodGroup": "O+",
        "knownConditions": ["PCOS"]
      },
      "cycleOverview": {
        "cyclesTracked": 3,
        "averageCycleLengthDays": 31,
        "variationDays": 4
      },
      "symptomIncidence": [
        { "symptom": "Dysmenorrhea (Cramping)", "totalDays": 5, "maxPainScale": 7 },
        { "symptom": "Fatigue", "totalDays": 8, "maxPainScale": 4 }
      ],
      "clinicalDisclaimer": "This patient-generated summary is intended solely to facilitate informed dialogue between the patient and their licensed healthcare provider. It is NOT a clinical diagnosis or medical test result."
    }
  }
  ```

---

### Module 8: Health Education & Myth-vs-Fact Resources

#### 8.1 List Educational Articles
- **Status:** `[PROPOSED / NOT IMPLEMENTED]`
- **Method & Path:** `GET /api/v1/education/articles`
- **Access Level:** Public
- **Query Parameters:** `?category=menstrual_health | pcos | nutrition | mental_wellbeing`
- **Response Example (`200 OK`):**
  ```json
  {
    "success": true,
    "data": [
      {
        "articleId": "art_pcos_basics_01",
        "title": "Understanding PCOS: Signs, Hormones, and Lifestyle Steps",
        "category": "pcos",
        "summary": "An evidence-based overview of Polycystic Ovary Syndrome and daily management strategies.",
        "readingTimeMinutes": 4
      }
    ]
  }
  ```

#### 8.2 Get Myth-vs-Fact Compendium
- **Status:** `[PROPOSED / NOT IMPLEMENTED]`
- **Method & Path:** `GET /api/v1/education/myths-vs-facts`
- **Access Level:** Public
- **Response Example (`200 OK`):**
  ```json
  {
    "success": true,
    "data": [
      {
        "id": "mf_001",
        "category": "Menstruation",
        "myth": "Debilitating period pain is just part of being a woman and should be endured in silence.",
        "fact": "Severe pain that prevents daily functioning is NOT normal. It may indicate conditions like endometriosis, fibroids, or adenomyosis. A clinical consult with a gynecologist is strongly advised.",
        "reference": "American College of Obstetricians and Gynecologists (ACOG)"
      }
    ]
  }
  ```

---

### Module 9: Privacy & Data Management

#### 9.1 Export All Personal Health Data
- **Status:** `[PROPOSED / NOT IMPLEMENTED]`
- **Method & Path:** `GET /api/v1/privacy/export`
- **Access Level:** Authenticated (Bearer Token)
- **Description:** Generates a structured JSON archive of all records associated with the user's account.
- **Response Example (`200 OK`):**
  ```json
  {
    "success": true,
    "message": "Personal health data export generated",
    "data": {
      "exportDate": "2026-10-24T12:00:00.000Z",
      "userProfile": { "userId": "...", "email": "...", "name": "..." },
      "passport": { ... },
      "symptomLogs": [ ... ],
      "moodLogs": [ ... ]
    }
  }
  ```

#### 9.2 Delete Account & Health Records (Permanent Purge)
- **Status:** `[PROPOSED / NOT IMPLEMENTED]`
- **Method & Path:** `DELETE /api/v1/privacy/delete-account`
- **Access Level:** Authenticated (Bearer Token)
- **Request Body:**
  ```json
  {
    "confirmation": "DELETE_MY_ACCOUNT",
    "password": "CurrentPassword123!"
  }
  ```
- **Response Example (`200 OK`):**
  ```json
  {
    "success": true,
    "message": "User account and all associated health records permanently deleted."
  }
  ```
- **Error Codes:** `400 Bad Request` (incorrect confirmation string), `401 Unauthorized` (incorrect password).
