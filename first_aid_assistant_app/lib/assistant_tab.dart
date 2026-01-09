import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:vibration/vibration.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'api_service.dart';
import './models/flow_models.dart';

class AssistantTab extends StatefulWidget {
  const AssistantTab({super.key});

  @override
  State<AssistantTab> createState() => _AssistantTabState();
}

class _AssistantTabState extends State<AssistantTab> {
  final ApiService _apiService = ApiService();
  final FlutterTts _flutterTts = FlutterTts();
  StreamSubscription? _subscription;

  // --- SPEECH TO TEXT (STT) ---
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _sttAvailable = false;
  bool _isListening = false;
  String _recognizedWords = "";
  bool _isBotSpeaking = false; 

  // --- LOKALIZACJA ---
  String _cachedAddress = "Pobieram lokalizację...";

  // --- KOLEJKA I SYNCHRONIZACJA ---
  final List<BotAction> _actionQueue = [];
  bool _isProcessing = false;
  Completer<void>? _ttsCompleter;

  // --- LOGIKA POWTARZANIA (REPEAT) ---
  String _lastSpokenText = ""; // Tu przechowujemy ostatnie wypowiedziane zdanie

  // --- METRONOM RKO ---
  Timer? _metronomeTimer;
  int _compressionCount = 0;
  bool _isMetronomeActive = false;
  String _metronomeCountText = "";

  // --- WYŚWIETLANIE ---
  String _botResponse = "Czekam na Twoje polecenie...";
  String _extraDisplay = ""; 
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initSystem();
  }

  Future<void> _initSystem() async {
    await _initTTS();
    _initWebSocket();
    await _fetchInitialLocation();
    await _initSTT();
  }

  Future<void> _initSTT() async {
    try {
      bool available = await _speechToText.initialize(
        onStatus: (status) {
          debugPrint('[STT STATUS] $status');
          if (status == 'notListening' || status == 'done') {
            if (!_isBotSpeaking) _startContinuousListening();
          }
          if (mounted) setState(() => _isListening = _speechToText.isListening);
        },
        onError: (error) {
          debugPrint('[STT ERROR] $error');
          if (error.errorMsg != 'error_busy' && !_isBotSpeaking) _startContinuousListening();
        },
      );
      if (mounted) {
        setState(() => _sttAvailable = available);
        if (available) _startContinuousListening();
      }
    } catch (e) { debugPrint("STT Init Error: $e"); }
  }

  void _startContinuousListening() async {
    if (!_sttAvailable || _speechToText.isListening || _isBotSpeaking) return;
    await _speechToText.listen(
      localeId: "pl_PL",
      onResult: (result) {
        setState(() {
          _recognizedWords = result.recognizedWords;
          if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
            _handleRecognizedText(result.recognizedWords);
          }
        });
      },
      listenMode: stt.ListenMode.dictation,
      cancelOnError: false,
      partialResults: true,
      listenFor: const Duration(hours: 1),
      pauseFor: const Duration(seconds: 4),
    );
  }

  Future<void> _initTTS() async {
    await _flutterTts.setLanguage("pl-PL");
    await _flutterTts.setSpeechRate(0.6);
    _flutterTts.setCompletionHandler(() {
      if (_ttsCompleter != null && !_ttsCompleter!.isCompleted) _ttsCompleter!.complete();
    });
  }

  void _initWebSocket() {
    _apiService.connect();
    _subscription = _apiService.messages.listen((data) {
      try {
        final Map<String, dynamic> jsonData = jsonDecode(data);
        final action = BotAction.fromJson(jsonData);
        _actionQueue.add(action);
        _runActionWorker();
      } catch (e) { debugPrint("[WS ERROR] $e"); }
    });
  }

  Future<void> _runActionWorker() async {
    if (_isProcessing) return;
    _isProcessing = true;
    while (_actionQueue.isNotEmpty) {
      final currentAction = _actionQueue.removeAt(0);
      await _executeAction(currentAction);
    }
    _isProcessing = false;
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _executeAction(BotAction action) async {
    try {
      if (mounted) {
        setState(() {
          // Główne wiadomości tekstowe (nie-specjalne) zapisujemy jako ostatnio mówione
          if (action.message != null && action.message!.isNotEmpty && action.special != true) {
            _botResponse = action.message!;
            _lastSpokenText = action.message!; // Zapamiętaj tekst do powtórzenia
          }
          _extraDisplay = action.display ?? "";
        });
      }

      // AKCJA: MOWA ASYSTENTA
      if (action.message != null && action.message!.isNotEmpty && action.special != true) {
        await _speakText(action.message!);
      }

      // AKCJE SPECJALNE
      if (action.special == true) {
        switch (action.message) {
          case 'tell_location': 
            await _handleTellLocation(); 
            break;
          case 'repeat': // NOWA OBSŁUGA AKCJI REPEAT
            await _handleRepeat();
            break;
          case 'start_cpr_pacer': 
            _startMetronome(); 
            break;
          case 'call_emergency_number': 
            _handleCallEmergency(); 
            break;
        }
      }
    } catch (e) { debugPrint("[EXEC ERROR] $e"); }
    await Future.delayed(const Duration(milliseconds: 400));
  }

  // Pomocnicza metoda do mówienia tekstu z zarządzaniem STT
  Future<void> _speakText(String text) async {
    _isBotSpeaking = true;
    await _speechToText.stop();
    
    _ttsCompleter = Completer<void>();
    await _flutterTts.speak(text);
    
    await _ttsCompleter!.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () { if (_ttsCompleter != null && !_ttsCompleter!.isCompleted) _ttsCompleter!.complete(); },
    );

    _isBotSpeaking = false;
    _startContinuousListening();
  }

  // --- LOGIKA POWTARZANIA ---
  Future<void> _handleRepeat() async {
    if (_lastSpokenText.isNotEmpty) {
      debugPrint("[REPEAT] Powtarzam: $_lastSpokenText");
      if (mounted) setState(() => _botResponse = _lastSpokenText);
      await _speakText(_lastSpokenText);
    } else {
      await _speakText("Nie mam czego powtórzyć.");
    }
  }

  Future<void> _handleTellLocation() async {
    String resp = "Twoja lokalizacja to: $_cachedAddress";
    
    if (mounted) {
      setState(() {
        _botResponse = resp;
        _lastSpokenText = resp;
      });
    }

    await _speakText(resp);
  }

  void _handleRecognizedText(String text) {
    if (text.isEmpty) return;
    setState(() {
      _isLoading = true;
      _recognizedWords = ""; 
    });
    _apiService.sendMessage(text);
  }

  Future<void> _fetchInitialLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (kIsWeb) {
        if (mounted) setState(() => _cachedAddress = "Kraków, ulica Czarnowiejska (Web)");
        return;
      }
      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> marks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (marks.isNotEmpty && mounted) {
        Placemark p = marks[0];
        setState(() => _cachedAddress = "${p.locality}, ${p.street} ${p.name ?? ''}");
      }
    } catch (e) { if (mounted) setState(() => _cachedAddress = "Brak GPS"); }
  }

  void _startMetronome() {
    if (_isMetronomeActive) return;
    _isMetronomeActive = true;
    _compressionCount = 0;
    _runCompressionCycle();
  }

  void _runCompressionCycle() {
    if (!_isMetronomeActive) return;
    _metronomeTimer = Timer.periodic(const Duration(milliseconds: 545), (timer) async {
      if (_compressionCount < 30) {
        _compressionCount++;
        if (mounted) setState(() => _metronomeCountText = "UCIŚNIĘCIE: $_compressionCount");
        if (!kIsWeb && (await Vibration.hasVibrator() ?? false)) Vibration.vibrate(duration: 80);
      } else {
        timer.cancel();
        _compressionCount = 0;
        if (mounted) setState(() => _metronomeCountText = "PRZERWA: 2 WDECHY");
        Future.delayed(const Duration(seconds: 5), () { if (_isMetronomeActive) _runCompressionCycle(); });
      }
    });
  }

  void _handleCallEmergency() {
    if (mounted) setState(() => _botResponse = "Łączę z numerem 112...");
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('POŁĄCZENIE: 112'), backgroundColor: Colors.red));
  }

  @override
  void dispose() {
    _isBotSpeaking = true;
    _metronomeTimer?.cancel();
    _subscription?.cancel();
    _speechToText.stop();
    _flutterTts.stop();
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
            _buildHeader(),
            const SizedBox(height: 20),
            _buildTopLocationPanel(),
            const Spacer(),
            _buildResponsePanel(),
            if (_extraDisplay.isNotEmpty) _buildExtraDisplay(),
            if (_isMetronomeActive) _buildMetronomeStatus(),
            const Spacer(),
            _buildListeningIndicator(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text("Asystent pierwszej pomocy", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 4),
        Text("Wsparcie medyczne w czasie rzeczywistym", style: TextStyle(fontSize: 14, color: Colors.grey.shade600, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        Container(width: 50, height: 3, decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(2))),
      ],
    );
  }

  Widget _buildTopLocationPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Flexible(child: Text("$_cachedAddress", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildResponsePanel() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 220),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.red.shade100, width: 2),
        boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Text(
        _botResponse,
        textAlign: TextAlign.center,
        maxLines: 6,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600, height: 1.4),
      ),
    );
  }

  Widget _buildExtraDisplay() {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(15)),
      child: Text(_extraDisplay, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
    );
  }

  Widget _buildMetronomeStatus() {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite, color: Colors.red),
          const SizedBox(width: 10),
          Text(_metronomeCountText, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildListeningIndicator() {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isListening ? Colors.red : Colors.grey.shade300,
            boxShadow: _isListening ? [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)] : [],
          ),
          child: Icon(_isListening ? Icons.mic : Icons.mic_off, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 12),
        Text(
          _isListening 
            ? (_recognizedWords.isEmpty ? "Słucham..." : _recognizedWords) 
            : (_isBotSpeaking ? "Odtwarzam instrukcje..." : "Inicjalizacja..."),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14, color: _isListening ? Colors.red : Colors.grey.shade600, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}