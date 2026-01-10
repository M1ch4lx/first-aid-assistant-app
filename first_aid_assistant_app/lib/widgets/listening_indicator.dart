import 'package:flutter/material.dart';

class ListeningIndicator extends StatelessWidget {
  final bool isListening;
  final bool isBotSpeaking;
  final String recognizedWords;

  const ListeningIndicator({
    super.key,
    required this.isListening,
    required this.isBotSpeaking,
    required this.recognizedWords,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isListening ? Colors.red : Colors.grey.shade300,
            boxShadow: isListening
                ? [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ]
                : [],
          ),
          child: Icon(
            isListening ? Icons.mic : Icons.mic_off,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 12),
        
        Text(
          _getStatusText(),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: isListening ? Colors.red : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getStatusText() {
    if (isListening) {
      return recognizedWords.isEmpty ? "Słucham..." : recognizedWords;
    }
    if (isBotSpeaking) {
      return "Odtwarzam instrukcje...";
    }
    return "Inicjalizacja...";
  }
}