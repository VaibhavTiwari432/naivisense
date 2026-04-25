import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  const AppException(this.message, {this.statusCode, this.code});

  @override
  String toString() => message;
}

class ErrorHandlerService {
  static AppException handle(dynamic error) {
    if (error is AppException) return error;
    if (error is DioException) {
      final normalized = error.error;
      if (normalized is AppException) return normalized;
      return _fromDio(error);
    }
    return AppException(error?.toString() ?? 'An unexpected error occurred.');
  }

  static AppException _fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AppException('Connection timed out. Please try again.');
      case DioExceptionType.connectionError:
        return const AppException(
            'Unable to connect. Check your internet connection.');
      case DioExceptionType.cancel:
        return const AppException('Request cancelled.');
      case DioExceptionType.badCertificate:
        return const AppException('Unable to verify the server connection.');
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        final msg = _parseMessage(error.response?.data);
        return AppException(
          msg.isEmpty ? _fallbackMessageForStatus(code) : msg,
          statusCode: code,
          code: code?.toString(),
        );
      default:
        return AppException(error.message ?? 'An unexpected error occurred.');
    }
  }

  static String _parseMessage(dynamic data) {
    if (data is Map) {
      final detail = data['detail'];
      if (detail is String) return detail;
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] != null) {
          return first['msg'].toString();
        }
        return first.toString();
      }
      return data['message']?.toString() ?? 'Server error';
    }
    if (data is String) return data;
    return '';
  }

  static String _fallbackMessageForStatus(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Please check the information and try again.';
      case 401:
        return 'Your session has expired. Please log in again.';
      case 403:
        return 'You do not have permission to do that.';
      case 404:
        return 'The requested information was not found.';
      case 409:
        return 'This information conflicts with an existing record.';
      case 422:
        return 'Please check the form details and try again.';
      case 500:
        return 'The server had a problem. Please try again shortly.';
      default:
        return 'Server error';
    }
  }
}
