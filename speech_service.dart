import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

/// Wraps on-device speech recognition + text-to-speech.
/// Swap this out later for Bhashini / AI4Bharat ASR+TTS APIs once you
/// have API access — the rest of the app only talks to this class.
class SpeechService {
  final stt.SpeechToText _stt = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  Future<bool> init() async {
    _ready = await _stt.initialize(
      onError: (e) => print('STT error: $e'),
    );
    return _ready;
  }

  bool get isListening => _stt.isListening;

  Future<void> listen({
    required void Function(String text) onResult,
    String localeId = 'en_IN', // use 'hi_IN' for Hindi
  }) async {
    if (!_ready) await init();
    await _stt.listen(
      localeId: localeId,
      onResult: (result) {
        if (result.finalResult) onResult(result.recognizedWords);
      },
    );
  }

  Future<void> stop() => _stt.stop();

  Future<void> speak(String text, {String localeId = 'en-IN'}) async {
    await _tts.setLanguage(localeId);
    await _tts.speak(text);
  }
}
