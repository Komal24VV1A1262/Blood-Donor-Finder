import 'package:sqflite_common_ffi/sqflite_ffi.dart' show ConflictAlgorithm;
import 'package:uuid/uuid.dart';

import '../models/donation.dart';
import '../models/donor.dart';
import 'app_database.dart';

class DonorRepository {
  final AppDatabase _db;

  DonorRepository(this._db);

  Future<List<Donor>> getAll({String? ownerUserId}) async {
    final db = await _db.database;
    final rows = await db.query(
      'donors',
      where: ownerUserId == null ? null : 'owner_user_id = ?',
      whereArgs: ownerUserId == null ? null : [ownerUserId],
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(Donor.fromMap).toList(growable: false);
  }

  Future<Donor?> getById(String id) async {
    final db = await _db.database;
    final rows = await db.query(
      'donors',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Donor.fromMap(rows.first);
  }

  Future<void> insert(Donor donor) async {
    final db = await _db.database;
    await db.insert(
      'donors',
      donor.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> update(Donor donor) async {
    final db = await _db.database;
    final map = donor.copyWith(updatedAt: DateTime.now()).toMap();
    await db.update(
      'donors',
      map,
      where: 'id = ?',
      whereArgs: [donor.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('donors', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setFavorite(String id, bool isFavorite) async {
    final db = await _db.database;
    await db.update(
      'donors',
      {
        'is_favorite': isFavorite ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Donation>> getDonations(String donorId) async {
    final db = await _db.database;
    final rows = await db.query(
      'donations',
      where: 'donor_id = ?',
      whereArgs: [donorId],
      orderBy: 'donation_date DESC',
    );
    return rows.map(Donation.fromMap).toList(growable: false);
  }

  Future<void> recordDonation({
    required String donorId,
    required DateTime donationDate,
    required int units,
    String? location,
    String? notes,
  }) async {
    final db = await _db.database;
    const uuid = Uuid();
    await db.transaction((txn) async {
      await txn.insert('donations', {
        'id': uuid.v4(),
        'donor_id': donorId,
        'donation_date': donationDate.toIso8601String(),
        'units': units,
        'location': location,
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
      });
      await txn.update(
        'donors',
        {
          'last_donation_date': donationDate.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [donorId],
      );
    });
  }

  Future<void> deleteDonation(String donationId) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      final rows = await txn.query(
        'donations',
        columns: ['donor_id'],
        where: 'id = ?',
        whereArgs: [donationId],
        limit: 1,
      );
      if (rows.isEmpty) return;
      final donorId = rows.first['donor_id'] as String;

      await txn.delete(
        'donations',
        where: 'id = ?',
        whereArgs: [donationId],
      );

      final latestRows = await txn.rawQuery(
        'SELECT MAX(donation_date) AS latest FROM donations WHERE donor_id = ?',
        [donorId],
      );
      final latest = latestRows.first['latest'] as String?;
      await txn.update(
        'donors',
        {
          'last_donation_date': latest,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [donorId],
      );
    });
  }

  Future<int> totalDonationCount() async {
    final db = await _db.database;
    final rows = await db.rawQuery('SELECT COUNT(*) AS total FROM donations');
    return (rows.first['total'] as int?) ?? 0;
  }
}
