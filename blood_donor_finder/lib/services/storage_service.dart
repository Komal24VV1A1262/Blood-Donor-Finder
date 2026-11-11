import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blood_donor_finder/models/donor.dart';

class StorageKeys {
  static const donors = 'donors';
  static const sessionEmail = 'session_email';
}

class StorageService {
  static const _donorsKey = StorageKeys.donors;
  static const _sessionKey = StorageKeys.sessionEmail;

  Future<List<Donor>> loadDonors() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_donorsKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Donor.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveDonors(List<Donor> donors) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(donors.map((d) => d.toJson()).toList());
    await prefs.setString(_donorsKey, json);
  }

  Future<void> saveSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, email);
  }

  Future<String?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}