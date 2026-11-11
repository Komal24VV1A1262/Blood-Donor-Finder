import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:blood_donar_finder/data/app_database.dart';
import 'package:blood_donar_finder/data/donor_repository.dart';
import 'package:blood_donar_finder/models/donor.dart';

void main() {
  sqfliteFfiInit();

  test('persists donors to a real file across close and reopen', () async {
    final dir = await Directory.systemTemp.createTemp('bloodlink_persist');
    final path = p.join(dir.path, 'blood_donor_finder.db');
    final now = DateTime(2026, 11, 10);

    final first = AppDatabase(factory: databaseFactoryFfiNoIsolate, path: path);
    final firstRepo = DonorRepository(first);
    await firstRepo.insert(
      Donor(
        id: 'persist-1',
        name: 'Persist Test',
        bloodGroup: 'O+',
        city: 'Delhi',
        phone: '+91 90000 00000',
        createdAt: now,
        updatedAt: now,
      ),
    );
    expect(File(path).existsSync(), isTrue);
    await first.close();

    final second = AppDatabase(factory: databaseFactoryFfiNoIsolate, path: path);
    final secondRepo = DonorRepository(second);
    final donors = await secondRepo.getAll();
    expect(donors.where((d) => d.id == 'persist-1'), hasLength(1));
    expect(donors.length, 15);
    await second.close();

    await dir.delete(recursive: true);
  });
}
