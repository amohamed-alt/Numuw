import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../content/health_sources.dart';

class CountryPreference extends ChangeNotifier {
  CountryPreference._();

  static final CountryPreference instance = CountryPreference._();
  static const _key = 'numuw.countryIsoCode';

  NumuwCountry _country = NumuwCountry.egypt;

  NumuwCountry get country => _country;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    _country = NumuwCountry.fromIsoCode(preferences.getString(_key)) ??
        NumuwCountry.egypt;
    notifyListeners();
  }

  Future<void> setCountry(NumuwCountry value) async {
    if (_country == value) return;
    _country = value;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, value.isoCode);
  }
}
