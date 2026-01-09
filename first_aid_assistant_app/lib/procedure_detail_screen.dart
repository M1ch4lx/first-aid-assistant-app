import 'package:flutter/material.dart';

class ProcedureDetailScreen extends StatelessWidget {
  final String title;
  final String description;
  final List<String> warnings;
  final List<String> steps;

  const ProcedureDetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.warnings,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Procedura Ratunkowa'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description, style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
            const SizedBox(height: 24),

            _buildInfoBox(
              title: 'WAŻNE OSTRZEŻENIA',
              icon: Icons.warning_amber_rounded,
              backgroundColor: Colors.orange.shade50,
              borderColor: Colors.orange.shade200,
              textColor: Colors.orange.shade900,
              content: Column(
                children: warnings.map((w) => _buildWarningPoint(w)).toList(),
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'INSTRUKCJA KROK PO KROKU',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 16),

            ...steps.asMap().entries.map((entry) => _buildStep(entry.key + 1, entry.value)).toList(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox({required String title, required IconData icon, required Color backgroundColor, required Color borderColor, required Color textColor, required Widget content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(15), border: Border.all(color: borderColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: textColor, size: 20), const SizedBox(width: 8), Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor))]),
        const SizedBox(height: 12),
        content,
      ]),
    );
  }

  Widget _buildWarningPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(text)),
      ]),
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: Colors.red.shade700, borderRadius: BorderRadius.circular(8)),
          alignment: Alignment.center,
          child: Text('$number', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16, height: 1.4))),
      ]),
    );
  }
}