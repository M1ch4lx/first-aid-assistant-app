import 'package:flutter/material.dart';

class AssistantHeader extends StatelessWidget {
  const AssistantHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Asystent pierwszej pomocy", 
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 4),
        Text("Wsparcie medyczne w czasie rzeczywistym", 
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        Container(width: 50, height: 3, decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(2))),
      ],
    );
  }
}

class LocationPanel extends StatelessWidget {
  final String address;
  const LocationPanel({required this.address, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Flexible(child: Text(address, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class ResponsePanel extends StatelessWidget {
  final String text;
  const ResponsePanel({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
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
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600, height: 1.4)),
    );
  }
}

class ExtraDisplay extends StatelessWidget {
  final String text;
  const ExtraDisplay({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(15)),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
    );
  }
}

class MetronomeStatus extends StatelessWidget {
  final String text;
  const MetronomeStatus({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite, color: Colors.red),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }
}