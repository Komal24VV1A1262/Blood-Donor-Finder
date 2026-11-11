import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/app_database.dart';
import 'data/donor_repository.dart';
import 'data/request_repository.dart';
import 'data/user_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/donor_provider.dart';
import 'providers/filter_provider.dart';
import 'providers/request_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/session_store.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase.instance;
  final authService = AuthService(UserRepository(database), SessionStore());
  final donorRepository = DonorRepository(database);
  final requestRepository = RequestRepository(database);

  runApp(
    BloodDonorFinderApp(
      authService: authService,
      donorRepository: donorRepository,
      requestRepository: requestRepository,
    ),
  );
}

class BloodDonorFinderApp extends StatelessWidget {
  final AuthService authService;
  final DonorRepository donorRepository;
  final RequestRepository requestRepository;

  const BloodDonorFinderApp({
    super.key,
    required this.authService,
    required this.donorRepository,
    required this.requestRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService)..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => DonorProvider(donorRepository)..loadDonors(),
        ),
        ChangeNotifierProvider(
          create: (_) => RequestProvider(requestRepository)..loadRequests(),
        ),
        ChangeNotifierProvider(create: (_) => FilterProvider()),
      ],
      child: MaterialApp(
        title: 'BloodLink - Blood Donor Finder',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.initializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return auth.isAuthenticated ? const HomeScreen() : const LoginScreen();
  }
}
