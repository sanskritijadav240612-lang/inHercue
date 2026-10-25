/// Emergency and crisis contact configuration for inHERcue / HerSignal.
/// Provides verified, country-specific emergency phone numbers, crisis hotlines,
/// and verified guidance to ensure users receive accurate assistance.
class EmergencyRegion {
  final String code;
  final String displayName;
  final String flag;
  final String emergencyNumber;
  final String emergencyLabel;
  final String crisisNumber;
  final String crisisLabel;
  final String crisisActionText;
  final String crisisDescription;
  final bool isVerified;

  const EmergencyRegion({
    required this.code,
    required this.displayName,
    required this.flag,
    required this.emergencyNumber,
    required this.emergencyLabel,
    required this.crisisNumber,
    required this.crisisLabel,
    required this.crisisActionText,
    required this.crisisDescription,
    required this.isVerified,
  });
}

class EmergencyConfig {
  /// Verified supported regions with national emergency and mental health helplines.
  static const List<EmergencyRegion> supportedRegions = [
    EmergencyRegion(
      code: 'US_CA',
      displayName: 'United States & Canada',
      flag: '🇺🇸 / 🇨🇦',
      emergencyNumber: '911',
      emergencyLabel: 'Emergency Services (911)',
      crisisNumber: '988',
      crisisLabel: 'Suicide & Crisis Lifeline (988)',
      crisisActionText: 'Call or text 988',
      crisisDescription: 'In the U.S. or Canada, call or text 988 for 24/7 free, confidential crisis support. For immediate danger, call 911.',
      isVerified: true,
    ),
    EmergencyRegion(
      code: 'IN',
      displayName: 'India',
      flag: '🇮🇳',
      emergencyNumber: '112',
      emergencyLabel: 'National Emergency Helpline (112)',
      crisisNumber: '14416',
      crisisLabel: 'Tele-MANAS Mental Health Helpline (14416)',
      crisisActionText: 'Call Tele-MANAS (14416)',
      crisisDescription: 'In India, call 112 for all emergencies (police, fire, ambulance). For mental health support, call Tele-MANAS (14416 / 1800-891-4416) or KIRAN (1800-599-0019) for 24/7 confidential support.',
      isVerified: true,
    ),
    EmergencyRegion(
      code: 'UK',
      displayName: 'United Kingdom',
      flag: '🇬🇧',
      emergencyNumber: '999',
      emergencyLabel: 'Emergency Services (999)',
      crisisNumber: '111',
      crisisLabel: 'NHS Mental Health & Urgent Care (111)',
      crisisActionText: 'Call NHS 111 or Samaritans (116 123)',
      crisisDescription: 'In the UK, call 999 for medical emergencies. For mental health support or urgent advice, call NHS 111 or call Samaritans at 116 123.',
      isVerified: true,
    ),
    EmergencyRegion(
      code: 'GLOBAL',
      displayName: 'International / Other',
      flag: '🌐',
      emergencyNumber: '112',
      emergencyLabel: 'Standard International Emergency (112)',
      crisisNumber: '',
      crisisLabel: 'Local Crisis & Health Services',
      crisisActionText: 'Contact local emergency services',
      crisisDescription: '112 is the standard GSM emergency number accepted in Europe and many global regions. If outside these areas, dial your local emergency services immediately.',
      isVerified: true,
    ),
  ];

  /// Default region fallback. Configured to US/Canada for Figma parity while supporting instant user switching.
  static EmergencyRegion get defaultRegion => supportedRegions[0];

  /// Find region by country code.
  static EmergencyRegion getByCode(String code) {
    return supportedRegions.firstWhere(
      (r) => r.code.toUpperCase() == code.toUpperCase(),
      orElse: () => defaultRegion,
    );
  }
}
