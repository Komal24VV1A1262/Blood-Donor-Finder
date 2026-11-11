import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donar_finder/models/donor.dart';
import 'package:blood_donar_finder/providers/filter_provider.dart';
import 'package:blood_donar_finder/utils/blood_compatibility.dart';
import 'package:blood_donar_finder/utils/password_hasher.dart';

Donor _donor({
  required String id,
  required String name,
  required String bloodGroup,
  required String city,
  DateTime? lastDonationDate,
  bool isAvailable = true,
  bool isFavorite = false,
}) {
  final now = DateTime(2026, 1, 1);
  return Donor(
    id: id,
    name: name,
    bloodGroup: bloodGroup,
    city: city,
    phone: '+91 98200 12345',
    email: '$id@example.com',
    lastDonationDate: lastDonationDate,
    isAvailable: isAvailable,
    isFavorite: isFavorite,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('BloodCompatibility', () {
    test('O- is a universal donor', () {
      expect(BloodCompatibility.canDonate('O-', 'AB+'), isTrue);
      expect(
        BloodCompatibility.canDonateTo('O-').length,
        kBloodGroups.length,
      );
    });

    test('AB+ is a universal recipient', () {
      expect(
        BloodCompatibility.compatibleDonorGroups('AB+').length,
        kBloodGroups.length,
      );
    });

    test('A+ recipient can receive from A+, A-, O+, O- only', () {
      expect(
        BloodCompatibility.compatibleDonorGroups('A+'),
        ['A+', 'A-', 'O+', 'O-'],
      );
    });

    test('AB+ donor can only donate to AB+', () {
      expect(BloodCompatibility.canDonateTo('AB+'), ['AB+']);
    });

    test('rejects incompatible combinations', () {
      expect(BloodCompatibility.canDonate('A+', 'B+'), isFalse);
      expect(BloodCompatibility.canDonate('B+', 'A-'), isFalse);
    });
  });

  group('Donor eligibility', () {
    final now = DateTime(2026, 6, 1);

    test('donor with no previous donation is eligible', () {
      final donor = _donor(
        id: '1',
        name: 'Aarav',
        bloodGroup: 'O+',
        city: 'Mumbai',
      );
      expect(donor.isEligibleAt(now), isTrue);
      expect(donor.isReadyToDonate, isTrue);
    });

    test('donor inside the 90 day window is not eligible', () {
      final donor = _donor(
        id: '2',
        name: 'Priya',
        bloodGroup: 'A+',
        city: 'Delhi',
        lastDonationDate: now.subtract(const Duration(days: 60)),
      );
      expect(donor.isEligibleAt(now), isFalse);
      expect(donor.daysUntilEligibleAt(now), 30);
    });

    test('donor past the 90 day window is eligible', () {
      final donor = _donor(
        id: '3',
        name: 'Rahul',
        bloodGroup: 'B+',
        city: 'Pune',
        lastDonationDate: now.subtract(const Duration(days: 100)),
      );
      expect(donor.isEligibleAt(now), isTrue);
    });

    test('unavailable donor is not ready even if eligible', () {
      final donor = _donor(
        id: '4',
        name: 'Sneha',
        bloodGroup: 'O-',
        city: 'Hyderabad',
        isAvailable: false,
      );
      expect(donor.isEligible, isTrue);
      expect(donor.isReadyToDonate, isFalse);
    });
  });

  group('FilterProvider', () {
    final donors = [
      _donor(
        id: '1',
        name: 'Aarav',
        bloodGroup: 'O+',
        city: 'Mumbai',
        isFavorite: true,
      ),
      _donor(id: '2', name: 'Priya', bloodGroup: 'A+', city: 'Delhi'),
      _donor(
        id: '3',
        name: 'Rahul',
        bloodGroup: 'O+',
        city: 'Mumbai',
        isFavorite: true,
      ),
      _donor(
        id: '4',
        name: 'Meera',
        bloodGroup: 'AB-',
        city: 'Kochi',
        isAvailable: false,
      ),
    ];

    test('returns all donors with no filters', () {
      final filter = FilterProvider();
      expect(filter.apply(donors).length, 4);
    });

    test('filters by blood group', () {
      final filter = FilterProvider()..setBloodGroup('O+');
      final result = filter.apply(donors);
      expect(result.length, 2);
      expect(result.every((d) => d.bloodGroup == 'O+'), isTrue);
    });

    test('filters by city', () {
      final filter = FilterProvider()..setCity('Mumbai');
      final result = filter.apply(donors);
      expect(result.length, 2);
      expect(result.every((d) => d.city == 'Mumbai'), isTrue);
    });

    test('filters by search query', () {
      final filter = FilterProvider()..setQuery('priya');
      final result = filter.apply(donors);
      expect(result.length, 1);
      expect(result.first.name, 'Priya');
    });

    test('filters by favorites', () {
      final filter = FilterProvider()..setFavoritesOnly(true);
      final result = filter.apply(donors);
      expect(result.length, 2);
      expect(result.every((d) => d.isFavorite), isTrue);
    });

    test('filters by available only', () {
      final filter = FilterProvider()..setAvailableOnly(true);
      final result = filter.apply(donors);
      expect(result.length, 3);
      expect(result.any((d) => d.id == '4'), isFalse);
    });

    test('filters by compatibility', () {
      final filter = FilterProvider()..setCompatibleWith('A+');
      final result = filter.apply(donors);
      expect(
        result.map((d) => d.bloodGroup).toSet(),
        {'O+', 'A+'},
      );
    });

    test('clear resets every filter', () {
      final filter = FilterProvider()
        ..setQuery('Mumbai')
        ..setBloodGroup('O+')
        ..setCity('Mumbai')
        ..setFavoritesOnly(true);
      expect(filter.hasActiveFilters, isTrue);
      filter.clear();
      expect(filter.hasActiveFilters, isFalse);
      expect(filter.apply(donors).length, 4);
    });

    test('citiesFrom lists unique sorted cities', () {
      final filter = FilterProvider();
      expect(filter.citiesFrom(donors), ['Delhi', 'Kochi', 'Mumbai']);
    });
  });

  group('PasswordHasher', () {
    test('verifies the original password', () {
      final hash = PasswordHasher.create('s3cret!');
      expect(
        PasswordHasher.verify('s3cret!', hash.salt, hash.hash),
        isTrue,
      );
    });

    test('rejects a wrong password', () {
      final hash = PasswordHasher.create('s3cret!');
      expect(
        PasswordHasher.verify('wrong', hash.salt, hash.hash),
        isFalse,
      );
    });

    test('uses a unique salt for every hash', () {
      final first = PasswordHasher.create('same-password');
      final second = PasswordHasher.create('same-password');
      expect(first.salt, isNot(second.salt));
      expect(first.hash, isNot(second.hash));
    });
  });

  group('kBloodGroups', () {
    test('contains all standard blood groups', () {
      expect(kBloodGroups, [
        'A+',
        'A-',
        'B+',
        'B-',
        'AB+',
        'AB-',
        'O+',
        'O-',
      ]);
    });
  });
}
