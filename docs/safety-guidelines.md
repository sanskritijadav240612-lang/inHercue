# HerSignal Clinical Safety Guidelines & Protocols

> **Core Safety Principle:**
> **HerSignal is an educational and personal health tracking application. Under NO circumstances does this application provide medical diagnoses, prescribe drugs or treatments, or replace the clinical judgment of a qualified healthcare professional.**

---

## 1. Absolute Clinical Boundaries

1. **No Automated Diagnoses:**
   - The application must never state that a user "has" a disease, syndrome, or medical disorder (e.g., will never state "You have Endometriosis" or "You have Pelvic Inflammatory Disease").
   - Instead, the app may only describe logged symptom patterns and suggest questions to discuss with a licensed physician.
2. **No Prescribing or Medication Adjustments:**
   - The application must never recommend starting, stopping, or altering dosages of prescription medications.
   - Any discussion of over-the-counter pain relief or supplements must carry explicit disclaimers advising the user to verify with their pharmacist or doctor.
3. **Mandatory Universal Disclaimer:**
   - Displayed prominently in the app footer, onboarding screens, and health report exports:
   > *"HerSignal is an educational and self-tracking tool. It does not provide medical diagnosis, treatment, or clinical advice. If you are experiencing severe pain, unusual symptoms, or a medical emergency, seek immediate professional medical care."*

---

## 2. Deterministic Urgent-Care Triage (No Generative AI for Emergencies)

### 2.1 The AI Hallucination Risk
Generative AI models and LLMs are non-deterministic: they can hallucinate, downplay life-threatening symptoms, or produce inconsistent output. For medical triage, **delegating emergency detection to an external LLM is strictly unacceptable**.

### 2.2 Explicit, Deterministic Rule Logic
All emergency and red-flag evaluations in HerSignal are governed by hardcoded, deterministic boolean rules executed in-memory:

```javascript
// Conceptual representation of deterministic safety evaluation
function evaluateSafetyTriage(symptoms, vitals) {
  const redFlags = [];

  // Acute hemorrhage indicator (Standard clinical emergency marker)
  if (symptoms.bleedingRate === 'soaking_two_pads_an_hour' || symptoms.bleedingRate === 'large_clots_greater_than_quarter') {
    redFlags.push({
      flag: 'SEVERE_ACUTE_HEMORRHAGE',
      message: 'Soaking two or more maxi pads per hour for consecutive hours requires urgent medical evaluation.'
    });
  }

  // Acute severe pelvic pain with fainting/dizziness (potential ectopic pregnancy or ovarian torsion)
  if (symptoms.painScale >= 8 && (symptoms.hasFainting || symptoms.hasSevereDizziness)) {
    redFlags.push({
      flag: 'ACUTE_PELVIC_EMERGENCY',
      message: 'Sudden, severe pelvic or abdominal pain accompanied by dizziness or fainting is a medical emergency.'
    });
  }

  // Systemic infection indicator
  if (symptoms.feverTemperatureC >= 38.5 && symptoms.hasPelvicTenderness) {
    redFlags.push({
      flag: 'POSSIBLE_PELVIC_INFECTION',
      message: 'High fever combined with pelvic pain requires prompt physician evaluation.'
    });
  }

  return {
    isRedFlag: redFlags.length > 0,
    urgencyLevel: redFlags.length > 0 ? 'EMERGENCY_IMMEDIATE' : 'ROUTINE',
    redFlags
  };
}
```

### 2.3 Requirement for Clinical Review
- The threshold values and rule definitions in this document and codebase are **prototype representations** created for a hackathon demonstration.
- **Before HerSignal can be deployed or used with real human patients, every safety rule, symptom threshold, and guidance string MUST undergo formal clinical review and sign-off by a licensed board-certified Obstetrician/Gynecologist (OB/GYN).**

---

## 3. Emergency & Crisis Protocols

### 3.1 Acute Physical Emergencies
When a red-flag condition is triggered:
1. The app immediately renders a non-dismissible or prominent top-level alert modal.
2. Direct one-tap dialer buttons appear for national and local emergency services (e.g., `112` in India, `911` in the US).
3. The user is instructed:
   - *"Do not drive yourself if dizzy or faint."*
   - *"Alert an emergency contact or family member."*
   - *"Head to the nearest emergency department or call an ambulance."*

### 3.2 Mental Health Crisis & Self-Harm Disclosures
Women's health and hormonal fluctuations can intersect with severe depressive episodes, postpartum depression, or premenstrual dysphoric disorder (PMDD).
- If a user enters text or selects indicators indicating suicidal thoughts, severe self-harm, or despair:
  1. The app immediately surfaces trusted national mental health crisis helplines.
  2. In India: **KIRAN Mental Health Helpline (1800-599-0019)**, **Tele-MANAS (14416 / 1800-891-4416)**, or **Vandrevala Foundation Helpline (+91 9999 666 555)**.
  3. Reassuring, compassionate, and non-judgmental language: *"You are not alone. Free, confidential support is available right now from trained counselors."*
