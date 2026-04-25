import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';

final storageServiceProvider =
    Provider<StorageService>((ref) => StorageService());

class StorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveToken(String token, {String tokenType = 'bearer'}) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
    await _storage.write(key: AppConstants.tokenTypeKey, value: tokenType);
  }

  Future<String?> getToken() => _storage.read(key: AppConstants.tokenKey);

  Future<String?> getTokenType() =>
      _storage.read(key: AppConstants.tokenTypeKey);

  Future<void> deleteToken() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.tokenTypeKey);
  }

  Future<void> saveUserData(String jsonStr) =>
      _storage.write(key: AppConstants.userKey, value: jsonStr);

  Future<String?> getUserData() => _storage.read(key: AppConstants.userKey);

  Future<void> clearAll() => _storage.deleteAll();
}
