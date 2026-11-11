import 'package:flutter/foundation.dart';

import '../data/donor_repository.dart';
import '../models/blood_request.dart';
import '../models/donation.dart';
import '../models/donor.dart';
import '../utils/blood_compatibility.dart';

class DonorProvider extends ChangeNotifier {
  final DonorRepository _repository;

  List<Donor> _donors = const [];
  bool _loading = true;
  String? _error;

  DonorProvider(this._repository);

  List<Donor> get donors => List.unmodifiable(_donors);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadDonors() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _donors = await _repository.getAll();
    } catch (_) {
      _error = 'Could not load donors. Please try again.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> reload() async {
    _donors = await _repository.getAll();
    notifyListeners();
  }

  Donor? getById(String id) {
    for (final donor in _donors) {
      if (donor.id == id) return donor;
    }
    return null;
  }

  Future<void> addDonor(Donor donor) async {
    await _repository.insert(donor);
    await reload();
  }

  Future<void> updateDonor(Donor donor) async {
    await _repository.update(donor);
    await reload();
  }

  Future<void> deleteDonor(String id) async {
    await _repository.delete(id);
    await reload();
  }

  Future<void> toggleFavorite(Donor donor) async {
    await _repository.setFavorite(donor.id, !donor.isFavorite);
    await reload();
  }

  Future<List<Donation>> donationsFor(String donorId) {
    return _repository.getDonations(donorId);
  }

  Future<void> recordDonation({
    required String donorId,
    required DateTime donationDate,
    required int units,
    String? location,
    String? notes,
  }) async {
    await _repository.recordDonation(
      donorId: donorId,
      donationDate: donationDate,
      units: units,
      location: location,
      notes: notes,
    );
    await reload();
  }

  Future<void> deleteDonation(String donationId) async {
    await _repository.deleteDonation(donationId);
    await reload();
  }

  List<Donor> get eligibleDonors =>
      _donors.where((d) => d.isReadyToDonate).toList(growable: false);

  List<Donor> get favoriteDonors =>
      _donors.where((d) => d.isFavorite).toList(growable: false);

  int get totalDonors => _donors.length;
  int get availableCount => eligibleDonors.length;
  int get favoriteCount => favoriteDonors.length;

  int get cityCount {
    final cities = <String>{};
    for (final donor in _donors) {
      cities.add(donor.city.toLowerCase());
    }
    return cities.length;
  }

  int get cooldownCount =>
      _donors.where((d) => d.isAvailable && !d.isEligible).length;

  /// Number of eligible, available donors per blood group.
  Map<String, int> get groupAvailability {
    final counts = {for (final group in kBloodGroups) group: 0};
    for (final donor in _donors) {
      if (donor.isReadyToDonate) {
        counts[donor.bloodGroup] = (counts[donor.bloodGroup] ?? 0) + 1;
      }
    }
    return counts;
  }

  /// Donors compatible with a request, prioritising the same city.
  List<Donor> matchesFor(BloodRequest request) {
    final compatibleGroups =
        BloodCompatibility.compatibleDonorGroups(request.bloodGroup);
    final matches = _donors
        .where(
          (d) =>
              d.isReadyToDonate &&
              compatibleGroups.contains(d.bloodGroup),
        )
        .toList();

    matches.sort((a, b) {
      final aLocal = a.city.toLowerCase() == request.city.toLowerCase();
      final bLocal = b.city.toLowerCase() == request.city.toLowerCase();
      if (aLocal != bLocal) return aLocal ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return matches;
  }
}
