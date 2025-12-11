abstract class AuthLocalService {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<bool> isLoggedIn();
  Future<bool> logout();

  // New methods for user data persistence
  Future<void> saveUserData(Map<String, dynamic> userData);
  Future<Map<String, dynamic>?> getUserData();
  Future<void> clearAll();
}
