import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/donor_provider.dart';
import '../providers/filter_provider.dart';
import '../theme.dart';
import '../widgets/donor_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_chips.dart';
import '../widgets/search_field.dart';
import 'add_edit_donor_screen.dart';

class DonorListScreen extends StatefulWidget {
  const DonorListScreen({super.key});

  @override
  State<DonorListScreen> createState() => _DonorListScreenState();
}

class _DonorListScreenState extends State<DonorListScreen> {
  late final TextEditingController _searchController;
  late final FilterProvider _filter;

  @override
  void initState() {
    super.initState();
    _filter = context.read<FilterProvider>();
    _searchController = TextEditingController(text: _filter.query);
    _filter.addListener(_syncSearchFromFilter);
  }

  @override
  void dispose() {
    _filter.removeListener(_syncSearchFromFilter);
    _searchController.dispose();
    super.dispose();
  }

  void _syncSearchFromFilter() {
    if (_searchController.text == _filter.query) return;
    final text = _filter.query;
    _searchController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  Future<void> _openAddDonor() async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddEditDonorScreen()),
    );
    if (added == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donor added successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final donorProvider = context.watch<DonorProvider>();
    final filterProvider = context.watch<FilterProvider>();
    final cities = filterProvider.citiesFrom(donorProvider.donors);
    final filtered = filterProvider.apply(donorProvider.donors);

    if (donorProvider.loading && donorProvider.donors.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (donorProvider.error != null && donorProvider.donors.isEmpty) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Could not load donors',
        message: donorProvider.error!,
        action: FilledButton(
          onPressed: donorProvider.loadDonors,
          child: const Text('Retry'),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: SearchField(
              hint: 'Search by name, city, phone or email',
              controller: _searchController,
              onChanged: filterProvider.setQuery,
            ),
          ),
          FilterBar(cities: cities),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${filtered.length} donor${filtered.length == 1 ? '' : 's'} found',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (filterProvider.hasActiveFilters)
                  TextButton.icon(
                    onPressed: () {
                      filterProvider.clear();
                      _searchController.clear();
                    },
                    icon: const Icon(Icons.filter_alt_off, size: 16),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: AppTheme.bloodRed,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: donorProvider.loadDonors,
              child: filtered.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.5,
                          child: EmptyState(
                            icon: Icons.search_off,
                            title: 'No donors found',
                            message: filterProvider.hasActiveFilters
                                ? 'Try adjusting your search or filters.'
                                : 'Add your first donor to get started.',
                            action: filterProvider.hasActiveFilters
                                ? OutlinedButton(
                                    onPressed: () {
                                      filterProvider.clear();
                                      _searchController.clear();
                                    },
                                    child: const Text('Clear filters'),
                                  )
                                : FilledButton.icon(
                                    onPressed: _openAddDonor,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add donor'),
                                  ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 4, bottom: 90),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return DonorCard(donor: filtered[index]);
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add donor',
        onPressed: _openAddDonor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
