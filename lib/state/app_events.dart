import 'package:flutter/foundation.dart';

class AppEvents extends ChangeNotifier {
  AppEvents._();
  static final AppEvents instance = AppEvents._();

  int _careEventVersion = 0;
  int _taskVersion = 0;
  int _vaccinationVersion = 0;
  int get careEventVersion => _careEventVersion;
  int get taskVersion => _taskVersion;
  int get vaccinationVersion => _vaccinationVersion;

  void careEventsChanged() {
    _careEventVersion++;
    notifyListeners();
  }

  void tasksChanged() {
    _taskVersion++;
    notifyListeners();
  }

  void vaccinationsChanged() {
    _vaccinationVersion++;
    notifyListeners();
  }

  void dashboardDataChanged() {
    _careEventVersion++;
    _taskVersion++;
    _vaccinationVersion++;
    notifyListeners();
  }
}
