import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences extends ChangeNotifier {
  AppPreferences._();

  static final AppPreferences instance = AppPreferences._();

  static const _welcomeKey = 'numuw.hasSeenWelcome';
  static const _nightModeKey = 'numuw.nightMode';
  static const _themePreferenceKey = 'numuw.themePreference';
  static const _nightLoggingKey = 'numuw.nightLogging';
  static const _reducedMotionKey = 'numuw.reducedMotion';
  static const _feedingRemindersKey = 'numuw.reminders.feeding';
  static const _medicineRemindersKey = 'numuw.reminders.medicine';
  static const _vaccinationRemindersKey = 'numuw.reminders.vaccination';

  bool _loaded = false;
  bool _hasSeenWelcome = false;
  String _themePreference = 'system';
  bool _nightLogging = false;
  bool _reducedMotion = false;
  bool _feedingRemindersEnabled = false;
  bool _medicineRemindersEnabled = false;
  bool _vaccinationRemindersEnabled = false;

  bool get loaded => _loaded;
  bool get hasSeenWelcome => _hasSeenWelcome;
  String get themePreference => _themePreference;
  bool get nightLogging => _nightLogging;
  bool get reducedMotion => _reducedMotion;
  bool get feedingRemindersEnabled => _feedingRemindersEnabled;
  bool get medicineRemindersEnabled => _medicineRemindersEnabled;
  bool get vaccinationRemindersEnabled => _vaccinationRemindersEnabled;

  bool get nightMode {
    if (_themePreference == 'dark') return true;
    if (_themePreference == 'light') return false;
    return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _hasSeenWelcome = prefs.getBool(_welcomeKey) ?? false;
    final storedTheme = prefs.getString(_themePreferenceKey);
    if (storedTheme == 'system' ||
        storedTheme == 'light' ||
        storedTheme == 'dark') {
      _themePreference = storedTheme!;
    } else if (prefs.containsKey(_nightModeKey)) {
      _themePreference = prefs.getBool(_nightModeKey) == true ? 'dark' : 'light';
    }
    _nightLogging = prefs.getBool(_nightLoggingKey) ?? false;
    _reducedMotion = prefs.getBool(_reducedMotionKey) ?? false;
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

  Future<void> setThemePreference(String value) async {
    if (value != 'system' && value != 'light' && value != 'dark') return;
    _themePreference = value;
    if (!nightMode) _nightLogging = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, value);
    await prefs.setBool(_nightModeKey, nightMode);
    await prefs.setBool(_nightLoggingKey, _nightLogging);
  }

  Future<void> setNightMode(bool value) =>
      setThemePreference(value ? 'dark' : 'light');

  Future<void> toggleNightMode() => setNightMode(!nightMode);

  Future<void> setNightLogging(bool value) async {
    _nightLogging = nightMode ? value : false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_nightLoggingKey, _nightLogging);
  }

  Future<void> setReducedMotion(bool value) async {
    _reducedMotion = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reducedMotionKey, value);
  }

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
