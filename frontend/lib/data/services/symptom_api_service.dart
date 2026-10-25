// ignore_for_file: use_null_aware_elements
import '../../core/config/api_config.dart';
import '../../core/network/api_client.dart';
import '../models/symptom_model.dart';

/// API Service for logging symptoms and querying check-in history.
class SymptomApiService {
  final ApiClient _client;

  SymptomApiService({ApiClient? client}) : _client = client ?? ApiClient();

  /// Record a daily symptom check-in.
  Future<SymptomLogModel> saveCheckin({
    required String token,
    String? date,
    String? flow,
    int? painScale,
    List<Map<String, dynamic>>? symptoms,
    String? hydration,
    String? sleep,
    String? energy,
    String? activity,
    String? appetite,
    String? mood,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      if (date != null) 'date': date,
      if (flow != null) 'flow': flow,
      if (painScale != null) 'painScale': painScale,
      if (symptoms != null) 'symptoms': symptoms,
      if (hydration != null) 'hydration': hydration,
      if (sleep != null) 'sleep': sleep,
      if (energy != null) 'energy': energy,
      if (activity != null) 'activity': activity,
      if (appetite != null) 'appetite': appetite,
      if (mood != null) 'mood': mood,
      if (notes != null) 'notes': notes,
    };

    final response = await _client.post(
      ApiConfig.symptomsCheckinEndpoint,
      token: token,
      body: body,
    );

    final data = response['data'] as Map<String, dynamic>? ?? {};
    final logData = data['log'] as Map<String, dynamic>? ?? data;
    return SymptomLogModel.fromJson(logData);
  }

  /// Retrieve symptom check-in history for authenticated user.
  Future<List<SymptomLogModel>> getHistory({
    required String token,
    String? startDate,
    String? endDate,
  }) async {
    String query = '';
    final params = <String>[];
    if (startDate != null) params.add('startDate=$startDate');
    if (endDate != null) params.add('endDate=$endDate');
    if (params.isNotEmpty) query = '?${params.join('&')}';

    final response = await _client.get(
      '${ApiConfig.symptomsHistoryEndpoint}$query',
      token: token,
    );

    final data = response['data'] as Map<String, dynamic>? ?? {};
    final rawLogs = data['logs'] as List<dynamic>? ?? [];

    return rawLogs
        .whereType<Map<String, dynamic>>()
        .map(SymptomLogModel.fromJson)
        .toList();
  }

  /// Retrieve the user's latest recorded check-in.
  Future<SymptomLogModel?> getLatest(String token) async {
    final response = await _client.get(
      ApiConfig.symptomsLatestEndpoint,
      token: token,
    );

    final data = response['data'];
    if (data == null || (data is Map && data.isEmpty)) {
      return null;
    }

    return SymptomLogModel.fromJson(data as Map<String, dynamic>);
  }
}
