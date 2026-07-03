import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogTimerState extends ChangeNotifier {
  LogTimerState._();

  static final LogTimerState instance = LogTimerState._();

  static const _feedingStartKey = 'numuw.activeFeedingStart';
  static const _feedingChildKey = 'numuw.activeFeedingChild';
  static const _sleepStartKey = 'numuw.activeSleepStart';
  static const _sleepChildKey = 'numuw.activeSleepChild';
  static const _pumpingStartKey = 'numuw.activePumpingStart';
  static const _pumpingChildKey = 'numuw.activePumpingChild';

  DateTime? _feedingStart;
  DateTime? _sleepStart;
  DateTime? _pumpingStart;
  String? _feedingChildId;
  String? _sleepChildId;
  String? _pumpingChildId;

  DateTime? get feedingStart => _feedingStart;
  DateTime? get sleepStart => _sleepStart;
  DateTime? get pumpingStart => _pumpingStart;
  String? get feedingChildId => _feedingChildId;
  String? get sleepChildId => _sleepChildId;
  String? get pumpingChildId => _pumpingChildId;
  bool get feedingActive => _feedingStart != null;
  bool get sleepActive => _sleepStart != null;
  bool get pumpingActive => _pumpingStart != null;

  DateTime? feedingStartForChild(String childId) =>
      _feedingChildId == childId ? _feedingStart : null;

  DateTime? sleepStartForChild(String childId) =>
      _sleepChildId == childId ? _sleepStart : null;

  DateTime? pumpingStartForChild(String childId) =>
      _pumpingChildId == childId ? _pumpingStart : null;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _feedingStart = DateTime.tryParse(
      prefs.getString(_feedingStartKey) ?? '',
    )?.toLocal();
    _sleepStart = DateTime.tryParse(
      prefs.getString(_sleepStartKey) ?? '',
    )?.toLocal();
    _pumpingStart = DateTime.tryParse(
      prefs.getString(_pumpingStartKey) ?? '',
    )?.toLocal();
    _feedingChildId = prefs.getString(_feedingChildKey);
    _sleepChildId = prefs.getString(_sleepChildKey);
    _pumpingChildId = prefs.getString(_pumpingChildKey);
    notifyListeners();
  }

  Future<void> startFeeding(String childId, [DateTime? start]) async {
    _feedingStart = start ?? DateTime.now();
    _feedingChildId = childId;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _feedingStartKey,
      _feedingStart!.toUtc().toIso8601String(),
    );
    await prefs.setString(_feedingChildKey, childId);
  }

  DateTime? pendingFeedingStart(String childId) =>
      feedingStartForChild(childId);

  Future<void> finishFeeding(String childId) async {
    if (_feedingChildId != childId) return;
    _feedingStart = null;
    _feedingChildId = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_feedingStartKey);
    await prefs.remove(_feedingChildKey);
  }

  Future<void> cancelFeeding() async {
    _feedingStart = null;
    _feedingChildId = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_feedingStartKey);
    await prefs.remove(_feedingChildKey);
  }

  Future<void> startSleep(String childId, [DateTime? start]) async {
    _sleepStart = start ?? DateTime.now();
    _sleepChildId = childId;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _sleepStartKey,
      _sleepStart!.toUtc().toIso8601String(),
    );
    await prefs.setString(_sleepChildKey, childId);
  }

  DateTime? pendingSleepStart(String childId) => sleepStartForChild(childId);

  Future<void> finishSleep(String childId) async {
    if (_sleepChildId != childId) return;
    _sleepStart = null;
    _sleepChildId = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sleepStartKey);
    await prefs.remove(_sleepChildKey);
  }

  Future<void> cancelSleep() async {
    _sleepStart = null;
    _sleepChildId = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sleepStartKey);
    await prefs.remove(_sleepChildKey);
  }

  Future<void> startPumping(String childId, [DateTime? start]) async {
    _pumpingStart = start ?? DateTime.now();
    _pumpingChildId = childId;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _pumpingStartKey,
      _pumpingStart!.toUtc().toIso8601String(),
    );
    await prefs.setString(_pumpingChildKey, childId);
  }

  DateTime? pendingPumpingStart(String childId) =>
      pumpingStartForChild(childId);

  Future<void> finishPumping(String childId) async {
    if (_pumpingChildId != childId) return;
    _pumpingStart = null;
    _pumpingChildId = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pumpingStartKey);
    await prefs.remove(_pumpingChildKey);
  }

  Future<void> cancelPumping() async {
    _pumpingStart = null;
    _pumpingChildId = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pumpingStartKey);
    await prefs.remove(_pumpingChildKey);
  }
}
