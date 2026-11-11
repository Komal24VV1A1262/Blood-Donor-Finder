import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_donor_finder/providers/service_providers.dart';

class AuthState {
  final String? email;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.email,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  const AuthState.loading()
      : email = null,
        isAuthenticated = false,
        isLoading = true,
        error = null;

  const AuthState.unauthenticated()
      : email = null,
        isAuthenticated = false,
        isLoading = false,
        error = null;

  const AuthState.authenticated(String this.email)
      : isAuthenticated = true,
        isLoading = false,
        error = null;

  AuthState copyWith({String? error}) {
    return AuthState(
      email: email,
      isAuthenticated: isAuthenticated,
      isLoading: isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final storage = ref.read(storageServiceProvider);
    final session = await storage.loadSession();
    if (session != null && session.isNotEmpty) {
      return AuthState.authenticated(session);
    }
    return const AuthState.unauthenticated();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    final auth = ref.read(authServiceProvider);
    final result = await auth.login(email: email, password: password);
    if (!result.success) {
      state = AsyncValue.error(result.error ?? 'Login failed', StackTrace.current);
      return;
    }
    await ref.read(storageServiceProvider).saveSession(email.trim());
    state = AsyncData(AuthState.authenticated(email.trim()));
  }

  Future<void> logout() async {
    await ref.read(storageServiceProvider).clearSession();
    state = const AsyncData(AuthState.unauthenticated());
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final authEmailProvider = Provider<String?>((ref) {
  final state = ref.watch(authProvider).value;
  return state?.email;
});