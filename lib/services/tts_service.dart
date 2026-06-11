// lib/services/tts_service.dart
// Text-to-Speech service using flutter_tts.
// Attempts Sinhala (si-LK) first; falls back to English if unavailable.

import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  Future<void> initialize() async {
    if (_initialized) return;

    // Prefer Sinhala; gracefully fall back
    await _tts.setLanguage('si-LK').catchError((_) async {
      await _tts.setLanguage('en-US');
    });

    await _tts.setSpeechRate(0.45);  // slightly slow — clearer for Sinhala
    await _tts.setVolume(1.0);
    await _tts.setPitch(0.95);       // slightly deep / robotic feel

    _tts.setStartHandler(() => _isSpeaking = true);
    _tts.setCompletionHandler(() => _isSpeaking = false);
    _tts.setCancelHandler(() => _isSpeaking = false);
    _tts.setErrorHandler((_) => _isSpeaking = false);

    _initialized = true;
  }

  /// Speak [text]. Stops any ongoing speech first.
  Future<void> speak(String text) async {
    if (!_initialized) await initialize();
    await _tts.stop();
    // Strip markdown/emoji for cleaner TTS output
    final cleaned = _cleanForSpeech(text);
    await _tts.speak(cleaned);
  }

  /// Stop speaking immediately.
  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
  }

  /// Remove symbols and markdown that don't read well aloud.
  String _cleanForSpeech(String text) {
    return text
        .replaceAll(RegExp(r'[*_`~#]'), '')          // markdown
        .replaceAll(RegExp(r'\p{So}', unicode: true), '') // symbols/emoji
        .replaceAll(RegExp(r'\s{2,}'), ' ')           // double spaces
        .trim();
  }

  /// Get available languages (useful for debug/settings screen).
  Future<List<dynamic>> getLanguages() async {
    return await _tts.getLanguages;
  }
}
