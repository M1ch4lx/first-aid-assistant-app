import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'services/api_service.dart';
import 'services/location_service.dart';
import 'services/metronome_service.dart';
import 'services/speech_service.dart';

import 'models/flow_models.dart';
import 'widgets/assistant_panels.dart';
import 'widgets/listening_indicator.dart';

class AssistantTab extends StatefulWidget {
  const AssistantTab({super.key});

  @override
  State<AssistantTab> createState() => _AssistantTabState();
}

class _AssistantTabState extends State<AssistantTab> {
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  final MetronomeService _metronomeService = MetronomeService();
  final SpeechService _speechService = SpeechService();

  StreamSubscription? _subscription;

  String _cachedAddress = "Pobieram lokalizację...";
  String _botResponse = "Czekam na Twoje polecenie...";
  String _extraDisplay = "";
  String _recognizedWords = "";
  String _metronomeCountText = "";
  
  bool _isListening = false;
  bool _isBotSpeaking = false;
  bool _isMetronomeActive = false;

  final List<BotAction> _actionQueue = [];
  bool _isProcessing = false;
  String _lastSpokenText = "";

  @override
  void initState() {
    super.initState();
    _initSystem();
  }

  Future<void> _initSystem() async {
    _setupSpeechCallbacks();
    await _speechService.init();

    _initWebSocket();
    _fetchInitialLocation();

    _speechService.startListening();
  }

  void _setupSpeechCallbacks() {
    _speechService.onWordsRecognized = (words) {
      setState(() => _recognizedWords = words);
      _handleRecognizedText(words);
    };

    _speechService.onListeningStatusChanged = (status) {
      if (mounted) setState(() => _isListening = status);
    };

    _speechService.onSpeakingStatusChanged = (status) {
      if (mounted) setState(() => _isBotSpeaking = status);
    };
  }

  void _initWebSocket() {
    _apiService.connect();
    _subscription = _apiService.messages.listen((data) {
      try {
        final action = BotAction.fromJson(jsonDecode(data));
        _actionQueue.add(action);
        _runActionWorker();
      } catch (e) {
        debugPrint("[WS ERROR] $e");
      }
    });
  }

  Future<void> _runActionWorker() async {
    if (_isProcessing) return;
    _isProcessing = true;
    while (_actionQueue.isNotEmpty) {
      await _executeAction(_actionQueue.removeAt(0));
    }
    _isProcessing = false;
  }

  Future<void> _executeAction(BotAction action) async {
    String? spokenMessage;

    if (action.message != null && action.special == false) {
      spokenMessage = action.message;
    } else if (action.special == true) {
      if (action.message == 'tell_location') {
        spokenMessage = "Twoja lokalizacja to: $_cachedAddress";
      }
    }

    if (mounted) {
      setState(() {
        if (spokenMessage != null) {
          _botResponse = spokenMessage;
          _lastSpokenText = spokenMessage;
        }
        _extraDisplay = action.display ?? "";
      });
    }

    if (action.special == true) {
      switch (action.message) {
        case 'tell_location':
          await _speechService.speak(spokenMessage!);
          break;
        case 'repeat':
          await _speechService.speak(_lastSpokenText.isNotEmpty 
              ? _lastSpokenText 
              : "Nie mam czego powtórzyć");
          break;
        case 'start_cpr_pacer':
          _startMetronomeLogic();
          break;
        case 'call_emergency_number':
          _handleCallEmergency();
          break;
      }
    } else if (spokenMessage != null) {
      await _speechService.speak(spokenMessage);
    }

    await Future.delayed(const Duration(milliseconds: 400));
  }

  void _handleRecognizedText(String text) {
    setState(() {
      _recognizedWords = "";
    });
    _apiService.sendMessage(text);
  }

  Future<void> _fetchInitialLocation() async {
    final addr = await _locationService.fetchCurrentAddress();
    if (mounted) setState(() => _cachedAddress = addr);
  }

  void _startMetronomeLogic() {
    if (_isMetronomeActive) return;
    setState(() => _isMetronomeActive = true);
    _metronomeService.start(
      onTick: (count) => setState(() => _metronomeCountText = "UCIŚNIĘCIE: $count"),
      onPause: () => setState(() => _metronomeCountText = "PRZERWA: 2 WDECHY"),
    );
  }

  void _handleCallEmergency() {
    setState(() => _botResponse = "Łączę z numerem 112...");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('POŁĄCZENIE: 112'), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _speechService.dispose();
    _metronomeService.stop();
    _apiService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const AssistantHeader(),
            const SizedBox(height: 20),
            LocationPanel(address: _cachedAddress),
            const Spacer(),
            ResponsePanel(text: _botResponse),
            if (_extraDisplay.isNotEmpty) ExtraDisplay(text: _extraDisplay),
            if (_isMetronomeActive) MetronomeStatus(text: _metronomeCountText),
            const Spacer(),
            ListeningIndicator(
              isListening: _isListening,
              isBotSpeaking: _isBotSpeaking,
              recognizedWords: _recognizedWords,
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}