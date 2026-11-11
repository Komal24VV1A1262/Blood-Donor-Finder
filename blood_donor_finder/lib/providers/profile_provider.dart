import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_donor_finder/models/donor.dart';
import 'package:blood_donor_finder/providers/auth_provider.dart';
import 'package:blood_donor_finder/providers/donor_list_provider.dart';

final currentUserProfileProvider = Provider<Donor?>((ref) {
  final auth = ref.watch(authProvider).value;
  final email = auth?.email;
  if (email == null) return null;
  final donors = ref.watch(donorListProvider).value ?? <Donor>[];
  for (final d in donors) {
    if (d.id == email) return d;
  }
  return null;
});