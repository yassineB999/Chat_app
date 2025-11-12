abstract class AuthLocalService {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<bool> isLoggedIn();
  Future<bool> logout();
}
