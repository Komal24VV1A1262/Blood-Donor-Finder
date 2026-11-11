import 'package:sqflite_common_ffi/sqflite_ffi.dart' show ConflictAlgorithm;

import '../models/app_user.dart';
import 'app_database.dart';

/// A user row together with its stored credentials.
class UserRecord {
  final AppUser user;
  final String passwordHash;
  final String passwordSalt;

  const UserRecord({
    required this.user,
    required this.passwordHash,
    required this.passwordSalt,
  });
}

class UserRepository {
  final AppDatabase _db;

  UserRepository(this._db);

  Future<UserRecord?> findByEmail(String email) async {
    final db = await _db.database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _toRecord(rows.first);
  }

  Future<AppUser?> findById(String id) async {
    final db = await _db.database;
    final rows = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<void> insertUser({
    required AppUser user,
    required String passwordHash,
    required String passwordSalt,
  }) async {
    final db = await _db.database;
    await db.insert(
      'users',
      {
        ...user.toMap(),
        'password_hash': passwordHash,
        'password_salt': passwordSalt,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<int> count() async {
    final db = await _db.database;
    final rows = await db.rawQuery('SELECT COUNT(*) AS total FROM users');
    return (rows.first['total'] as int?) ?? 0;
  }

  UserRecord _toRecord(Map<String, Object?> row) {
    return UserRecord(
      user: AppUser.fromMap(row),
      passwordHash: row['password_hash'] as String,
      passwordSalt: row['password_salt'] as String,
    );
  }
}
