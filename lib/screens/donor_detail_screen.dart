import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/donation.dart';
import '../models/donor.dart';
import '../providers/donor_provider.dart';
import '../theme.dart';
import '../utils/formatters.dart';
import '../widgets/blood_group_badge.dart';
import '../widgets/section_header.dart';
import 'add_edit_donor_screen.dart';

class DonorDetailScreen extends StatefulWidget {
  final String donorId;

  const DonorDetailScreen({super.key, required this.donorId});

  @override
  State<DonorDetailScreen> createState() => _DonorDetailScreenState();
}

class _DonorDetailScreenState extends State<DonorDetailScreen> {
  late Future<List<Donation>> _donationsFuture;

  @override
  void initState() {
    super.initState();
    _reloadDonations();
  }

  void _reloadDonations() {
    _donationsFuture =
        context.read<DonorProvider>().donationsFor(widget.donorId);
  }

  Future<void> _refreshDonations() async {
    setState(_reloadDonations);
    await _donationsFuture;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DonorProvider>();
    final donor = provider.getById(widget.donorId);

    if (donor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Donor')),
        body: const Center(child: Text('This donor is no longer available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor details'),
        actions: [
          IconButton(
            tooltip: donor.isFavorite ? 'Remove favorite' : 'Add favorite',
            icon: Icon(
              donor.isFavorite ? Icons.star : Icons.star_border,
              color: donor.isFavorite ? Colors.amber.shade300 : Colors.white,
            ),
            onPressed: () => provider.toggleFavorite(donor),
          ),
          IconButton(
            tooltip: 'Delete donor',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(donor),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDonations,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ProfileHeader(donor: donor),
            const SizedBox(height: 14),
            _EligibilityCard(donor: donor),
            const SizedBox(height: 14),
            _ContactActions(donor: donor),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Details'),
            Card(
              child: Column(
                children: [
                  _InfoTile(
                    icon: Icons.bloodtype,
                    label: 'Blood group',
                    value: donor.bloodGroup,
                  ),
                  const Divider(height: 1),
                  _InfoTile(
                    icon: Icons.location_on_outlined,
                    label: 'City',
                    value: donor.city,
                  ),
                  const Divider(height: 1),
                  _InfoTile(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: donor.phone,
                  ),
                  const Divider(height: 1),
                  _InfoTile(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: donor.email ?? 'Not provided',
                  ),
                  const Divider(height: 1),
                  _InfoTile(
                    icon: Icons.event_outlined,
                    label: 'Last donation',
                    value: formatDate(donor.lastDonationDate),
                  ),
                  if (donor.notes != null && donor.notes!.isNotEmpty) ...[
                    const Divider(height: 1),
                    _InfoTile(
                      icon: Icons.notes,
                      label: 'Notes',
                      value: donor.notes!,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionHeader(
              title: 'Donation history',
              trailing: TextButton.icon(
                onPressed: () => _recordDonation(donor),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Record'),
              ),
            ),
            FutureBuilder<List<Donation>>(
              future: _donationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final donations = snapshot.data ?? const <Donation>[];
                if (donations.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.history,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text('No donations recorded yet.'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Card(
                  child: Column(
                    children: [
                      for (var i = 0; i < donations.length; i++) ...[
                        if (i > 0) const Divider(height: 1),
                        _DonationTile(
                          donation: donations[i],
                          onDelete: () =>
                              _deleteDonation(donations[i]),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _openEdit(donor),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit donor'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEdit(Donor donor) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddEditDonorScreen(donorId: donor.id),
      ),
    );
    if (updated == true && mounted) {
      _reloadDonations();
      setState(() {});
    }
  }

  Future<void> _confirmDelete(Donor donor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete donor?'),
        content: Text(
          'This removes ${donor.name} and all recorded donations.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await context.read<DonorProvider>().deleteDonor(donor.id);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete donor.')),
      );
    }
  }

  Future<void> _recordDonation(Donor donor) async {
    final draft = await showDialog<_DonationDraft>(
      context: context,
      builder: (_) => _RecordDonationDialog(lastDonation: donor.lastDonationDate),
    );
    if (draft == null || !mounted) return;

    try {
      await context.read<DonorProvider>().recordDonation(
            donorId: donor.id,
            donationDate: draft.date,
            units: draft.units,
            location: draft.location,
            notes: draft.notes,
          );
      if (!mounted) return;
      await _refreshDonations();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation recorded.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not record donation.')),
      );
    }
  }

  Future<void> _deleteDonation(Donation donation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete record?'),
        content: const Text('Remove this donation record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await context.read<DonorProvider>().deleteDonation(donation.id);
      if (!mounted) return;
      await _refreshDonations();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete record.')),
      );
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  final Donor donor;

  const _ProfileHeader({required this.donor});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            BloodGroupBadge(bloodGroup: donor.bloodGroup, size: 72),
            const SizedBox(height: 12),
            Text(
              donor.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 15,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 3),
                Text(
                  donor.city,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            if (donor.isFavorite) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, size: 15, color: Colors.amber.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'Favorite donor',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EligibilityCard extends StatelessWidget {
  final Donor donor;

  const _EligibilityCard({required this.donor});

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final IconData icon;
    late final String title;
    late final String subtitle;

    if (!donor.isAvailable) {
      color = Colors.grey;
      icon = Icons.pause_circle_outline;
      title = 'Currently unavailable';
      subtitle = 'This donor has marked themselves unavailable.';
    } else if (!donor.isEligible) {
      color = AppTheme.warning;
      icon = Icons.hourglass_bottom;
      title = 'On cooldown';
      subtitle =
          'Eligible again on ${formatDate(donor.nextEligibleDate)} '
          '(${donor.daysUntilEligible} days left).';
    } else {
      color = AppTheme.success;
      icon = Icons.check_circle_outline;
      title = 'Eligible to donate';
      subtitle = donor.lastDonationDate == null
          ? 'No previous donations recorded.'
          : 'Last donated on ${formatDate(donor.lastDonationDate)}.';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactActions extends StatelessWidget {
  final Donor donor;

  const _ContactActions({required this.donor});

  Future<void> _launch(BuildContext context, Uri uri, String fallback) async {
    try {
      final supported = await canLaunchUrl(uri);
      if (supported) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {
      // Fall through to the message below.
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(fallback)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final phone = donor.phone.replaceAll(RegExp(r'[^0-9+]'), '');
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.success,
            ),
            onPressed: () => _launch(
              context,
              Uri.parse('tel:$phone'),
              'Calling is not supported on this device.',
            ),
            icon: const Icon(Icons.phone),
            label: const Text('Call'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _launch(
              context,
              Uri.parse('sms:$phone'),
              'Messaging is not supported on this device.',
            ),
            icon: const Icon(Icons.message_outlined),
            label: const Text('Message'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: donor.email == null
                ? null
                : () => _launch(
                      context,
                      Uri.parse(
                        'mailto:${donor.email}'
                        '?subject=Blood%20donation%20request',
                      ),
                      'Email is not supported on this device.',
                    ),
            icon: const Icon(Icons.email_outlined),
            label: const Text('Email'),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.bloodRed, size: 22),
      title: Text(
        label,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _DonationTile extends StatelessWidget {
  final Donation donation;
  final VoidCallback onDelete;

  const _DonationTile({required this.donation, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.water_drop, color: AppTheme.bloodRed),
      title: Text(formatDate(donation.donationDate)),
      subtitle: Text(
        [
          '${donation.units} ${donation.units == 1 ? 'unit' : 'units'}',
          if (donation.location != null && donation.location!.isNotEmpty)
            donation.location!,
        ].join(' · '),
      ),
      trailing: IconButton(
        tooltip: 'Delete record',
        icon: const Icon(Icons.delete_outline, size: 20),
        onPressed: onDelete,
      ),
    );
  }
}

class _DonationDraft {
  final DateTime date;
  final int units;
  final String? location;
  final String? notes;

  const _DonationDraft({
    required this.date,
    required this.units,
    this.location,
    this.notes,
  });
}

class _RecordDonationDialog extends StatefulWidget {
  final DateTime? lastDonation;

  const _RecordDonationDialog({this.lastDonation});

  @override
  State<_RecordDonationDialog> createState() =>
      _RecordDonationDialogState();
}

class _RecordDonationDialogState extends State<_RecordDonationDialog> {
  late DateTime _date;
  int _units = 1;
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: now,
      helpText: 'Donation date',
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Record donation'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Donation date',
                  prefixIcon: Icon(Icons.event_outlined),
                ),
                child: Text(formatDate(_date)),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _units,
              decoration: const InputDecoration(
                labelText: 'Units donated',
                prefixIcon: Icon(Icons.water_drop_outlined),
              ),
              items: const [1, 2, 3, 4]
                  .map(
                    (units) => DropdownMenuItem(
                      value: units,
                      child: Text('$units unit${units == 1 ? '' : 's'}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _units = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location (optional)',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final location = _locationController.text.trim();
            final notes = _notesController.text.trim();
            Navigator.of(context).pop(
              _DonationDraft(
                date: _date,
                units: _units,
                location: location.isEmpty ? null : location,
                notes: notes.isEmpty ? null : notes,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
