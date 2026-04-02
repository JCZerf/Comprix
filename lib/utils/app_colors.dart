import 'package:flutter/material.dart';

/// Paleta de cores da identidade visual do Comprix
class AppColors {
  // Paleta principal monocromática
  static const Color primaryBlue = Color(0xFF111111);
  static const Color primaryBlueDark = Color(0xFF000000);
  static const Color primaryBlueLight = Color(0xFF1C1C1C);

  // Tons de apoio
  static const Color accentBlue = Color(0xFF2B2B2B);
  static const Color backgroundBlue = Color(0xFFF7F7F7);

  // Cores de status em escala de cinza
  static const Color success = textPrimary;
  static const Color warning = textSecondary;
  static const Color error = textPrimary;
  static const Color info = textSecondary;

  // Cores neutras
  static const Color textPrimary = Color(0xFF111111); // Preto suave para textos
  static const Color textSecondary = Color(0xFF525252); // Cinza médio
  static const Color textLight = Color(0xFF8A8A8A); // Cinza claro

  static const Color background = Colors.white; // Fundo claro
  static const Color cardBackground = Colors.white;
  static const Color divider = Color(0xFFE8E8E8);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentBlue, accentBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const List<Color> categoryColors = [
    Color(0xFF111111),
    Color(0xFF252525),
    Color(0xFF383838),
    Color(0xFF4A4A4A),
    Color(0xFF5A5A5A),
    Color(0xFF6A6A6A),
    Color(0xFF7A7A7A),
    Color(0xFF8A8A8A),
    Color(0xFF444444),
    Color(0xFF555555),
    Color(0xFF666666),
    Color(0xFF777777),
  ];

  static Color getCategoryColor(String? category) {
    if (category == null || category.isEmpty) {
      return textLight;
    }

    int hash = 5381;
    for (int i = 0; i < category.length; i++) {
      hash = ((hash << 5) + hash) + category.codeUnitAt(i);
    }

    final index = hash.abs() % categoryColors.length;
    return categoryColors[index];
  }

  static Color getCategoryColorLight(String? category) {
    return getCategoryColor(category).withValues(alpha: 0.12);
  }
}
