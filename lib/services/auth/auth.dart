/// Temporary placeholder while Firebase auth is disabled.
class Auth {
  Future<void> init() async {}

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    return false;
  }

  Future<bool> signup({
    required String email,
    required String password,
  }) async {
    return false;
  }

  Future<void> logout() async {}

  bool isLoggedIn() {
    return false;
  }
}
