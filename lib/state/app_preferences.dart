import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences extends ChangeNotifier {
  AppPreferences._();

  static final AppPreferences instance = AppPreferences._();

  static const _welcomeKey = 'numuw.hasSeenWelcome';
  static const _nightModeKey = 'numuw.nightMode';

  bool _loaded = false;
  bool _hasSeenWelcome = false;
  bool _nightMode = false;

  bool get loaded => _loaded;
  bool get hasSeenWelcome => _hasSeenWelcome;
  bool get nightMode => _nightMode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _hasSeenWelcome = prefs.getBool(_welcomeKey) ?? false;
    _nightMode = prefs.getBool(_nightModeKey) ?? false;
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
}
