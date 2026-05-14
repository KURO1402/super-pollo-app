import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyAccess = 'accessToken';
  static const _keyRefresh = 'refreshToken';

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _keyAccess, value: accessToken);
    await _storage.write(key: _keyRefresh, value: refreshToken);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccess);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefresh);
  }

  static Future<bool> haySession() async {
    final refresh = await _storage.read(key: _keyRefresh);
    return refresh != null && refresh.isNotEmpty;
  }

  static Future<void> clearTokens() async {
    await _storage.deleteAll();
  }

  static Future<dynamic> getToken() async {}
}
