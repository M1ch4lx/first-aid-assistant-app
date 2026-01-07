import 'package:flutter/material.dart';

class ProcedureDetailScreen extends StatelessWidget {
  final String title;
  final String description;

  const ProcedureDetailScreen({
    super.key,
    required this.title,
    required this.description,
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
            // Tytuł i opis
            Text(
              title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),

            // SEKCJA OSTRZEŻEŃ (Pomarańczowy)
            _buildInfoBox(
              title: 'WAŻNE OSTRZEŻENIA',
              icon: Icons.warning_amber_rounded,
              backgroundColor: Colors.orange.shade50,
              borderColor: Colors.orange.shade200,
              textColor: Colors.orange.shade900,
              content: Column(
                children: [
                  _buildWarningPoint('Natychmiast wezwij pogotowie (999 lub 112).'),
                  _buildWarningPoint('Upewnij się, że miejsce zdarzenia jest bezpieczne.'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // LISTA KROKÓW
            const Text(
              'INSTRUKCJA KROK PO KROKU',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 16),
            _buildStep(1, 'Sprawdź przytomność – głośno zawołaj i delikatnie potrząśnij.'),
            _buildStep(2, 'Udrożnij drogi oddechowe – odchyl głowę do tyłu.'),
            _buildStep(3, 'Oceń oddech – patrz, słuchaj i wyczuwaj przez 10 sekund.'),
            const SizedBox(height: 32),

            // --- NOWE SEKCJE NA DOLE ---

            // SEKREJA POGOTOWIE (Czerwonawy)
            _buildInfoBox(
              title: 'POGOTOWIE RATUNKOWE',
              icon: Icons.phone_in_talk,
              backgroundColor: Colors.red.shade50,
              borderColor: Colors.red.shade200,
              textColor: Colors.red.shade900,
              content: Text(
                'Zawsze dzwoń na pogotowie (999 lub 112) w sytuacjach zagrożenia życia. Pierwsza pomoc ma na celu stabilizację stanu do czasu przybycia profesjonalnej pomocy.',
                style: TextStyle(color: Colors.red.shade900),
              ),
            ),
            const SizedBox(height: 16),

            // SEKCJA O PROCEDURZE (Szarawy)
            _buildInfoBox(
              title: 'O TEJ PROCEDURZE',
              icon: Icons.info_outline,
              backgroundColor: Colors.grey.shade100,
              borderColor: Colors.grey.shade300,
              textColor: Colors.grey.shade800,
              content: Text(
                'Jest to procedura do wykonania przez osobę początkującą. Postępuj zgodnie z każdym krokiem ostrożnie i użyj asystenta głosowego, aby uzyskać wskazówki w czasie rzeczywistym podczas sytuacji awaryjnej.',
                style: TextStyle(color: Colors.grey.shade800),
              ),
            ),
            const SizedBox(height: 40), // Margines na samym dole
          ],
        ),
      ),
    );
  }

  // Uniwersalny widget dla kolorowych bloków informacyjnych
  Widget _buildInfoBox({
    required String title,
    required IconData icon,
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildWarningPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: Text('$number', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16, height: 1.4))),
        ],
      ),
    );
  }
}