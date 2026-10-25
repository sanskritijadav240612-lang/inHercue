/// Model representing a single symptom with severity.
class SymptomItem {
  final String type;
  final String severity;
  final String? duration;
  final String? frequency;

  const SymptomItem({
    required this.type,
    required this.severity,
    this.duration,
    this.frequency,
  });

  factory SymptomItem.fromJson(Map<String, dynamic> json) {
    return SymptomItem(
      type: json['type'] as String? ?? '',
      severity: json['severity'] as String? ?? 'mild',
      duration: json['duration'] as String?,
      frequency: json['frequency'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'severity': severity,
      if (duration != null) 'duration': duration,
      if (frequency != null) 'frequency': frequency,
    };
  }
}

/// Safety assessment returned with a check-in.
class SafetyAssessment {
  final bool isEmergency;
  final String triageLevel;
  final String advice;

  const SafetyAssessment({
    this.isEmergency = false,
    this.triageLevel = 'ROUTINE',
    this.advice = 'Routine self-care applies.',
  });

  factory SafetyAssessment.fromJson(Map<String, dynamic> json) {
    return SafetyAssessment(
      isEmergency: json['isEmergency'] as bool? ?? false,
      triageLevel: json['triageLevel'] as String? ?? 'ROUTINE',
      advice: json['advice'] as String? ?? 'Routine self-care applies.',
    );
  }
}

/// Model representing a Daily Symptom Check-in log.
class SymptomLogModel {
  final String? id;
  final String date;
  final String flow;
  final int painScale;
  final List<SymptomItem> symptoms;
  final String? hydration;
  final String? sleep;
  final String? energy;
  final String? activity;
  final String? appetite;
  final String? mood;
  final String? notes;
  final SafetyAssessment? safetyAssessment;
  final DateTime? createdAt;

  const SymptomLogModel({
    this.id,
    required this.date,
    this.flow = 'none',
    this.painScale = 0,
    this.symptoms = const [],
    this.hydration,
    this.sleep,
    this.energy,
    this.activity,
    this.appetite,
    this.mood,
    this.notes,
    this.safetyAssessment,
    this.createdAt,
  });

  factory SymptomLogModel.fromJson(Map<String, dynamic> json) {
    final rawSymptoms = json['symptoms'];
    List<SymptomItem> parsedSymptoms = [];
    if (rawSymptoms is List) {
      for (final s in rawSymptoms) {
        if (s is Map<String, dynamic>) {
          parsedSymptoms.add(SymptomItem.fromJson(s));
        } else if (s is String) {
          parsedSymptoms.add(SymptomItem(type: s, severity: 'mild'));
        }
      }
    }

    final rawSafety = json['safetyAssessment'];
    SafetyAssessment? safety;
    if (rawSafety is Map<String, dynamic>) {
      safety = SafetyAssessment.fromJson(rawSafety);
    }

    return SymptomLogModel(
      id: (json['_id'] ?? json['id'] ?? json['logId']) as String?,
      date: json['date'] as String? ?? '',
      flow: json['flow'] as String? ?? 'none',
      painScale: (json['painScale'] as num?)?.toInt() ?? 0,
      symptoms: parsedSymptoms,
      hydration: json['hydration'] as String?,
      sleep: json['sleep'] as String?,
      energy: json['energy'] as String?,
      activity: json['activity'] as String?,
      appetite: json['appetite'] as String?,
      mood: json['mood'] as String?,
      notes: json['notes'] as String?,
      safetyAssessment: safety,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
