import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class OfflineCareEventQueue {
  OfflineCareEventQueue._();

  static final OfflineCareEventQueue instance = OfflineCareEventQueue._();
  static const _storageKey = 'offline_care_event_inserts_v1';

  Future<void> enqueueInsert(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final pending = await pendingInserts();
    pending.add(Map<String, dynamic>.from(payload));
    await prefs.setString(_storageKey, jsonEncode(pending));
  }

  Future<List<Map<String, dynamic>>> pendingInserts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> replacePending(List<Map<String, dynamic>> pending) async {
    final prefs = await SharedPreferences.getInstance();
    if (pending.isEmpty) {
      await prefs.remove(_storageKey);
      return;
    }
    await prefs.setString(_storageKey, jsonEncode(pending));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
