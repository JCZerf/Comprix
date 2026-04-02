import 'package:flutter/material.dart';

/// Paleta de cores da identidade visual do Comprix
class AppColors {
  // Paleta principal
  static const Color primaryBlue = Color(0xFF111111);
  static const Color primaryBlueDark = Color(0xFF000000);
  static const Color primaryBlueLight = Color(0xFF2C2C2C);

  // Tons de apoio (cinza frio elegante)
  static const Color accentBlue = Color(0xFF334155);
  static const Color backgroundBlue = Color(0xFFF8FAFC);

  // Cores de status em escala de cinza
  static const Color success = textPrimary;
  static const Color warning = textSecondary;
  static const Color error = textPrimary;
  static const Color info = textSecondary;

  // Cores neutras
  static const Color textPrimary = Color(0xFF0F172A); // Preto azulado
  static const Color textSecondary = Color(0xFF475569); // Cinza frio médio
  static const Color textLight = Color(0xFF94A3B8); // Cinza claro

  static const Color background = Color(0xFFF3F4F6); // Fundo da tela
  static const Color cardBackground = Colors.white;
  static const Color divider = Color(0xFFE2E8F0);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryBlueLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentBlue, Color(0xFF475569)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const List<Color> categoryColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Violet
    Color(0xFF0EA5E9), // Sky
    Color(0xFF14B8A6), // Teal
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFFEC4899), // Pink
    Color(0xFF64748B), // Slate
    Color(0xFF4F46E5), // Indigo dark
    Color(0xFF7C3AED), // Purple
    Color(0xFF0891B2), // Cyan dark
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
