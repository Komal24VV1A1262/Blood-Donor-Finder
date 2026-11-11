import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _auth;

  bool _initializing = true;
  String? _error;

  AuthProvider(this._auth);

  bool get initializing => _initializing;
  AppUser? get user => _auth.currentUser;
  bool get isAuthenticated => user != null;
  String? get error => _error;
  String get displayName => user?.firstName ?? 'there';

  Future<void> initialize() async {
    _initializing = true;
    notifyListeners();
    try {
      await _auth.restoreSession();
    } catch (_) {
      _error = 'Could not restore your session.';
    }
    _initializing = false;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    _error = null;
    try {
      final error = await _auth.login(email, password);
      if (error != null) _error = error;
      notifyListeners();
      return error;
    } catch (_) {
      _error = 'Unable to sign in right now. Please try again.';
      notifyListeners();
      return _error;
    }
  }

  Future<String?> register(
    String name,
    String email,
    String password,
  ) async {
    _error = null;
    try {
      final error = await _auth.register(name, email, password);
      if (error != null) _error = error;
      notifyListeners();
      return error;
    } catch (_) {
      _error = 'Unable to create your account. Please try again.';
      notifyListeners();
      return _error;
    }
  }

  Future<String?> loginWithDemoAccount() async {
    _error = null;
    try {
      final error = await _auth.loginWithDemoAccount();
      if (error != null) _error = error;
      notifyListeners();
      return error;
    } catch (_) {
      _error = 'Unable to open the demo account. Please try again.';
      notifyListeners();
      return _error;
    }
  }

  Future<void> logout() async {
    await _auth.logout();
    _error = null;
    notifyListeners();
  }
}
