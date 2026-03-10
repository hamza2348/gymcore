class AuthService {
  static bool isLoggedIn = false;
  static Future<bool> login(String email, String pass) async {
    await Future.delayed(const Duration(milliseconds: 500));
    isLoggedIn = true;
    return true;
  }
  static void logout() { isLoggedIn = false; }
}
