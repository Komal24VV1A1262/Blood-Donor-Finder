import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as mobile_sqlite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:uuid/uuid.dart';

import '../services/seed_data.dart';
import '../utils/password_hasher.dart';

/// Owns the SQLite connection and schema for the application.
class AppDatabase {
  AppDatabase({DatabaseFactory? factory, String? path})
    : _factoryOverride = factory,
      _pathOverride = path;

  static final AppDatabase instance = AppDatabase();

  static const int _version = 1;

  final DatabaseFactory? _factoryOverride;
  final String? _pathOverride;

  Database? _db;
  Future<Database>? _opening;

  Future<Database> get database {
    final existing = _db;
    if (existing != null) return Future.value(existing);
    return _opening ??= _open();
  }

  Future<Database> _open() async {
    final DatabaseFactory factory;
    if (_factoryOverride != null) {
      factory = _factoryOverride;
    } else if (kIsWeb) {
      // Web uses SQLite compiled to WebAssembly and persisted in IndexedDB.
      factory = databaseFactoryFfiWeb;
    } else if (Platform.isAndroid || Platform.isIOS) {
      // Use the native SQLite plugin on phones and tablets.
      factory = mobile_sqlite.databaseFactory;
    } else {
      // Use the FFI implementation on Windows, macOS and Linux.
      sqfliteFfiInit();
      factory = databaseFactoryFfi;
    }
    final path = _pathOverride ?? await _defaultPath();
    final db = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _version,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: _createSchema,
      ),
    );
    await _seedIfNeeded(db);
    _db = db;
    return db;
  }

  Future<String> _defaultPath() async {
    // The web implementation stores this named database in browser IndexedDB.
    if (kIsWeb) return 'bloodlink_web.db';

    final supportDir = await getApplicationSupportDirectory();
    final dbDir = Directory(p.join(supportDir.path, 'BloodDonorFinder'));
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }
    return p.join(dbDir.path, 'blood_donor_finder.db');
  }

  Future<void> _createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        password_salt TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE donors (
        id TEXT PRIMARY KEY,
        owner_user_id TEXT,
        name TEXT NOT NULL,
        blood_group TEXT NOT NULL,
        city TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        notes TEXT,
        last_donation_date TEXT,
        is_available INTEGER NOT NULL DEFAULT 1,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (owner_user_id) REFERENCES users (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE donations (
        id TEXT PRIMARY KEY,
        donor_id TEXT NOT NULL,
        donation_date TEXT NOT NULL,
        units INTEGER NOT NULL DEFAULT 1,
        location TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (donor_id) REFERENCES donors (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE requests (
        id TEXT PRIMARY KEY,
        requester_name TEXT NOT NULL,
        patient_name TEXT NOT NULL,
        blood_group TEXT NOT NULL,
        city TEXT NOT NULL,
        units INTEGER NOT NULL DEFAULT 1,
        contact_phone TEXT NOT NULL,
        hospital TEXT,
        urgency TEXT NOT NULL DEFAULT 'normal',
        notes TEXT,
        status TEXT NOT NULL DEFAULT 'open',
        created_at TEXT NOT NULL,
        fulfilled_at TEXT
      )
    ''');

    await db.execute('CREATE INDEX idx_donors_group ON donors (blood_group)');
    await db.execute('CREATE INDEX idx_donors_city ON donors (city)');
    await db.execute(
      'CREATE INDEX idx_donors_available ON donors (is_available)',
    );
    await db.execute(
      'CREATE INDEX idx_donations_donor ON donations (donor_id)',
    );
    await db.execute('CREATE INDEX idx_requests_status ON requests (status)');
    await db.execute(
      'CREATE INDEX idx_requests_group ON requests (blood_group)',
    );
  }

  Future<void> _seedIfNeeded(Database db) async {
    final donorRows = await db.rawQuery('SELECT COUNT(*) AS total FROM donors');
    final donorCount = (donorRows.first['total'] as int?) ?? 0;
    if (donorCount == 0) {
      final batch = db.batch();
      for (final donor in SeedData.donors()) {
        batch.insert('donors', donor.toMap());
      }
      for (final donation in SeedData.donations()) {
        batch.insert('donations', donation.toMap());
      }
      await batch.commit(noResult: true);
    }

    final userRows = await db.rawQuery('SELECT COUNT(*) AS total FROM users');
    final userCount = (userRows.first['total'] as int?) ?? 0;
    if (userCount == 0) {
      final credentials = PasswordHasher.create(SeedData.demoPassword);
      await db.insert('users', {
        'id': SeedData.demoUserId,
        'name': SeedData.demoName,
        'email': SeedData.demoEmail,
        'password_hash': credentials.hash,
        'password_salt': credentials.salt,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Overrides the seeded demo account identifier so tests are deterministic.
  static String newId() => const Uuid().v4();

  Future<void> close() async {
    final db = _db;
    _db = null;
    _opening = null;
    if (db != null) {
      await db.close();
    }
  }
}
