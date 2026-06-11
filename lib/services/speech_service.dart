// lib/services/speech_service.dart
// Wraps the speech_to_text plugin with simple start/stop/status API.

import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class SpeechService {
  final SpeechToText _stt = SpeechToText();
  bool _initialized = false;

  bool get isListening => _stt.isListening;

  /// Initialize the STT engine. Returns true if available on this device.
  Future<bool> initialize() async {
    if (_initialized) return true;
    _initialized = await _stt.initialize(
      onError: (error) => print('[STT] Error: $error'),
      onStatus: (status) => print('[STT] Status: $status'),
    );
    return _initialized;
  }

  /// Start listening. [onResult] fires continuously with partial + final text.
  /// [onDone] fires when the session ends (silence or stop()).
  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    required void Function() onDone,
    String localeId = 'si_LK', // Sinhala — falls back to device default
  }) async {
    if (!_initialized) await initialize();
    if (!_initialized) return;

    // Try Sinhala locale; if unavailable the plugin silently uses device default
    await _stt.listen(
      onResult: (SpeechRecognitionResult result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: localeId,
      listenMode: ListenMode.confirmation,
      onSoundLevelChange: null,
    );

    // Notify caller when listening naturally ends
    _stt.statusListener = (status) {
      if (status == 'done' || status == 'notListening') onDone();
    };
  }

  /// Stop listening immediately.
  Future<void> stopListening() async {
    await _stt.stop();
  }

  /// Cancel without returning result.
  Future<void> cancel() async {
    await _stt.cancel();
  }

  /// Returns list of available locales (for debugging).
  Future<List<LocaleName>> getLocales() async {
    if (!_initialized) await initialize();
    return _stt.locales();
  }
}
