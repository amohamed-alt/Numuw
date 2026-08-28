import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Lightweight transport-level connectivity signal used for UX only.
///
/// This does not claim that the internet is reachable; repositories must still
/// handle timeouts and network failures normally.
class NetworkStatusService extends ChangeNotifier {
  NetworkStatusService._();

  static final NetworkStatusService instance = NetworkStatusService._();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _initialized = false;
  bool _hasConnectivity = true;

  bool get hasConnectivity => _hasConnectivity;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    try {
      _apply(await _connectivity.checkConnectivity());
      _subscription = _connectivity.onConnectivityChanged.listen(_apply);
    } catch (_) {
      // Connectivity is an enhancement, not a startup dependency.
    }
  }

  void _apply(List<ConnectivityResult> results) {
    final next = results.any((result) => result != ConnectivityResult.none);
    if (_hasConnectivity == next) return;
    _hasConnectivity = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
