import 'package:flutter/foundation.dart';

import '../data/request_repository.dart';
import '../models/blood_request.dart';

class RequestProvider extends ChangeNotifier {
  final RequestRepository _repository;

  List<BloodRequest> _requests = const [];
  bool _loading = true;
  String? _error;

  RequestProvider(this._repository);

  List<BloodRequest> get requests => List.unmodifiable(_requests);
  bool get loading => _loading;
  String? get error => _error;

  List<BloodRequest> get openRequests =>
      _requests.where((r) => r.isOpen).toList(growable: false);

  List<BloodRequest> get closedRequests =>
      _requests.where((r) => !r.isOpen).toList(growable: false);

  int get openCount => openRequests.length;

  int get criticalCount => openRequests
      .where((r) => r.urgency == RequestUrgency.critical)
      .length;

  Future<void> loadRequests() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _requests = await _repository.getAll();
    } catch (_) {
      _error = 'Could not load blood requests. Please try again.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> reload() async {
    _requests = await _repository.getAll();
    notifyListeners();
  }

  Future<void> addRequest(BloodRequest request) async {
    await _repository.insert(request);
    await reload();
  }

  Future<void> setStatus(String id, RequestStatus status) async {
    await _repository.updateStatus(id, status);
    await reload();
  }

  Future<void> deleteRequest(String id) async {
    await _repository.delete(id);
    await reload();
  }
}
