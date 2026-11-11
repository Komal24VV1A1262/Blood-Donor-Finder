import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_donor_finder/models/donor.dart';
import 'package:blood_donor_finder/providers/auth_provider.dart';
import 'package:blood_donor_finder/providers/profile_provider.dart';
import 'package:blood_donor_finder/screens/add_edit_donor_screen.dart';
import 'package:blood_donor_finder/theme.dart';
import 'package:blood_donor_finder/widgets/blood_drop_badge.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider).value;
    final email = auth?.email ?? '';
    final profile = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Center(
            child: Column(
              children: [
                const Icon(Icons.account_circle, size: 80, color: AppColors.primary),
                const SizedBox(height: 12),
                Text(email, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (profile == null)
            _NoProfileCard(onCreate: () => _openEditor(context, null))
          else
            _ProfileCard(profile: profile, onEdit: () => _openEditor(context, profile)),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryDark,
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _openEditor(BuildContext context, Donor? donor) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditDonorScreen(donor: donor)),
    );
  }
}

class _NoProfileCard extends StatelessWidget {
  final VoidCallback onCreate;

  const _NoProfileCard({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.person_add_alt_1, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            const Text(
              'No profile yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Create your donor profile so others can find you.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onCreate,
              child: const Text('Create Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final Donor profile;
  final VoidCallback onEdit;

  const _ProfileCard({required this.profile, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                BloodGroupBadge(bloodGroup: profile.bloodGroup),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    profile.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ProfileRow(icon: Icons.bloodtype_outlined, label: 'Blood Group', value: profile.bloodGroup),
            _ProfileRow(icon: Icons.location_city_outlined, label: 'City', value: profile.city),
            _ProfileRow(icon: Icons.phone_outlined, label: 'Phone', value: profile.phone),
            _ProfileRow(icon: Icons.event_outlined, label: 'Last Donation', value: profile.lastDonationDate),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onEdit,
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}