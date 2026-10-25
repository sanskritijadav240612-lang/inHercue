import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_exceptions.dart';

/// Reusable HTTP API client for inHercue.
/// Handles request building, JSON serialization, bearer token injection,
/// timeouts, and maps backend error envelopes to typed [ApiException]s.
class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Performs an HTTP GET request to the specified [endpoint].
  /// [endpoint] should begin with a slash (e.g., `/health`, `/auth/me`).
  Future<Map<String, dynamic>> get(
    String endpoint, {
    String? token,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final mergedHeaders = _buildHeaders(token: token, customHeaders: headers);

    try {
      final response = await _client
          .get(uri, headers: mergedHeaders)
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw const NetworkException(
        message: 'Request timed out while waiting for server response.',
      );
    } on SocketException catch (e) {
      throw NetworkException(
        message: 'Network connection failed: ${e.message}',
      );
    } on http.ClientException catch (e) {
      throw NetworkException(message: 'HTTP client error: ${e.message}');
    }
  }

  /// Performs an HTTP POST request to the specified [endpoint].
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final mergedHeaders = _buildHeaders(token: token, customHeaders: headers);
    final encodedBody = body != null ? jsonEncode(body) : null;

    try {
      final response = await _client
          .post(uri, headers: mergedHeaders, body: encodedBody)
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw const NetworkException(
        message: 'Request timed out while waiting for server response.',
      );
    } on SocketException catch (e) {
      throw NetworkException(
        message: 'Network connection failed: ${e.message}',
      );
    } on http.ClientException catch (e) {
      throw NetworkException(message: 'HTTP client error: ${e.message}');
    }
  }

  /// Performs an HTTP PUT request to the specified [endpoint].
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final mergedHeaders = _buildHeaders(token: token, customHeaders: headers);
    final encodedBody = body != null ? jsonEncode(body) : null;

    try {
      final response = await _client
          .put(uri, headers: mergedHeaders, body: encodedBody)
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw const NetworkException(
        message: 'Request timed out while waiting for server response.',
      );
    } on SocketException catch (e) {
      throw NetworkException(
        message: 'Network connection failed: ${e.message}',
      );
    } on http.ClientException catch (e) {
      throw NetworkException(message: 'HTTP client error: ${e.message}');
    }
  }

  /// Builds standard JSON and authorization request headers.
  Map<String, String> _buildHeaders({
    String? token,
    Map<String, String>? customHeaders,
  }) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  /// Processes the HTTP response, validating status code and decoding JSON envelope.
  Map<String, dynamic> _handleResponse(http.Response response) {
    Map<String, dynamic> body = {};
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          body = decoded;
        }
      } catch (_) {
        // Response was not JSON
      }
    }

    final statusCode = response.statusCode;

    // Successful response (2xx)
    if (statusCode >= 200 && statusCode < 300) {
      return body;
    }

    // Parse backend error envelope: { success: false, error: { code, message, details } }
    final errorObj = body['error'];
    String? errorCode;
    String errorMessage = 'Request failed with status $statusCode';
    List<ValidationErrorDetail> details = [];

    if (errorObj is Map<String, dynamic>) {
      errorCode = errorObj['code'] as String?;
      errorMessage = errorObj['message'] as String? ?? errorMessage;

      final detailsList = errorObj['details'];
      if (detailsList is List) {
        details = detailsList
            .whereType<Map<String, dynamic>>()
            .map(ValidationErrorDetail.fromJson)
            .toList();
      }
    }

    // Map to typed exceptions
    if (statusCode == 409 || errorCode == 'DUPLICATE_EMAIL') {
      throw DuplicateEmailException(
        message: errorMessage,
        statusCode: statusCode,
        code: errorCode ?? 'DUPLICATE_EMAIL',
        details: details,
      );
    }

    if (statusCode == 401 && errorCode == 'INVALID_CREDENTIALS') {
      throw InvalidCredentialsException(
        message: errorMessage,
        statusCode: statusCode,
        code: errorCode,
        details: details,
      );
    }

    if (statusCode == 422 || errorCode == 'VALIDATION_ERROR') {
      throw ValidationException(
        message: errorMessage,
        statusCode: statusCode,
        code: errorCode ?? 'VALIDATION_ERROR',
        details: details,
      );
    }

    if (statusCode == 401) {
      throw UnauthorizedException(
        message: errorMessage,
        statusCode: statusCode,
        code: errorCode ?? 'UNAUTHORIZED',
        details: details,
      );
    }

    throw ApiException(
      message: errorMessage,
      statusCode: statusCode,
      code: errorCode,
      details: details,
    );
  }

  /// Closes the underlying HTTP client.
  void dispose() {
    _client.close();
  }
}
