import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:blood_donar_finder/data/app_database.dart';
import 'package:blood_donar_finder/services/backup_service.dart';

void main() {
  late AppDatabase database;
  late BackupService backups;

  setUp(() {
    database = AppDatabase(
      factory: databaseFactoryFfiNoIsolate,
      path: inMemoryDatabasePath,
    );
    backups = BackupService(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('exports and restores all local tables', () async {
    final db = await database.database;
    final originalDonors = await db.query('donors');
    final originalDonations = await db.query('donations');
    final originalUsers = await db.query('users');

    final backup = await backups.createBackup();
    final decoded = jsonDecode(utf8.decode(backup)) as Map<String, dynamic>;
    expect(decoded['app'], 'BloodLink');
    expect(decoded['formatVersion'], 1);

    await db.delete('donations');
    await db.delete('donors');
    await db.delete('requests');
    await db.delete('users');

    final restoredCounts = await backups.restoreBackup(backup);

    expect(restoredCounts['donors'], originalDonors.length);
    expect(restoredCounts['donations'], originalDonations.length);
    expect(restoredCounts['users'], originalUsers.length);
    expect(await db.query('donors'), originalDonors);
    expect(await db.query('donations'), originalDonations);
    expect(await db.query('users'), originalUsers);
  });

  test('rejects an invalid backup without changing local data', () async {
    final db = await database.database;
    final before = await db.query('donors');

    await expectLater(
      backups.restoreBackup(
        utf8.encode('{"app":"OtherApp","formatVersion":1,"tables":{}}'),
      ),
      throwsFormatException,
    );

    expect(await db.query('donors'), before);
  });
}
