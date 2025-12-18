import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF6C63FF); // Modern Indigo
  static const Color primaryDark = Color(0xFF4834D4);
  static const Color primaryLight = Color(0xFFA29BFE);

  static const Color secondary = Color(0xFF00CEC9); // Teal
  static const Color accent = Color(0xFFFF7675); // Soft Red for Expense

  // Backgrounds
  static const Color background = Color(0xFFF5F6FA); // Very light grey/blue
  static const Color surface = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textInverse = Colors.white;

  // Functional
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDBC3D);
  static const Color error = Color(0xFFD63031);
  static const Color income = Color(0xFF00B894);
  static const Color expense = Color(0xFFFF7675);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF4834D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF5F6FA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Drop Shadows
  static List<BoxShadow> get shadowMedium => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowLight => [
    BoxShadow(
      color: Colors.black.withOpacity(0.03),
      blurRadius: 5,
      offset: const Offset(0, 2),
    ),
  ];

  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
}
