import 'package:flutter/material.dart';

class Procedure {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> warnings;
  final List<String> steps;

  Procedure({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.warnings,
    required this.steps,
  });

  factory Procedure.fromJson(Map<String, dynamic> json) {
    return Procedure(
      title: json['title'],
      description: json['description'],
      icon: _mapIcon(json['icon']),
      color: _mapColor(json['color']),
      warnings: List<String>.from(json['warnings']),
      steps: List<String>.from(json['steps']),
    );
  }

  static IconData _mapIcon(String iconName) {
    switch (iconName) {
      case 'favorite': return Icons.favorite;
      case 'air': return Icons.air;
      case 'bloodtype': return Icons.bloodtype;
      case 'psychology': return Icons.psychology;
      case 'person_pin': return Icons.person_pin;
      default: return Icons.help_outline;
    }
  }

  static Color _mapColor(String colorName) {
    switch (colorName) {
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'redShade900': return Colors.red.shade900;
      case 'purple': return Colors.purple;
      case 'green': return Colors.green;
      default: return Colors.grey;
    }
  }
}