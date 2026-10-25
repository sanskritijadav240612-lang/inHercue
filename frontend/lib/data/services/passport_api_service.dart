// ignore_for_file: use_null_aware_elements
import '../../core/config/api_config.dart';
import '../../core/network/api_client.dart';
import '../models/passport_model.dart';

/// API Service for managing Health Passport records with the backend.
class PassportApiService {
  final ApiClient _client;

  PassportApiService({ApiClient? client}) : _client = client ?? ApiClient();

  /// Retrieve the current user's Health Passport.
  Future<PassportModel?> getPassport(String token) async {
    final response = await _client.get(
      ApiConfig.passportEndpoint,
      token: token,
    );

    final data = response['data'];
    if (data == null || (data is Map && data.isEmpty)) {
      return null;
    }

    return PassportModel.fromJson(data as Map<String, dynamic>);
  }

  /// Save or update Health Passport records for authenticated user.
  Future<PassportModel> savePassport({
    required String token,
    String? focus,
    String? cycleType,
    int? averageCycleDays,
    int? typicalPeriodDurationDays,
    String? lastPeriodStartDate,
    List<String>? diagnosedConditions,
    List<String>? allergies,
    List<String>? currentMedications,
    List<Map<String, String>>? emergencyContacts,
  }) async {
    final body = <String, dynamic>{
      if (focus != null) 'focus': focus,
      if (cycleType != null) 'cycleType': cycleType,
      if (averageCycleDays != null) 'averageCycleDays': averageCycleDays,
      if (typicalPeriodDurationDays != null)
        'typicalPeriodDurationDays': typicalPeriodDurationDays,
      if (lastPeriodStartDate != null)
        'lastPeriodStartDate': lastPeriodStartDate,
      if (diagnosedConditions != null)
        'diagnosedConditions': diagnosedConditions,
      if (allergies != null) 'allergies': allergies,
      if (currentMedications != null) 'currentMedications': currentMedications,
      if (emergencyContacts != null) 'emergencyContacts': emergencyContacts,
    };

    final response = await _client.post(
      ApiConfig.passportEndpoint,
      token: token,
      body: body,
    );

    final data = response['data'] as Map<String, dynamic>? ?? {};
    return PassportModel.fromJson(data);
  }
}
