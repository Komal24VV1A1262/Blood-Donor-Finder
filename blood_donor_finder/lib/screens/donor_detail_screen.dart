import 'package:flutter/material.dart';
import 'package:blood_donor_finder/models/donor.dart';
import 'package:blood_donor_finder/widgets/blood_drop_badge.dart';

class DonorDetailScreen extends StatelessWidget {
  final Donor donor;

  const DonorDetailScreen({super.key, required this.donor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donor Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Center(
            child: Column(
              children: [
                BloodGroupBadge(bloodGroup: donor.bloodGroup, size: 80),
                const SizedBox(height: 16),
                Text(
                  donor.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  donor.city,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _DetailTile(icon: Icons.bloodtype, label: 'Blood Group', value: donor.bloodGroup),
          _DetailTile(icon: Icons.location_on_outlined, label: 'City', value: donor.city),
          _DetailTile(icon: Icons.phone_outlined, label: 'Phone', value: donor.phone),
          _DetailTile(icon: Icons.event_available_outlined, label: 'Last Donation', value: donor.lastDonationDate),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Call ${donor.name} at ${donor.phone}')),
              );
            },
            icon: const Icon(Icons.call),
            label: const Text('Contact Donor'),
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFE53935)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF212121)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}