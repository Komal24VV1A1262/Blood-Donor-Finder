class AuthResult {
  final bool success;
  final String? error;

  const AuthResult.success() : success = true, error = null;
  const AuthResult.failure(this.error) : success = false;
}

class AuthService {
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (email.trim().isEmpty || !email.contains('@')) {
      return const AuthResult.failure('Please enter a valid email address.');
    }
    if (password.length < 6) {
      return const AuthResult.failure('Password must be at least 6 characters.');
    }
    return const AuthResult.success();
  }

  Future<AuthResult> validateProfile({
    required String name,
    required String bloodGroup,
    required String city,
    required String phone,
  }) async {
    if (name.trim().isEmpty) {
      return const AuthResult.failure('Name is required.');
    }
    if (bloodGroup.isEmpty) {
      return const AuthResult.failure('Please select a blood group.');
    }
    if (city.trim().isEmpty) {
      return const AuthResult.failure('City is required.');
    }

    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 10) {
      return const AuthResult.failure('Please enter a valid phone number (at least 10 digits).');
    }
    return const AuthResult.success();
  }
}