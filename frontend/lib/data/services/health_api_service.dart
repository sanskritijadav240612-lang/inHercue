import '../../core/config/api_config.dart';
import '../../core/network/api_client.dart';

/// Model representing backend operational status from `GET /api/v1/health`.
class HealthStatusModel {
  final String service;
  final String status;
  final String environment;
  final String? dbStatus;
  final DateTime? timestamp;

  const HealthStatusModel({
    required this.service,
    required this.status,
    required this.environment,
    this.dbStatus,
    this.timestamp,
  });

  factory HealthStatusModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final dbObj = data['database'] as Map<String, dynamic>?;

    return HealthStatusModel(
      service: data['service'] as String? ?? 'inHercue API',
      status: data['status'] as String? ?? 'unknown',
      environment: data['environment'] as String? ?? 'development',
      dbStatus: dbObj != null ? dbObj['status'] as String? : null,
      timestamp: data['timestamp'] != null
          ? DateTime.tryParse(data['timestamp'].toString())
          : null,
    );
  }

  bool get isHealthy => status.toLowerCase() == 'healthy';

  @override
  String toString() => 'HealthStatus(status: $status, db: $dbStatus)';
}

/// Service for monitoring backend availability and database readiness.
class HealthApiService {
  final ApiClient _client;

  HealthApiService({ApiClient? client}) : _client = client ?? ApiClient();

  /// Checks backend health via `GET /api/v1/health`.
  Future<HealthStatusModel> checkHealth() async {
    final response = await _client.get(ApiConfig.healthEndpoint);
    return HealthStatusModel.fromJson(response);
  }
}
