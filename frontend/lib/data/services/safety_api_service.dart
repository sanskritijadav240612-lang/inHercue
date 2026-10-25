// ignore_for_file: use_null_aware_elements
import '../../core/config/api_config.dart';
import '../../core/network/api_client.dart';
import '../models/safety_triage_model.dart';

/// API Service for deterministic safety triage and red-flag evaluations.
class SafetyApiService {
  final ApiClient _client;

  SafetyApiService({ApiClient? client}) : _client = client ?? ApiClient();

  /// Evaluate acute symptoms for red-flag warning signs.
  Future<SafetyTriageResult> evaluateTriage({
    List<String>? acuteSymptoms,
    int? painScale,
    String? bleedingRate,
    double? feverTemperatureC,
    bool? hasFainting,
    bool? hasSevereDizziness,
    bool? hasPelvicTenderness,
  }) async {
    final body = <String, dynamic>{
      if (acuteSymptoms != null) 'acuteSymptoms': acuteSymptoms,
      if (painScale != null) 'painScale': painScale,
      if (bleedingRate != null) 'bleedingRate': bleedingRate,
      if (feverTemperatureC != null) 'feverTemperatureC': feverTemperatureC,
      if (hasFainting != null) 'hasFainting': hasFainting,
      if (hasSevereDizziness != null) 'hasSevereDizziness': hasSevereDizziness,
      if (hasPelvicTenderness != null)
        'hasPelvicTenderness': hasPelvicTenderness,
    };

    final response = await _client.post(
      ApiConfig.safetyTriageEndpoint,
      body: body,
    );

    return SafetyTriageResult.fromJson(response);
  }
}
