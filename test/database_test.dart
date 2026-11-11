import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:blood_donar_finder/data/app_database.dart';
import 'package:blood_donar_finder/data/donor_repository.dart';
import 'package:blood_donar_finder/data/request_repository.dart';
import 'package:blood_donar_finder/data/user_repository.dart';
import 'package:blood_donar_finder/models/blood_request.dart';
import 'package:blood_donar_finder/models/donor.dart';
import 'package:blood_donar_finder/services/seed_data.dart';
import 'package:blood_donar_finder/utils/password_hasher.dart';

void main() {
  late AppDatabase database;
  late DonorRepository donors;
  late UserRepository users;
  late RequestRepository requests;

  setUp(() {
    database = AppDatabase(
      factory: databaseFactoryFfiNoIsolate,
      path: inMemoryDatabasePath,
    );
    donors = DonorRepository(database);
    users = UserRepository(database);
    requests = RequestRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('seeds donors, donations and the demo account', () async {
    expect(await donors.getAll(), hasLength(14));
    expect(await donors.totalDonationCount(), 6);
    expect(await users.count(), 1);

    final demo = await users.findByEmail(SeedData.demoEmail);
    expect(demo, isNotNull);
    expect(demo!.user.name, SeedData.demoName);
    expect(
      PasswordHasher.verify(
        SeedData.demoPassword,
        demo.passwordSalt,
        demo.passwordHash,
      ),
      isTrue,
    );
    expect(
      PasswordHasher.verify(
        'wrong-password',
        demo.passwordSalt,
        demo.passwordHash,
      ),
      isFalse,
    );
  });

  test('inserts, updates and deletes a donor', () async {
    final now = DateTime(2026, 11, 6);
    final donor = Donor(
      id: 'test-donor',
      name: 'Test Donor',
      bloodGroup: 'O+',
      city: 'Mumbai',
      phone: '+91 90000 00000',
      createdAt: now,
      updatedAt: now,
    );

    await donors.insert(donor);
    expect(await donors.getById('test-donor'), isNotNull);
    expect(await donors.getAll(), hasLength(15));

    await donors.update(
      donor.copyWith(name: 'Renamed Donor', isFavorite: true),
    );
    final updated = await donors.getById('test-donor');
    expect(updated!.name, 'Renamed Donor');
    expect(updated.isFavorite, isTrue);

    await donors.delete('test-donor');
    expect(await donors.getById('test-donor'), isNull);
    expect(await donors.getAll(), hasLength(14));
  });

  test('recording and deleting a donation keeps the donor in sync', () async {
    const donorId = 'seed-2';
    final donationDate = DateTime(2026, 10, 1);

    await donors.recordDonation(
      donorId: donorId,
      donationDate: donationDate,
      units: 2,
      location: 'Test Blood Bank',
    );

    expect((await donors.getById(donorId))!.lastDonationDate, donationDate);
    expect(await donors.totalDonationCount(), 7);

    final history = await donors.getDonations(donorId);
    expect(history, hasLength(1));
    expect(history.first.units, 2);

    await donors.deleteDonation(history.first.id);

    expect((await donors.getById(donorId))!.lastDonationDate, isNull);
    expect(await donors.getDonations(donorId), isEmpty);
    expect(await donors.totalDonationCount(), 6);
  });

  test('deleting the latest donation falls back to the previous one', () async {
    const donorId = 'seed-1';
    final history = await donors.getDonations(donorId);
    expect(history, hasLength(2));

    await donors.deleteDonation(history.first.id);

    final remaining = await donors.getDonations(donorId);
    expect(remaining, hasLength(1));
    expect(
      (await donors.getById(donorId))!.lastDonationDate,
      remaining.first.donationDate,
    );
  });

  test('creates and fulfils a blood request', () async {
    final request = BloodRequest(
      id: 'test-request',
      requesterName: 'Requester',
      patientName: 'Patient',
      bloodGroup: 'A+',
      city: 'Delhi',
      units: 2,
      contactPhone: '+91 90000 11111',
      urgency: RequestUrgency.critical,
      createdAt: DateTime(2026, 11, 6),
    );

    await requests.insert(request);
    final stored = await requests.getAll();
    expect(stored, hasLength(1));
    expect(stored.first.urgency, RequestUrgency.critical);
    expect(stored.first.isOpen, isTrue);

    await requests.updateStatus('test-request', RequestStatus.fulfilled);
    final fulfilled = (await requests.getAll()).first;
    expect(fulfilled.status, RequestStatus.fulfilled);
    expect(fulfilled.fulfilledAt, isNotNull);

    await requests.delete('test-request');
    expect(await requests.getAll(), isEmpty);
  });
}
