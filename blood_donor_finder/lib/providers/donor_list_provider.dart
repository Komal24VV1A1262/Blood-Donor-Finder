import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_donor_finder/models/donor.dart';
import 'package:blood_donor_finder/providers/service_providers.dart';
import 'package:blood_donor_finder/services/seed_data.dart';

class DonorListNotifier extends AsyncNotifier<List<Donor>> {
  @override
  Future<List<Donor>> build() async {
    final storage = ref.read(storageServiceProvider);
    var donors = await storage.loadDonors();
    if (donors.isEmpty) {
      donors = SeedData.donors();
      await storage.saveDonors(donors);
    }
    return donors;
  }

  Future<void> addDonor(Donor donor) async {
    final storage = ref.read(storageServiceProvider);
    final current = await future;
    await storage.saveDonors([...current, donor]);
    state = AsyncData([...current, donor]);
  }

  Future<void> updateDonor(Donor donor) async {
    final storage = ref.read(storageServiceProvider);
    final current = await future;
    final updated = current
        .map((d) => d.id == donor.id ? donor : d)
        .toList();
    await storage.saveDonors(updated);
    state = AsyncData(updated);
  }

  Future<void> deleteDonor(String id) async {
    final storage = ref.read(storageServiceProvider);
    final current = await future;
    final updated = current.where((d) => d.id != id).toList();
    await storage.saveDonors(updated);
    state = AsyncData(updated);
  }
}

final donorListProvider = AsyncNotifierProvider<DonorListNotifier, List<Donor>>(
  DonorListNotifier.new,
);