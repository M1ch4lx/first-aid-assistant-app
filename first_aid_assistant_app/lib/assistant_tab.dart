import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'api_service.dart';
import './models/flow_models.dart';

class AssistantTab extends StatefulWidget {
  const AssistantTab({super.key});

  @override
  State<AssistantTab> createState() => _AssistantTabState();
}

class _AssistantTabState extends State<AssistantTab> {
  final ApiService _apiService = ApiService();
  StreamSubscription? _subscription;
  
  String _botResponse = "Łączenie z asystentem...";
  String _debugInfo = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initWebSocket();
  }

  void _initWebSocket() {
    _apiService.connect();
    
    _subscription = _apiService.messages.listen(
      (data) {
        try {
          final Map<String, dynamic> jsonData = jsonDecode(data);
          final action = BotAction.fromJson(jsonData);

          setState(() {
            _isLoading = false;
            _botResponse = action.message ?? "Otrzymano instrukcję";
            
            // Zabezpieczenie: wyświetlamy info o użytkowniku tylko jeśli istnieje
            String userText = jsonData['user'] ?? "Inicjalizacja";
            _debugInfo = "Serwer: $userText\nAkcja: ${action.special ?? 'brak'}";
          });

          if (action.special == 'call_help') {
            _triggerEmergencyCall();
          }
        } catch (e) {
          debugPrint("Błąd dekodowania JSON: $e");
        }
      },
      onError: (error) {
        setState(() {
          _isLoading = false;
          _botResponse = "Błąd połączenia z serwerem AI";
        });
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _apiService.disconnect();
    super.dispose();
  }

  void _handleVoiceInput() {
    setState(() {
      _isLoading = true;
      _botResponse = "Słucham...";
    });

    // Symulacja mowy - serwer powinien odpowiedzieć na tę frazę
    const String userSpeech = "Widzę nieprzytomnego mężczyznę";
    _apiService.sendMessage(userSpeech);
  }

  // --- Reszta metod UI bez zmian ---
  void _triggerEmergencyCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('URUCHAMIANIE POŁĄCZENIA: 112', 
          style: TextStyle(fontWeight: FontWeight.bold)), 
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          const SizedBox(height: 60),
          const Spacer(),
          _buildResponsePanel(),
          const SizedBox(height: 20),
          if (_debugInfo.isNotEmpty)
            Text(_debugInfo, textAlign: TextAlign.center, 
                 style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          const Spacer(),
          _buildMicButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildResponsePanel() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Text(_botResponse, textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, height: 1.4, color: Colors.black87),
      ),
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleVoiceInput,
      child: Container(
        width: 120, height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isLoading ? Colors.grey.shade400 : Colors.red,
          boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 15, spreadRadius: 2)],
        ),
        child: _isLoading 
          ? const Padding(padding: EdgeInsets.all(35), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
          : const Icon(Icons.mic, size: 50, color: Colors.white),
      ),
    );
  }
}