# HerSignal Data Privacy & Security Specification

> **Legal Disclaimer:**
> While HerSignal incorporates modern privacy-by-design concepts inspired by international frameworks such as the GDPR, HIPAA, and the Indian Digital Personal Data Protection Act (DPDPA), **this hackathon project does not claim certified regulatory compliance**. Operating in a live clinical or production setting requires formal legal audits, business associate agreements (BAA), data protection officers (DPO), and certified infrastructure.

---

## 1. Classification of Sensitive Health Data

All user data processed by HerSignal is classified according to sensitivity:

| Data Category | Examples | Sensitivity Level | Protective Measures |
| :--- | :--- | :--- | :--- |
| **Authentication Credentials** | Passwords, password reset tokens | **Critical** | Salting and one-way hashing with `bcryptjs` (work factor 12). Plaintext passwords never logged or saved. |
| **Personal Health Data (PHD)** | Menstrual dates, flow volume, pain scores, physical symptoms | **Highly Sensitive** | Bound strictly to user's authenticated UUID. Never sold, never shared with third-party advertisers. |
| **Medical History & Meds** | Diagnosed conditions (PCOS, Endometriosis), medications, allergies | **Highly Sensitive** | Stored in isolated Health Passport document. Exportable and deletable upon user request. |
| **Mental Wellness & Notes** | Mood ratings, journal entries, emotional reflections | **Highly Sensitive** | Restricted to user-only access. Never fed into general model training. |
| **Emergency Contacts** | Names, phone numbers of relatives/friends | **Sensitive** | Used solely within emergency / safety alert workflows. |

---

## 2. Security & Access Architecture

### 2.1 Authentication & Authorization
- **JWT (JSON Web Tokens):**
  - Signed with a high-entropy secret (`JWT_SECRET`).
  - Short-lived expiry (e.g., 24 hours to 7 days in development).
- **Tenant Isolation:**
  - Every MongoDB query for user records is filtered by `userId: req.user._id`.
  - Under no circumstances can a user query or mutate another user's health records.

### 2.2 Input Sanitization & Validation
- All inbound JSON payloads are validated using strict schema validators (e.g., Joi or express-validator).
- Any unexpected fields are stripped to prevent parameter pollution or NoSQL injection attacks.

### 2.3 Secret Management & Version Control Safety
- **No Hardcoded Secrets:** No database connection strings, JWT signing keys, or API tokens may exist in source code.
- **Environment Files:**
  - `.env`, `.env.local`, and `.env.*.local` are strictly excluded in `.gitignore`.
  - A clean `.env.example` file is maintained in version control, providing dummy placeholder keys (e.g., `PORT=5000`, `MONGO_URI=mongodb://localhost:27017/hersignal_db`, `JWT_SECRET=replace_with_a_secure_random_string_in_production`).

---

## 3. User Data Rights & Privacy Controls

### 3.1 Data Minimization
- The application only requests data points directly relevant to women's cycle logging, wellness education, and emergency triaging.
- Optional fields (like journal notes) are never mandatory.

### 3.2 Right to Data Portability (Export)
- Available via `GET /api/v1/privacy/export`.
- Returns a complete JSON file containing the user's profile, passport, symptom logs, and mood history.

### 3.3 Right to Erasure (Permanent Account Deletion)
- Available via `DELETE /api/v1/privacy/delete-account`.
- Permanently purges all user records across all MongoDB collections (`users`, `healthpassports`, `symptomlogs`, `moodlogs`).
- No soft-delete retention of health metrics once purged.
