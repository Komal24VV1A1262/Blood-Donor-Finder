import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_donor_finder/models/donor.dart';
import 'package:blood_donor_finder/providers/donor_list_provider.dart';

class FilterState {
  final String searchText;
  final String? bloodGroup;

  const FilterState({
    this.searchText = '',
    this.bloodGroup,
  });

  FilterState copyWith({String? searchText, String? bloodGroup, bool clearBloodGroup = false}) {
    return FilterState(
      searchText: searchText ?? this.searchText,
      bloodGroup: clearBloodGroup ? null : (bloodGroup ?? this.bloodGroup),
    );
  }
}

class FilterNotifier extends Notifier<FilterState> {
  @override
  FilterState build() => const FilterState();

  void setSearchText(String value) {
    state = state.copyWith(searchText: value);
  }

  void setBloodGroup(String? group) {
    state = state.copyWith(bloodGroup: group, clearBloodGroup: group == null);
  }

  void clear() => state = const FilterState();
}

final filterProvider = NotifierProvider<FilterNotifier, FilterState>(
  FilterNotifier.new,
);

List<Donor> applyFilters(List<Donor> donors, FilterState filter) {
  final query = filter.searchText.trim().toLowerCase();
  return donors.where((d) {
    final matchesGroup = filter.bloodGroup == null || d.bloodGroup == filter.bloodGroup;
    if (!matchesGroup) return false;
    if (query.isEmpty) return true;
    return d.name.toLowerCase().contains(query) ||
        d.city.toLowerCase().contains(query);
  }).toList();
}

final filteredDonorsProvider = Provider<List<Donor>>((ref) {
  final donors = ref.watch(donorListProvider).value ?? <Donor>[];
  final filter = ref.watch(filterProvider);
  return applyFilters(donors, filter);
});