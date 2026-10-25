/// Model representing an authenticated user's Health Passport.
class PassportModel {
  final String? focus;
  final String? cycleType;
  final int averageCycleDays;
  final int typicalPeriodDurationDays;
  final String? lastPeriodStartDate;
  final List<String> diagnosedConditions;
  final List<String> allergies;
  final List<String> currentMedications;
  final DateTime? updatedAt;

  const PassportModel({
    this.focus,
    this.cycleType,
    this.averageCycleDays = 28,
    this.typicalPeriodDurationDays = 5,
    this.lastPeriodStartDate,
    this.diagnosedConditions = const [],
    this.allergies = const [],
    this.currentMedications = const [],
    this.updatedAt,
  });

  factory PassportModel.fromJson(Map<String, dynamic> json) {
    return PassportModel(
      focus: json['focus'] as String?,
      cycleType: json['cycleType'] as String?,
      averageCycleDays: (json['averageCycleDays'] as num?)?.toInt() ?? 28,
      typicalPeriodDurationDays:
          (json['typicalPeriodDurationDays'] as num?)?.toInt() ?? 5,
      lastPeriodStartDate: json['lastPeriodStartDate'] as String?,
      diagnosedConditions:
          (json['diagnosedConditions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      allergies:
          (json['allergies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      currentMedications:
          (json['currentMedications'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (focus != null) 'focus': focus,
      if (cycleType != null) 'cycleType': cycleType,
      'averageCycleDays': averageCycleDays,
      'typicalPeriodDurationDays': typicalPeriodDurationDays,
      if (lastPeriodStartDate != null)
        'lastPeriodStartDate': lastPeriodStartDate,
      'diagnosedConditions': diagnosedConditions,
      'allergies': allergies,
      'currentMedications': currentMedications,
    };
  }
}
