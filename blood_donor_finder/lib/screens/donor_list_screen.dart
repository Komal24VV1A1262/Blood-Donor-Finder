import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_donor_finder/providers/filter_provider.dart';
import 'package:blood_donor_finder/providers/donor_list_provider.dart';
import 'package:blood_donor_finder/services/seed_data.dart';
import 'package:blood_donor_finder/widgets/donor_card.dart';
import 'package:blood_donor_finder/widgets/search_field.dart';
import 'package:blood_donor_finder/widgets/filter_chips.dart';
import 'package:blood_donor_finder/theme.dart';
import 'package:blood_donor_finder/screens/donor_detail_screen.dart';

class DonorListScreen extends ConsumerStatefulWidget {
  const DonorListScreen({super.key});

  @override
  ConsumerState<DonorListScreen> createState() => _DonorListScreenState();
}

class _DonorListScreenState extends ConsumerState<DonorListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final donorsAsync = ref.watch(donorListProvider);
    final filter = ref.watch(filterProvider);
    final filtered = ref.watch(filteredDonorsProvider);
    final filterNotifier = ref.read(filterProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Find Donors')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: SearchField(
              controller: _searchController,
              onChanged: filterNotifier.setSearchText,
            ),
          ),
          BloodGroupFilterChips(
            bloodGroups: SeedData.bloodGroups,
            selectedGroup: filter.bloodGroup,
            onSelected: filterNotifier.setBloodGroup,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: donorsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Failed to load donors: $error')),
              data: (donors) {
                if (donors.isEmpty) {
                  return const _NoDonorsView();
                }
                if (filtered.isEmpty) {
                  return const _NoMatchesView();
                }
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(donorListProvider.future),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final donor = filtered[index];
                      return DonorCard(
                        donor: donor,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DonorDetailScreen(donor: donor),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NoDonorsView extends StatelessWidget {
  const _NoDonorsView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No donors yet. Create your profile to get started.'),
    );
  }
}

class _NoMatchesView extends StatelessWidget {
  const _NoMatchesView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          const Text('No donors match your search', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            'Try a different blood group or city.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}