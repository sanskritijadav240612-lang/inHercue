/// Model representing safety triage response from POST /api/v1/safety/triage.
class SafetyTriageResult {
  final bool isRedFlag;
  final String triageLevel;
  final String alertHeadline;
  final String explanation;
  final String actionRequired;
  final String emergencyHelpline;
  final List<String> recommendedSteps;
  final String disclaimer;

  const SafetyTriageResult({
    required this.isRedFlag,
    required this.triageLevel,
    required this.alertHeadline,
    required this.explanation,
    required this.actionRequired,
    required this.emergencyHelpline,
    required this.recommendedSteps,
    required this.disclaimer,
  });

  factory SafetyTriageResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return SafetyTriageResult(
      isRedFlag: data['isRedFlag'] as bool? ?? false,
      triageLevel: data['triageLevel'] as String? ?? 'ROUTINE',
      alertHeadline: data['alertHeadline'] as String? ?? '',
      explanation: data['explanation'] as String? ?? '',
      actionRequired: data['actionRequired'] as String? ?? '',
      emergencyHelpline: data['emergencyHelpline'] as String? ?? '',
      recommendedSteps:
          (data['recommendedSteps'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      disclaimer: data['disclaimer'] as String? ?? '',
    );
  }
}
