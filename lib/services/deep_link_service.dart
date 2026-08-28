import 'dart:async';

import 'package:app_links/app_links.dart';

/// Receives Numuw universal/app links. Routing decisions stay in the UI layer.
class DeepLinkService {
  DeepLinkService._();

  static final DeepLinkService instance = DeepLinkService._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  final StreamController<Uri> _controller = StreamController<Uri>.broadcast();

  Stream<Uri> get links => _controller.stream;

  Future<void> initialize() async {
    if (_subscription != null) return;
    _subscription = _appLinks.uriLinkStream.listen(
      _controller.add,
      onError: (_) {},
    );
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
