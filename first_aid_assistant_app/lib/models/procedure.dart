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
}