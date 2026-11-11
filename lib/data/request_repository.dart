import '../models/blood_request.dart';
import 'app_database.dart';

class RequestRepository {
  final AppDatabase _db;

  RequestRepository(this._db);

  Future<List<BloodRequest>> getAll() async {
    final db = await _db.database;
    final rows = await db.query(
      'requests',
      orderBy:
          "CASE WHEN status = 'open' THEN 0 ELSE 1 END, created_at DESC",
    );
    return rows.map(BloodRequest.fromMap).toList(growable: false);
  }

  Future<void> insert(BloodRequest request) async {
    final db = await _db.database;
    await db.insert('requests', request.toMap());
  }

  Future<void> updateStatus(String id, RequestStatus status) async {
    final db = await _db.database;
    await db.update(
      'requests',
      {
        'status': status.name,
        'fulfilled_at':
            status == RequestStatus.fulfilled
                ? DateTime.now().toIso8601String()
                : null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('requests', where: 'id = ?', whereArgs: [id]);
  }
}
