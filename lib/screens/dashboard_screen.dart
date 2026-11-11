import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/blood_request.dart';
import '../models/donor.dart';
import '../providers/auth_provider.dart';
import '../providers/donor_provider.dart';
import '../providers/filter_provider.dart';
import '../providers/request_provider.dart';
import '../theme.dart';
import '../utils/formatters.dart';
import '../widgets/donor_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/urgency_badge.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onFindDonors;
  final VoidCallback onViewRequests;

  const DashboardScreen({
    super.key,
    required this.onFindDonors,
    required this.onViewRequests,
  });

  @override
  Widget build(BuildContext context) {
    final donorProvider = context.watch<DonorProvider>();
    final requestProvider = context.watch<RequestProvider>();
    final auth = context.watch<AuthProvider>();

    if (donorProvider.loading && donorProvider.donors.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (donorProvider.error != null && donorProvider.donors.isEmpty) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Something went wrong',
        message: donorProvider.error!,
        action: FilledButton(
          onPressed: donorProvider.loadDonors,
          child: const Text('Retry'),
        ),
      );
    }

    final dates = DateTime.now();
    final openRequests = requestProvider.openRequests.take(3).toList();
    final recentDonors = [...donorProvider.donors]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final recent = recentDonors.take(4).toList();

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          donorProvider.loadDonors(),
          requestProvider.loadRequests(),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Greeting(name: auth.displayName, date: dates),
          const SizedBox(height: 18),
          _HeroBanner(
            onFindDonors: onFindDonors,
            onViewRequests: onViewRequests,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.people,
                  value: '${donorProvider.totalDonors}',
                  label: 'Total donors',
                  color: AppTheme.bloodRed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.check_circle_outline,
                  value: '${donorProvider.availableCount}',
                  label: 'Available now',
                  color: AppTheme.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.water_drop_outlined,
                  value: '${requestProvider.openCount}',
                  label: 'Open requests',
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.location_city,
                  value: '${donorProvider.cityCount}',
                  label: 'Cities covered',
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Blood group availability',
            trailing: Text(
              'Available donors',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
          _AvailabilityGrid(
            counts: donorProvider.groupAvailability,
            onGroupTap: (group) {
              context.read<FilterProvider>().applyPreset(bloodGroup: group);
              onFindDonors();
            },
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Open blood requests',
            trailing: TextButton(
              onPressed: onViewRequests,
              child: const Text('View all'),
            ),
          ),
          if (openRequests.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppTheme.success),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('No open requests right now.')),
                  ],
                ),
              ),
            )
          else
            ...openRequests.map(
              (request) =>
                  _RequestPreviewCard(request: request, onTap: onViewRequests),
            ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Recently added donors',
            trailing: TextButton(
              onPressed: onFindDonors,
              child: const Text('Browse'),
            ),
          ),
          if (recent.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No donors yet. Add your first donor.'),
              ),
            )
          else
            ...recent.map(
              (donor) => DonorCard(donor: donor, showFavoriteButton: false),
            ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onFindDonors,
            icon: const Icon(Icons.search),
            label: const Text('Find a donor'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  final String name;
  final DateTime date;

  const _Greeting({required this.name, required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $name!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Every donation can save up to three lives.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Text(
                formatDate(date),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvailabilityGrid extends StatelessWidget {
  final Map<String, int> counts;
  final ValueChanged<String> onGroupTap;

  const _AvailabilityGrid({required this.counts, required this.onGroupTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kBloodGroups.map((group) {
        final count = counts[group] ?? 0;
        final color = AppTheme.bloodGroupColor(group);
        final active = count > 0;
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onGroupTap(group),
          child: Container(
            width: 72,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: active
                  ? color.withValues(alpha: 0.08)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active
                    ? color.withValues(alpha: 0.25)
                    : Colors.grey.shade200,
              ),
            ),
            child: Column(
              children: [
                Text(
                  group,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: active ? color : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count available',
                  style: TextStyle(fontSize: 9.5, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _RequestPreviewCard extends StatelessWidget {
  final BloodRequest request;
  final VoidCallback onTap;

  const _RequestPreviewCard({required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.bloodGroupColor(request.bloodGroup)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  request.bloodGroup,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.bloodGroupColor(request.bloodGroup),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            request.patientName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        UrgencyBadge(urgency: request.urgency),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${request.city} · ${request.units} '
                      '${request.units == 1 ? 'unit' : 'units'} · '
                      '${formatRelative(request.createdAt)}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final VoidCallback onFindDonors;
  final VoidCallback onViewRequests;

  const _HeroBanner({required this.onFindDonors, required this.onViewRequests});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB71C1C), Color(0xFFE53935), Color(0xFFEF5350)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.bloodRed.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned(
              right: -28,
              top: -42,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              right: 44,
              bottom: -58,
              child: Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.volunteer_activism_outlined,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'BE A LIFESAVER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your one donation\ncan mean everything.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      height: 1.18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connect with nearby donors and help someone get the blood they need.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: onFindDonors,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.darkRed,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.search, size: 18),
                        label: const Text('Find donors'),
                      ),
                      TextButton.icon(
                        onPressed: onViewRequests,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward, size: 17),
                        label: const Text('View requests'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
