import 'dart:io' as io;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_database.dart';
import '../providers/auth_provider.dart';
import '../providers/donor_provider.dart';
import '../providers/request_provider.dart';
import '../services/backup_service.dart';
import '../services/seed_data.dart';
import '../theme.dart';
import '../utils/formatters.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final donorProvider = context.watch<DonorProvider>();
    final requestProvider = context.watch<RequestProvider>();
    final user = auth.user;

    if (user == null) {
      return const Center(child: Text('Not signed in.'));
    }

    final isDemo = user.email == SeedData.demoEmail;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: AppTheme.bloodRed,
                  child: Text(
                    initialsOf(user.name),
                    style: const TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Member since ${formatDate(user.createdAt)}',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
                if (isDemo) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Demo account',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _MiniStat(
                  value: '${donorProvider.totalDonors}',
                  label: 'Donors',
                  color: AppTheme.bloodRed,
                ),
                _MiniStat(
                  value: '${donorProvider.availableCount}',
                  label: 'Available',
                  color: AppTheme.success,
                ),
                _MiniStat(
                  value: '${donorProvider.favoriteCount}',
                  label: 'Favorites',
                  color: Colors.amber.shade700,
                ),
                _MiniStat(
                  value: '${requestProvider.openCount}',
                  label: 'Requests',
                  color: Colors.indigo,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.info_outline,
                  color: AppTheme.bloodRed,
                ),
                title: const Text('About BloodLink'),
                subtitle: const Text(
                  'Connect blood donors with people who need them.',
                ),
                onTap: () => _showAbout(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(
                  Icons.health_and_safety_outlined,
                  color: AppTheme.bloodRed,
                ),
                title: const Text('Donation eligibility'),
                subtitle: const Text(
                  'Donors can donate again 90 days after their last donation.',
                ),
                onTap: () => _showEligibility(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(
                  Icons.storage_outlined,
                  color: AppTheme.bloodRed,
                ),
                title: const Text('Data storage'),
                subtitle: const Text(
                  'All records are stored locally in an SQLite database.',
                ),
                onTap: () => _showStorage(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(
                  Icons.refresh,
                  color: AppTheme.bloodRed,
                ),
                title: const Text('Refresh data'),
                onTap: () async {
                  await Future.wait([
                    donorProvider.loadDonors(),
                    requestProvider.loadRequests(),
                  ]);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data refreshed.')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.backup_outlined, color: AppTheme.bloodRed),
                title: const Text('Create backup'),
                subtitle: const Text('Save all BloodLink records to a JSON file.'),
                onTap: () => _createBackup(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.restore_outlined, color: AppTheme.bloodRed),
                title: const Text('Restore backup'),
                subtitle: const Text('Replace this device data from a backup file.'),
                onTap: () => _restoreBackup(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _logout(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          icon: const Icon(Icons.logout),
          label: const Text('Log out'),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'BloodLink v1.0.0',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Future<void> _createBackup(BuildContext context) async {
    try {
      final bytes = await BackupService(AppDatabase.instance).createBackup();
      final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final savedPath = await FilePicker.saveFile(
        dialogTitle: 'Save BloodLink backup',
        fileName: 'bloodlink_backup_$stamp.json',
        mimeType: 'application/json',
        bytes: bytes,
      );
      if (!context.mounted) return;
      if (savedPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup saved successfully.')),
        );
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create backup: $error')),
      );
    }
  }

  Future<void> _restoreBackup(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restore backup?'),
        content: const Text(
          'Restoring replaces all current BloodLink users, donors, donations, '
          'and requests on this device. Export a backup of current data first '
          'if you may need it. You will be logged out after restoration.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Choose backup'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final donorNotifier = context.read<DonorProvider>();
    final requestNotifier = context.read<RequestProvider>();
    final authNotifier = context.read<AuthProvider>();
    try {
      final files = await FilePicker.pickFiles(
        dialogTitle: 'Select BloodLink backup',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (files.isEmpty) return;
      final selectedPath = files.single.path;
      if (selectedPath == null) {
        throw const FormatException('The selected file path is unavailable.');
      }
      final bytes = await io.File(selectedPath).readAsBytes();

      final counts = await BackupService(
        AppDatabase.instance,
      ).restoreBackup(bytes);
      if (!context.mounted) return;

      await Future.wait([
        donorNotifier.loadDonors(),
        requestNotifier.loadRequests(),
      ]);
      await authNotifier.logout();

      if (!context.mounted) return;
      final total = counts.values.fold<int>(0, (sum, count) => sum + count);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup restored: $total records. Please sign in.'),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not restore backup: $error')),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You can sign back in at any time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<AuthProvider>().logout();
  }

  void _showAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About BloodLink'),
        content: const Text(
          'BloodLink helps you find and manage blood donors in your area, '
          'track donation history, and post blood requests. Donor matches '
          'follow standard blood group compatibility rules.\n\n'
          'Every donation can save up to three lives.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEligibility(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Donation eligibility'),
        content: const Text(
          'For whole blood donation, a minimum interval of about 90 days is '
          'recommended between donations. BloodLink uses this interval to '
          'show when a donor becomes eligible again.\n\n'
          'Always follow the guidance of a qualified medical professional.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showStorage(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data storage'),
        content: const Text(
          'Donors, donations, users and blood requests are stored in a local '
          'SQLite database on this device. Passwords are stored only as '
          'salted PBKDF2 hashes, never in plain text.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _MiniStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
