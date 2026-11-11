import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_donor_finder/services/storage_service.dart';
import 'package:blood_donor_finder/services/auth_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

final authServiceProvider = Provider<AuthService>((ref) => AuthService());