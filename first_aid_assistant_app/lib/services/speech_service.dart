import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  bool isListening = false;
  bool isBotSpeaking = false;
  bool _sttAvailable = false;
  
  Function(String)? onWordsRecognized;
  Function(bool)? onListeningStatusChanged;
  Function(bool)? onSpeakingStatusChanged;

  Future<void> init() async {
    await _initTTS();
    await _initSTT();
  }

  Future<void> _initTTS() async {
    await _flutterTts.setLanguage("pl-PL");
    await _flutterTts.setSpeechRate(0.6);
    
    _flutterTts.setCompletionHandler(() {
      isBotSpeaking = false;
      onSpeakingStatusChanged?.call(false);
      startListening();
    });
  }

  Future<void> _initSTT() async {
    try {
      _sttAvailable = await _speechToText.initialize(
        onStatus: (status) {
          isListening = _speechToText.isListening;
          onListeningStatusChanged?.call(isListening);
          
          if ((status == 'notListening' || status == 'done') && !isBotSpeaking) {
            startListening();
          }
        },
        onError: (error) => debugPrint('[STT ERROR] $error'),
      );
    } catch (e) {
      debugPrint("STT Init Error: $e");
    }
  }

  Future<void> speak(String text) async {
    isBotSpeaking = true;
    onSpeakingStatusChanged?.call(true);
    
    await stopListening();
    await _flutterTts.speak(text);
  }

  Future<void> startListening() async {
    if (!_sttAvailable || _speechToText.isListening || isBotSpeaking) return;

    await _speechToText.listen(
      localeId: "pl_PL",
      onResult: (result) {
        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
          onWordsRecognized?.call(result.recognizedWords);
        }
      },
      listenMode: stt.ListenMode.dictation,
      cancelOnError: false,
      partialResults: true,
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
    isListening = false;
    onListeningStatusChanged?.call(false);
  }

  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
  }
}