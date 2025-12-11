import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nexuschatfe/features/auth/data/data_sources/local/auth_local_service.dart';

class AuthLocalServiceImpl implements AuthLocalService {
  static const _kTokenKey = 'auth_token';
  static const _kUserDataKey = 'user_data';

  // Use encrypted shared preferences on Android for better security
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(key: _kTokenKey, value: token);
    print('🔐 Token saved to secure storage');
  }

  @override
  Future<String?> getToken() async {
    final token = await _storage.read(key: _kTokenKey);
    print(
      '🔐 Token retrieved from secure storage: ${token != null ? 'exists' : 'null'}',
    );
    return token;
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<bool> logout() async {
    await _storage.delete(key: _kTokenKey);
    await _storage.delete(key: _kUserDataKey);
    print('🔐 Cleared auth data from secure storage');
    return true;
  }

  @override
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final jsonString = jsonEncode(userData);
    await _storage.write(key: _kUserDataKey, value: jsonString);
    print('🔐 User data saved to secure storage');
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    final jsonString = await _storage.read(key: _kUserDataKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final data = jsonDecode(jsonString) as Map<String, dynamic>;
        print('🔐 User data retrieved from secure storage');
        return data;
      } catch (e) {
        print('🔐 Error parsing user data: $e');
        return null;
      }
    }
    print('🔐 No user data found in secure storage');
    return null;
  }

  @override
  Future<void> clearAll() async {
    await _storage.deleteAll();
    print('🔐 Cleared ALL data from secure storage');
  }
}
