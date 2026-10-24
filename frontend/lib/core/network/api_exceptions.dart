/// Field-level validation detail returned by the backend.
class ValidationErrorDetail {
  final String field;
  final String issue;

  const ValidationErrorDetail({
    required this.field,
    required this.issue,
  });

  factory ValidationErrorDetail.fromJson(Map<String, dynamic> json) {
    return ValidationErrorDetail(
      field: json['field'] as String? ?? '',
      issue: json['issue'] as String? ?? '',
    );
  }

  @override
  String toString() => '$field: $issue';
}

/// Base class for all API exceptions thrown by inHercue client.
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String? code;
  final List<ValidationErrorDetail> details;

  const ApiException({
    required this.message,
    this.statusCode = 500,
    this.code,
    this.details = const [],
  });

  @override
  String toString() {
    if (details.isNotEmpty) {
      final detailSummary = details.map((d) => d.toString()).join('; ');
      return 'ApiException ($statusCode, code: $code): $message ($detailSummary)';
    }
    return 'ApiException ($statusCode, code: $code): $message';
  }
}

/// Thrown when the backend rejects registration due to an existing email (HTTP 409 DUPLICATE_EMAIL).
class DuplicateEmailException extends ApiException {
  const DuplicateEmailException({
    super.message = 'An account with this email address already exists.',
    super.statusCode = 409,
    super.code = 'DUPLICATE_EMAIL',
    super.details = const [],
  });
}

/// Thrown when login fails due to incorrect email or password (HTTP 401 INVALID_CREDENTIALS).
class InvalidCredentialsException extends ApiException {
  const InvalidCredentialsException({
    super.message = 'Invalid email or password.',
    super.statusCode = 401,
    super.code = 'INVALID_CREDENTIALS',
    super.details = const [],
  });
}

/// Thrown when payload fails validation rules (HTTP 422 VALIDATION_ERROR).
class ValidationException extends ApiException {
  const ValidationException({
    super.message = 'Validation failed.',
    super.statusCode = 422,
    super.code = 'VALIDATION_ERROR',
    super.details = const [],
  });
}

/// Thrown when a protected endpoint rejects a missing, invalid, or expired token (HTTP 401).
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Authentication token is missing, invalid, or expired.',
    super.statusCode = 401,
    super.code = 'UNAUTHORIZED',
    super.details = const [],
  });
}

/// Thrown when a network failure occurs (e.g., connection refused, timeout, offline).
class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'Unable to connect to the inHercue server. Please check your network connection.',
    super.statusCode = 0,
    super.code = 'NETWORK_ERROR',
    super.details = const [],
  });
}
