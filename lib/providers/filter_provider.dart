import 'package:flutter/foundation.dart';

import '../models/donor.dart';
import '../utils/blood_compatibility.dart';

class FilterProvider extends ChangeNotifier {
  String _query = '';
  String _bloodGroup = '';
  String _city = '';
  String _compatibleWith = '';
  bool _availableOnly = false;
  bool _favoritesOnly = false;

  String get query => _query;
  String get bloodGroup => _bloodGroup;
  String get city => _city;
  String get compatibleWith => _compatibleWith;
  bool get availableOnly => _availableOnly;
  bool get favoritesOnly => _favoritesOnly;

  bool get hasActiveFilters =>
      _query.isNotEmpty ||
      _bloodGroup.isNotEmpty ||
      _city.isNotEmpty ||
      _compatibleWith.isNotEmpty ||
      _availableOnly ||
      _favoritesOnly;

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void setBloodGroup(String value) {
    if (_bloodGroup == value) return;
    _bloodGroup = value;
    notifyListeners();
  }

  void setCity(String value) {
    if (_city == value) return;
    _city = value;
    notifyListeners();
  }

  void setCompatibleWith(String value) {
    if (_compatibleWith == value) return;
    _compatibleWith = value;
    notifyListeners();
  }

  void setAvailableOnly(bool value) {
    if (_availableOnly == value) return;
    _availableOnly = value;
    notifyListeners();
  }

  void setFavoritesOnly(bool value) {
    if (_favoritesOnly == value) return;
    _favoritesOnly = value;
    notifyListeners();
  }

  void clear() {
    if (!hasActiveFilters) return;
    _query = '';
    _bloodGroup = '';
    _city = '';
    _compatibleWith = '';
    _availableOnly = false;
    _favoritesOnly = false;
    notifyListeners();
  }

  void applyPreset({
    String? bloodGroup,
    String? city,
    String? compatibleWith,
    bool availableOnly = true,
  }) {
    _query = '';
    _bloodGroup = bloodGroup ?? '';
    _city = city ?? '';
    _compatibleWith = compatibleWith ?? '';
    _availableOnly = availableOnly;
    _favoritesOnly = false;
    notifyListeners();
  }

  List<Donor> apply(List<Donor> donors) {
    final normalizedQuery = _query.trim().toLowerCase();
    final compatibleGroups = _compatibleWith.isEmpty
        ? null
        : BloodCompatibility.compatibleDonorGroups(_compatibleWith);

    final results = donors.where((donor) {
      final matchesQuery = normalizedQuery.isEmpty ||
          donor.name.toLowerCase().contains(normalizedQuery) ||
          donor.city.toLowerCase().contains(normalizedQuery) ||
          donor.phone
              .replaceAll(' ', '')
              .contains(normalizedQuery.replaceAll(' ', '')) ||
          (donor.email?.toLowerCase().contains(normalizedQuery) ?? false);

      final matchesGroup =
          _bloodGroup.isEmpty || donor.bloodGroup == _bloodGroup;
      final matchesCity =
          _city.isEmpty || donor.city.toLowerCase() == _city.toLowerCase();
      final matchesAvailability = !_availableOnly || donor.isReadyToDonate;
      final matchesFavorite = !_favoritesOnly || donor.isFavorite;
      final matchesCompatibility =
          compatibleGroups == null || compatibleGroups.contains(donor.bloodGroup);

      return matchesQuery &&
          matchesGroup &&
          matchesCity &&
          matchesAvailability &&
          matchesFavorite &&
          matchesCompatibility;
    }).toList();

    results.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return results;
  }

  List<String> citiesFrom(List<Donor> donors) {
    final cities = <String>{};
    for (final donor in donors) {
      cities.add(donor.city);
    }
    final list = cities.toList()..sort();
    return list;
  }
}
