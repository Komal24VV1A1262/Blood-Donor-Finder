import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/blood_request.dart';
import '../providers/donor_provider.dart';
import '../theme.dart';
import '../utils/blood_compatibility.dart';
import '../widgets/donor_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/urgency_badge.dart';

class DonorMatchesScreen extends StatelessWidget {
  final BloodRequest request;

  const DonorMatchesScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final donorProvider = context.watch<DonorProvider>();
    final matches = donorProvider.matchesFor(request);
    final compatibleGroups =
        BloodCompatibility.compatibleDonorGroups(request.bloodGroup);

    return Scaffold(
      appBar: AppBar(title: const Text('Matching donors')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
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
                            color: AppTheme.bloodGroupColor(
                              request.bloodGroup,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'For ${request.patientName}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${request.city} · ${request.units} '
                              '${request.units == 1 ? 'unit' : 'units'} needed',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      UrgencyBadge(urgency: request.urgency),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Compatible donor groups',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: compatibleGroups
                        .map(
                          (group) => Chip(
                            label: Text(
                              group,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.bloodGroupColor(group),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: AppTheme.bloodGroupColor(group)
                                .withValues(alpha: 0.1),
                            side: BorderSide(
                              color: AppTheme.bloodGroupColor(group)
                                  .withValues(alpha: 0.25),
                            ),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${matches.length} eligible donor'
                    '${matches.length == 1 ? '' : 's'} found. '
                    'Donors in ${request.city} are listed first.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (matches.isEmpty)
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.4,
              child: const EmptyState(
                icon: Icons.search_off,
                title: 'No eligible matches',
                message:
                    'No available donors match this request right now. '
                    'Try again later or widen the city.',
              ),
            )
          else
            ...matches.map((donor) => DonorCard(donor: donor)),
        ],
      ),
    );
  }
}
