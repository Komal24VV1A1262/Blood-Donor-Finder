import 'package:uuid/uuid.dart';

import '../data/user_repository.dart';
import '../models/app_user.dart';
import '../utils/password_hasher.dart';
import 'seed_data.dart';
import 'session_store.dart';

/// Handles authentication and session persistence.
///
/// Passwords are verified against a PBKDF2 hash; the session stores only the
/// user id.
class AuthService {
  final UserRepository _users;
  final SessionStore _session;

  AppUser? _currentUser;

  AuthService(this._users, this._session);

  AppUser? get currentUser => _currentUser;

  Future<AppUser?> restoreSession() async {
    final userId = await _session.readUserId();
    if (userId == null) return null;

    final user = await _users.findById(userId);
    if (user == null) {
      await _session.clear();
      return null;
    }
    _currentUser = user;
    return user;
  }

  Future<String?> login(String email, String password) async {
    final normalized = email.trim().toLowerCase();
    final record = await _users.findByEmail(normalized);
    if (record == null) {
      return 'No account found with this email.';
    }
    final valid = PasswordHasher.verify(
      password,
      record.passwordSalt,
      record.passwordHash,
    );
    if (!valid) {
      return 'Incorrect password. Please try again.';
    }
    _currentUser = record.user;
    await _session.saveUserId(record.user.id);
    return null;
  }

  Future<String?> register(
    String name,
    String email,
    String password,
  ) async {
    final normalized = email.trim().toLowerCase();
    final existing = await _users.findByEmail(normalized);
    if (existing != null) {
      return 'An account with this email already exists.';
    }

    final credentials = PasswordHasher.create(password);
    final user = AppUser(
      id: const Uuid().v4(),
      name: name.trim(),
      email: normalized,
      createdAt: DateTime.now(),
    );
    await _users.insertUser(
      user: user,
      passwordHash: credentials.hash,
      passwordSalt: credentials.salt,
    );
    _currentUser = user;
    await _session.saveUserId(user.id);
    return null;
  }

  Future<String?> loginWithDemoAccount() {
    return login(SeedData.demoEmail, SeedData.demoPassword);
  }

  Future<void> logout() async {
    _currentUser = null;
    await _session.clear();
  }
}
