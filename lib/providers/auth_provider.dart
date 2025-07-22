import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  // Expose Firebase user if needed
  get firebaseUser => _authService.currentUser;

  AuthProvider() {
    // Fetch user profile if already logged in
    if (_authService.currentUser != null) {
      fetchUserProfile();
    }
  }

  Future<String?> registerUser({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String address,
  }) async {
    try {
      final user = await _authService.registerUser(
        email: email,
        password: password,
      );
      if (user == null) return 'User registration failed';

      await _userService.saveUserProfile(
        userId: user.uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
      );
      await fetchUserProfile();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _authService.loginUser(email: email, password: password);
      await fetchUserProfile();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> fetchUserProfile() async {
    final user = _authService.currentUser;
    if (user != null) {
      final profile = await _userService.getUserProfile(user.uid);
      _userModel = profile;
      notifyListeners();
    }
  }

  Future<String?> updateUserProfile({
    required String name,
    required String phoneNumber,
    required String address,
  }) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return 'User not logged in';
      await _userService.saveUserProfile(
        userId: user.uid,
        name: name,
        email: user.email ?? '',
        phoneNumber: phoneNumber,
        address: address,
      );
      await fetchUserProfile();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _userModel = null;
    notifyListeners();
  }
}
