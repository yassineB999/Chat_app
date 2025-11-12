import 'package:nexuschatfe/features/auth/data/data_sources/local/auth_local_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalServiceImpl implements AuthLocalService {
  static const _kTokenKey = 'token';

  @override
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTokenKey, token);
  }

  @override
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kTokenKey);
  }

  @override
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kTokenKey);
    return token != null && token.isNotEmpty;
  }

  @override
  Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_kTokenKey);
  }
}
