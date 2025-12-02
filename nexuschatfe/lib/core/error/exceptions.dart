import 'package:dio/dio.dart';

/// Base exception class for all custom exceptions
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

/// Server-related exceptions (5xx errors)
class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode});
}

/// Client-related exceptions (4xx errors)
class ClientException extends AppException {
  const ClientException({required super.message, super.statusCode});
}

/// Network connectivity exceptions
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.statusCode,
  });
}

/// Cache/Storage exceptions
class CacheException extends AppException {
  const CacheException({required super.message, super.statusCode});
}

/// Unauthorized exceptions (401)
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Unauthorized access',
    super.statusCode = 401,
  });
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  const ValidationException({
    required super.message,
    this.errors,
    super.statusCode = 422,
  });
}

/// Helper to extract error messages from DioException
String extractErrorMessage(DioException e) {
  // Check for network connectivity issues
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout) {
    return 'Connection timeout. Please check your internet connection.';
  }

  if (e.type == DioExceptionType.connectionError) {
    return 'No internet connection. Please check your network settings.';
  }

  // Extract from response data
  if (e.response?.data != null) {
    final data = e.response!.data;

    if (data is Map<String, dynamic>) {
      // Laravel validation errors
      if (data.containsKey('errors') && data['errors'] is Map) {
        final errors = data['errors'] as Map;
        if (errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
        }
      }

      // Standard message field
      if (data.containsKey('message') && data['message'] is String) {
        return data['message'] as String;
      }

      // Error field
      if (data.containsKey('error') && data['error'] is String) {
        return data['error'] as String;
      }
    }

    // If data is a string
    if (data is String && data.isNotEmpty) {
      return data;
    }
  }

  // Default messages based on status code
  final statusCode = e.response?.statusCode;
  if (statusCode != null) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access forbidden. You don\'t have permission.';
      case 404:
        return 'Resource not found.';
      case 422:
        return 'Validation error. Please check your input.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
    }
  }

  return e.message ?? 'An unexpected error occurred';
}

/// Convert DioException to appropriate AppException
AppException convertDioException(DioException e) {
  final message = extractErrorMessage(e);
  final statusCode = e.response?.statusCode;

  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.connectionError) {
    return NetworkException(message: message);
  }

  if (statusCode != null) {
    if (statusCode == 401) {
      return UnauthorizedException(message: message);
    }

    if (statusCode == 422 && e.response?.data is Map) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data.containsKey('errors')) {
        return ValidationException(
          message: message,
          errors: (data['errors'] as Map).map(
            (key, value) => MapEntry(
              key.toString(),
              (value as List).map((e) => e.toString()).toList(),
            ),
          ),
        );
      }
    }

    if (statusCode >= 400 && statusCode < 500) {
      return ClientException(message: message, statusCode: statusCode);
    }

    if (statusCode >= 500) {
      return ServerException(message: message, statusCode: statusCode);
    }
  }

  return ServerException(message: message, statusCode: statusCode);
}
