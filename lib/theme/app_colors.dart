import 'package:flutter/material.dart';

/// Paleta de colores de Finix.
class AppColors {
  AppColors._();

  static const bg = Color(0xFFF2F7F4);
  static const card = Colors.white;
  static const primary = Color(0xFF0B5A3A);
  static const primaryDark = Color(0xFF063D27);
  static const deep = Color(0xFF04170F);
  static const green = Color(0xFF1FB86A);
  static const mint = Color(0xFF3DE08C);
  static const greenSoft = Color(0xFFE3F7EC);
  static const text = Color(0xFF0E1A14);
  static const muted = Color(0xFF718079);
  static const border = Color(0xFFE6EDE9);
  static const field = Color(0xFFF4F7F5);
  static const red = Color(0xFFEF4444);
  static const redSoft = Color(0xFFFDECEC);
  static const orange = Color(0xFFF59E0B);
  static const blue = Color(0xFF3B82F6);
  static const purple = Color(0xFFA855F7);
  static const gold = Color(0xFFF5A623);

  static const buttonGradient = LinearGradient(
    colors: [Color(0xFF0F7449), Color(0xFF063D27)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkGradient = LinearGradient(
    colors: [Color(0xFF0D6541), Color(0xFF042A1B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const brightGradient = LinearGradient(
    colors: [Color(0xFF45E596), Color(0xFF14A85E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
