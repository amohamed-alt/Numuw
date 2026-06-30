import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogTimerState extends ChangeNotifier {
  LogTimerState._();

  static final LogTimerState instance = LogTimerState._();

  static const _feedingStartKey = 'numuw.activeFeedingStart';
  static const _sleepStartKey = 'numuw.activeSleepStart';

  DateTime? _feedingStart;
  DateTime? _sleepStart;

  DateTime? get feedingStart => _feedingStart;
  DateTime? get sleepStart => _sleepStart;
  bool get feedingActive => _feedingStart != null;
  bool get sleepActive => _sleepStart != null;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _feedingStart = DateTime.tryParse(prefs.getString(_feedingStartKey) ?? '');
    _sleepStart = DateTime.tryParse(prefs.getString(_sleepStartKey) ?? '');
    notifyListeners();
  }

  Future<void> startFeeding([DateTime? start]) async {
    _feedingStart = start ?? DateTime.now();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _feedingStartKey,
      _feedingStart!.toUtc().toIso8601String(),
    );
  }

  Future<DateTime?> stopFeeding() async {
    final start = _feedingStart;
    _feedingStart = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_feedingStartKey);
    return start;
  }

  Future<void> startSleep([DateTime? start]) async {
    _sleepStart = start ?? DateTime.now();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _sleepStartKey,
      _sleepStart!.toUtc().toIso8601String(),
    );
  }

  Future<DateTime?> stopSleep() async {
    final start = _sleepStart;
    _sleepStart = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sleepStartKey);
    return start;
  }
}
