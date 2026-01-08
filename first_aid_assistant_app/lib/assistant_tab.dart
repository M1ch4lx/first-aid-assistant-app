import 'package:flutter/material.dart';
import 'api_service.dart';
import './services/bot_logic_service.dart';
import './models/flow_models.dart';

class AssistantTab extends StatefulWidget {
  const AssistantTab({super.key});

  @override
  State<AssistantTab> createState() => _AssistantTabState();
}

class _AssistantTabState extends State<AssistantTab> {
  final ApiService _apiService = ApiService();
  final BotLogicService _botLogic = BotLogicService();
  
  String _botResponse = "Wciśnij mikrofon, aby zacząć";
  String _debugInfo = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _botLogic.loadFlow(); // Wczytujemy plik YAML przy starcie
  }

  void _handleVoiceInput() async {
    setState(() => _isLoading = true);

    const String userSpeech = "Widzę nieprzytomnego mężczyznę";
    
    final result = await _apiService.predictIntent(userSpeech);
    String intent = result['intent'];
    double conf = result['confidence'];

    final action = _botLogic.getNextAction(intent);

    setState(() {
      _isLoading = false;
      _debugInfo = "Słyszałem: \"$userSpeech\"\nIntent: $intent (${(conf * 100).toStringAsFixed(1)}%)";
      
      if (action != null) {
        _botResponse = action.message ?? "Akcja: ${action.actionId}";
        
        if (action.actionId == 'call_help') {
           _triggerEmergencyCall();
        }
      } else {
        _botResponse = "Przepraszam, nie zrozumiałem. Czy możesz powtórzyć?";
      }
    });
  }

  void _triggerEmergencyCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('URUCHAMIANIE POŁĄCZENIA: 112'), backgroundColor: Colors.red),
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
        boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 20)],
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Text(
        _botResponse,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, height: 1.4),
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
          color: _isLoading ? Colors.grey : Colors.red,
          boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 15)],
        ),
        child: _isLoading 
          ? const Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator(color: Colors.white))
          : const Icon(Icons.mic, size: 50, color: Colors.white),
      ),
    );
  }
}