import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechCaptionService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final StreamController<String> _captionController = StreamController<String>.broadcast();

  bool _available = false;
  bool get isAvailable => _available;
  bool get isListening => _speechToText.isListening;
  Stream<String> get captions => _captionController.stream;

  Future<bool> initialize() async {
    _available = await _speechToText.initialize(
      onStatus: (status) {},
      onError: (error) {
        // Forward errors as empty captions to avoid crashing UI; real apps should handle differently.
        _captionController.add('');
      },
    );
    return _available;
  }

  Future<void> startListening({String localeId = ''}) async {
    if (!_available) {
      await initialize();
    }
    if (!_available) return;

    await _speechToText.listen(
      localeId: localeId.isEmpty ? null : localeId,
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      onResult: (result) {
        _captionController.add(result.recognizedWords);
      },
    );
  }

  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
  }

  Future<void> cancel() async {
    await _speechToText.cancel();
  }

  void dispose() {
    _captionController.close();
  }
}


