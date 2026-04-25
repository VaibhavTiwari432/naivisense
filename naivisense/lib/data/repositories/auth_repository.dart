import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../services/api_service.dart';
import '../services/error_handler_service.dart';
import '../services/storage_service.dart';
import '../../shared/models/api/auth_requests.dart';
import '../../shared/models/api/auth_responses.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.read(apiServiceProvider),
    ref.read(storageServiceProvider),
  );
});

class AuthRepository {
  final ApiService _api;
  final StorageService _storage;

  AuthRepository(this._api, this._storage);

  Future<TokenResponse> login(String phone, String password) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        AppConstants.authLoginEndpoint,
        data: LoginRequest(phone: phone, password: password).toJson(),
      );
      return _persistSession(TokenResponse.fromJson(_asMap(res.data)));
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<TokenResponse> register(RegisterRequest request) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        AppConstants.authRegisterEndpoint,
        data: request.toJson(),
      );
      return _persistSession(TokenResponse.fromJson(_asMap(res.data)));
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<UserResponse> getCurrentUser() async {
    try {
      final res = await _api.get<Map<String, dynamic>>(
        AppConstants.authMeEndpoint,
      );
      final user = UserResponse.fromJson(_asMap(res.data));
      await _storage.saveUserData(jsonEncode(user.toJson()));
      return user;
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<UserResponse?> getStoredUser() async {
    final stored = await _storage.getUserData();
    if (stored == null || stored.isEmpty) return null;
    return UserResponse.fromJson(jsonDecode(stored) as Map<String, dynamic>);
  }

  Future<String> refreshToken() async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      throw const AppException('No active session found.');
    }
    await getCurrentUser();
    return token;
  }

  Future<bool> hasSession() async {
    final token = await _storage.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() => _storage.clearAll();

  Future<TokenResponse> _persistSession(TokenResponse token) async {
    await _storage.saveToken(token.accessToken, tokenType: token.tokenType);
    await _storage.saveUserData(jsonEncode(token.user.toJson()));
    return token;
  }

  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const AppException('Unexpected server response.');
  }
}
