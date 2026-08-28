import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Single speech recognizer shared by short-form Numuw voice entry flows.
/// Intended for commands and short phrases, not continuous dictation.
class SpeechInputService {
  SpeechInputService._();

  static final SpeechInputService instance = SpeechInputService._();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _initialized = false;
  bool _available = false;

  bool get isListening => _speech.isListening;
  bool get available => _available;

  Future<bool> initialize() async {
    if (_initialized) return _available;
    _initialized = true;
    _available = await _speech.initialize();
    return _available;
  }

  Future<bool> requestPermission() async {
    final microphone = await Permission.microphone.request();
    if (!microphone.isGranted) return false;

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      final speech = await Permission.speech.request();
      return speech.isGranted || speech.isLimited || speech.isProvisional;
    }

    return true;
  }

  Future<bool> start({
    required void Function(String words, bool isFinal) onResult,
    String localeId = 'ar_EG',
  }) async {
    if (!await requestPermission()) return false;
    final ready = await initialize();
    if (!ready) return false;
    await _speech.listen(
      onResult: (result) => onResult(result.recognizedWords, result.finalResult),
      localeId: localeId,
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      cancelOnError: true,
    );
    return _speech.isListening;
  }

  Future<void> stop() => _speech.stop();

  Future<void> cancel() => _speech.cancel();
}
