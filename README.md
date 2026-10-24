# inHercue
Women's Healthcare and Wellness App

## Overview
**HerSignal** is a comprehensive women's healthcare and wellness application designed for hackathon demonstration. It empowers users to track their menstrual cycles, log daily physical and mental symptoms, view context-aware lifestyle guidance, access verified educational resources, and conduct rule-based urgent safety triages.

> **Project Status:**
> **Phase 1: Foundation and Documentation.**
> All API specifications, architecture plans, safety rules, and privacy guidelines have been designed and documented under `docs/`. **All backend endpoints and frontend interfaces are currently PROPOSED / NOT YET IMPLEMENTED.**

---

## Planned Technology Stack

- **Mobile Frontend:** Flutter & Dart (Cross-platform for Android and iOS)
- **Backend Server:** Node.js & Express (`/api/v1` REST API)
- **Database:** MongoDB & Mongoose ODM
- **Version Control:** Git & GitHub (`inHercue` repository on branch `backend`)
- **Development Environment:** Google Antigravity IDE

---

## Core Modules & Capabilities

1. **Authentication & Onboarding:** Secure user registration, login, and personalized onboarding.
2. **Women's Health Passport:** Baseline profile including cycle patterns, diagnosed conditions (e.g., PCOS), medications, and emergency contacts.
3. **Symptom Check-in:** Daily logging of flow, cramping, fatigue, and physical symptoms.
4. **Context-Aware Health Guidance:** Phase-specific lifestyle, nutrition, and rest guidance.
5. **Safety Alerts & Urgent-Care Guidance:** Explicit, deterministic rule-based evaluation of red-flag symptoms with immediate emergency assistance prompts.
6. **Mental Wellness & Mood Tracking:** Daily mood ratings, stress logs, and guided relaxation exercises.
7. **Doctor-Ready Health Summary:** Objective data compilation of cycle regularity and symptom patterns for healthcare visits.
8. **Health Education & Myth Busters:** Evidence-backed articles debunking common women's health myths.
9. **Privacy & Data Management:** Full user control over personal health data, including one-click JSON export and permanent account deletion.

---

## Documentation Quick Links

- [API Contract Specification](docs/api-contract.md)
- [System Architecture & Roadmap](docs/architecture.md)
- [Clinical Safety Guidelines](docs/safety-guidelines.md)
- [Data Privacy & Security Specification](docs/data-privacy-spec.md)

---

## Safety Disclaimer
HerSignal is an educational and wellness logging tool. It does **not** provide clinical diagnosis, treatment, or medical prescriptions. In case of severe symptoms or acute medical emergencies, users are directed to contact local emergency services or seek in-person medical care immediately.
