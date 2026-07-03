import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences extends ChangeNotifier {
  AppPreferences._();

  static final AppPreferences instance = AppPreferences._();

  static const _welcomeKey = 'numuw.hasSeenWelcome';
  static const _nightModeKey = 'numuw.nightMode';
  static const _feedingRemindersKey = 'numuw.reminders.feeding';
  static const _medicineRemindersKey = 'numuw.reminders.medicine';
  static const _vaccinationRemindersKey = 'numuw.reminders.vaccination';

  bool _loaded = false;
  bool _hasSeenWelcome = false;
  bool _nightMode = false;
  bool _feedingRemindersEnabled = false;
  bool _medicineRemindersEnabled = false;
  bool _vaccinationRemindersEnabled = false;

  bool get loaded => _loaded;
  bool get hasSeenWelcome => _hasSeenWelcome;
  bool get nightMode => _nightMode;
  bool get feedingRemindersEnabled => _feedingRemindersEnabled;
  bool get medicineRemindersEnabled => _medicineRemindersEnabled;
  bool get vaccinationRemindersEnabled => _vaccinationRemindersEnabled;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _hasSeenWelcome = prefs.getBool(_welcomeKey) ?? false;
    _nightMode = prefs.getBool(_nightModeKey) ?? false;
    _feedingRemindersEnabled = prefs.getBool(_feedingRemindersKey) ?? false;
    _medicineRemindersEnabled = prefs.getBool(_medicineRemindersKey) ?? false;
    _vaccinationRemindersEnabled =
        prefs.getBool(_vaccinationRemindersKey) ?? false;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setHasSeenWelcome(bool value) async {
    _hasSeenWelcome = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_welcomeKey, value);
  }

  Future<void> setNightMode(bool value) async {
    _nightMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_nightModeKey, value);
  }

  Future<void> toggleNightMode() => setNightMode(!_nightMode);

  Future<void> setFeedingReminders(bool value) => _setBool(
    _feedingRemindersKey,
    value,
    (v) => _feedingRemindersEnabled = v,
  );

  Future<void> setMedicineReminders(bool value) => _setBool(
    _medicineRemindersKey,
    value,
    (v) => _medicineRemindersEnabled = v,
  );

  Future<void> setVaccinationReminders(bool value) => _setBool(
    _vaccinationRemindersKey,
    value,
    (v) => _vaccinationRemindersEnabled = v,
  );

  Future<void> _setBool(
    String key,
    bool value,
    void Function(bool value) assign,
  ) async {
    assign(value);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
}
