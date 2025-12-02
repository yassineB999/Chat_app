import 'package:dio/dio.dart';

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({required this.message, this.statusCode});
}

// Helper to extract error messages from Dio
String extractErrorMessage(DioException e) {
  if (e.response != null && e.response?.data != null) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      if (data.containsKey('errors')) {
        // Laravel style errors
        final errors = data['errors'];
        if (errors is Map) {
          return errors.values.first.first.toString();
        }
      }
      if (data.containsKey('message')) {
        return data['message'];
      }
    }
  }
  return e.message ?? "Unknown Error";
}
