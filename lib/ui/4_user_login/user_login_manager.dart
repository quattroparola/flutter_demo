import 'package:flutter_demo/services/auth/auth.dart';
import 'package:flutter_demo/services/service_locator.dart';

class UserLoginManager {
  final _authService = getIt<Auth>();

  Future<bool> login({required String email, required String password}) async {
    return _authService.login(email: email, password: password);
  }

  Future<bool> signUp({required String email, required String password}) async {
    return _authService.signup(email: email, password: password);
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  Future<bool> isLoggedIn() async {
    return _authService.isLoggedIn();
  }
}
