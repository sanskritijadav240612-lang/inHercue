/**
 * Deterministic Clinical Safety Triage Service for HerSignal.
 * Strictly implements explicit boolean rule logic from docs/safety-guidelines.md.
 * NEVER delegates emergency triage to generative AI models.
 */

/**
 * Evaluates symptoms, vitals, and red-flags deterministically.
 *
 * @param {Object} input
 * @param {string[]} [input.acuteSymptoms=[]]
 * @param {number} [input.painScale=0]
 * @param {string} [input.bleedingRate='']
 * @param {number} [input.feverTemperatureC]
 * @param {boolean} [input.hasFainting=false]
 * @param {boolean} [input.hasSevereDizziness=false]
 * @param {boolean} [input.hasPelvicTenderness=false]
 * @returns {Object} Triage result
 */
function evaluateSafetyTriage(input = {}) {
  const acuteSymptoms = Array.isArray(input.acuteSymptoms)
    ? input.acuteSymptoms.map(s => s.toLowerCase().trim())
    : [];

  const painScale = Number(input.painScale) || 0;
  const bleedingRate = (input.bleedingRate || '').toLowerCase().trim();
  const fever = Number(input.feverTemperatureC) || null;
  const hasFainting = Boolean(input.hasFainting) || acuteSymptoms.some(s => s.includes('faint'));
  const hasDizziness = Boolean(input.hasSevereDizziness) || acuteSymptoms.some(s => s.includes('dizz'));
  const hasPelvicPain = painScale >= 8 || acuteSymptoms.some(s => s.includes('pelvic') || s.includes('abdominal'));

  const redFlags = [];

  // 1. Acute hemorrhage indicator
  if (
    bleedingRate === 'soaking_two_pads_an_hour' ||
    bleedingRate === 'large_clots_greater_than_quarter' ||
    acuteSymptoms.some(s => s.includes('soaking') || s.includes('hemorrhage') || s.includes('heavy_bleeding'))
  ) {
    redFlags.push({
      flag: 'SEVERE_ACUTE_HEMORRHAGE',
      message: 'Soaking two or more maxi pads per hour for consecutive hours requires urgent medical evaluation.'
    });
  }

  // 2. Acute severe pelvic pain with fainting / dizziness
  if (hasPelvicPain && (hasFainting || hasDizziness)) {
    redFlags.push({
      flag: 'ACUTE_PELVIC_EMERGENCY',
      message: 'Sudden, severe pelvic or abdominal pain accompanied by dizziness or fainting is a medical emergency.'
    });
  }

  // 3. Systemic infection indicator
  if ((fever && fever >= 38.5) || acuteSymptoms.some(s => s.includes('high_fever'))) {
    if (hasPelvicPain || Boolean(input.hasPelvicTenderness) || acuteSymptoms.some(s => s.includes('tender'))) {
      redFlags.push({
        flag: 'POSSIBLE_PELVIC_INFECTION',
        message: 'High fever combined with pelvic pain requires prompt physician evaluation.'
      });
    }
  }

  const isRedFlag = redFlags.length > 0;

  if (isRedFlag) {
    return {
      isRedFlag: true,
      triageLevel: 'EMERGENCY_RED_FLAG',
      alertHeadline: 'URGENT MEDICAL EVALUATION RECOMMENDED',
      explanation: redFlags.map(r => r.message).join(' '),
      actionRequired: 'Please seek emergency medical attention or have someone drive you to the nearest urgent care or emergency room.',
      emergencyHelpline: '112 (National Emergency Number in India) or 911 / 988 in the US',
      recommendedSteps: [
        'Do not drive yourself if dizzy or faint',
        'Alert an emergency contact or family member',
        'Present your Health Passport to the emergency medical team'
      ],
      redFlags,
      disclaimer: 'HerSignal provides safety guidance based on standard clinical red-flag indicators. It does not provide medical diagnosis, treatment, or clinical prescriptions.'
    };
  }

  return {
    isRedFlag: false,
    triageLevel: 'ROUTINE',
    alertHeadline: 'NO ACUTE RED FLAGS DETECTED',
    explanation: 'Your reported symptoms do not trigger urgent red-flag criteria at this time. Routine self-care and monitoring apply.',
    actionRequired: 'Continue tracking your symptoms. If symptoms worsen, change suddenly, or become severe, seek in-person medical care.',
    emergencyHelpline: '112 (National Emergency Number in India) or 911 / 988 in the US',
    recommendedSteps: [
      'Rest and maintain comfortable hydration',
      'Log any changing symptoms in your daily check-in',
      'Consult a licensed physician for ongoing concerns'
    ],
    redFlags: [],
    disclaimer: 'HerSignal provides safety guidance based on standard clinical red-flag indicators. It does not provide medical diagnosis, treatment, or clinical prescriptions.'
  };
}

module.exports = {
  evaluateSafetyTriage
};
