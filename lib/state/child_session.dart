import 'package:flutter/foundation.dart';

import '../models/child_profile.dart';
import '../repositories/child_repository.dart';

class ChildSession extends ChangeNotifier {
  ChildSession._();
  static final ChildSession instance = ChildSession._();

  final ChildRepository _repository = ChildRepository();
  List<ChildProfile> _children = const [];
  ChildProfile? _selectedChild;
  bool _isLoading = false;
  String? _error;

  List<ChildProfile> get children => _children;
  ChildProfile? get selectedChild => _selectedChild;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final loaded = await _repository.fetchCurrentUserChildren();
      setChildren(loaded, notify: false);
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setChildren(List<ChildProfile> children, {bool notify = true}) {
    _children = List.unmodifiable(children);
    if (_children.isEmpty) {
      _selectedChild = null;
    } else {
      final currentId = _selectedChild?.id;
      _selectedChild = _children.firstWhere(
        (child) => child.id == currentId,
        orElse: () => _children.first,
      );
    }
    if (notify) notifyListeners();
  }

  void selectChild(ChildProfile child) {
    _selectedChild = child;
    notifyListeners();
  }

  void clear() {
    _children = const [];
    _selectedChild = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
