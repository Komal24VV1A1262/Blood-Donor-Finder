import 'dart:convert';
import 'dart:typed_data';

import 'package:sqflite_common/sqlite_api.dart';

import '../data/app_database.dart';

/// Exports and restores the complete local BloodLink database as JSON.
class BackupService {
  BackupService(this._appDatabase);

  final AppDatabase _appDatabase;

  static const int _formatVersion = 1;
  static const List<String> _tables = [
    'users',
    'donors',
    'donations',
    'requests',
  ];

  Future<Uint8List> createBackup() async {
    final db = await _appDatabase.database;
    final data = <String, Object?>{
      'app': 'BloodLink',
      'formatVersion': _formatVersion,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'tables': <String, Object?>{},
    };

    final tables = data['tables'] as Map<String, Object?>;
    for (final table in _tables) {
      tables[table] = await db.query(table);
    }

    return Uint8List.fromList(
      utf8.encode(const JsonEncoder.withIndent('  ').convert(data)),
    );
  }

  Future<Map<String, int>> restoreBackup(Uint8List bytes) async {
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, dynamic> ||
        decoded['app'] != 'BloodLink' ||
        decoded['formatVersion'] != _formatVersion ||
        decoded['tables'] is! Map<String, dynamic>) {
      throw const FormatException('This is not a supported BloodLink backup.');
    }

    final rawTables = decoded['tables'] as Map<String, dynamic>;
    final rowsByTable = <String, List<Map<String, Object?>>>{};
    for (final table in _tables) {
      final rawRows = rawTables[table];
      if (rawRows is! List) {
        throw FormatException('Backup is missing the $table table.');
      }
      final rows = <Map<String, Object?>>[];
      for (final row in rawRows) {
        if (row is! Map) {
          throw FormatException('Invalid record found in $table.');
        }
        rows.add(Map<String, Object?>.from(row));
      }
      rowsByTable[table] = rows;
    }

    final db = await _appDatabase.database;
    await db.transaction((txn) async {
      await txn.delete('donations');
      await txn.delete('requests');
      await txn.delete('donors');
      await txn.delete('users');

      for (final table in _tables) {
        for (final row in rowsByTable[table]!) {
          await txn.insert(table, row, conflictAlgorithm: ConflictAlgorithm.abort);
        }
      }
    });

    return {
      for (final table in _tables) table: rowsByTable[table]!.length,
    };
  }
}
