import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_donor_finder/theme.dart';
import 'package:blood_donor_finder/providers/auth_provider.dart';
import 'package:blood_donor_finder/screens/login_screen.dart';
import 'package:blood_donor_finder/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: BloodDonorFinderApp()));
}

class BloodDonorFinderApp extends ConsumerWidget {
  const BloodDonorFinderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Blood Donor Finder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: authState.when(
        loading: () => const _SplashScreen(),
        error: (error, _) => LoginScreen(errorMessage: error.toString()),
        data: (state) => state.isAuthenticated ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}