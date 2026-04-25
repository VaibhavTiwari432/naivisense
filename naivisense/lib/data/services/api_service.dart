import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import 'error_handler_service.dart';
import 'storage_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref.read(storageServiceProvider));
});

class ApiService {
  late final Dio dio;
  final StorageService _storage;

  ApiService(this._storage) {
    dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout:
          const Duration(milliseconds: AppConstants.connectionTimeoutMs),
      sendTimeout: const Duration(milliseconds: AppConstants.sendTimeoutMs),
      receiveTimeout:
          const Duration(milliseconds: AppConstants.receiveTimeoutMs),
      responseType: ResponseType.json,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: _attachAuthToken,
        onError: _normalizeError,
      ),
      if (kDebugMode)
        LogInterceptor(
          requestHeader: false,
          responseHeader: false,
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (object) => debugPrint(object.toString()),
        ),
    ]);
  }

  Future<void> _attachAuthToken(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers.putIfAbsent('Authorization', () => 'Bearer $token');
    }
    handler.next(options);
  }

  void _normalizeError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) {
    final appException = ErrorHandlerService.handle(error);
    handler.reject(error.copyWith(error: appException));
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
}
