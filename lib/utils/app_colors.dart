import 'package:flutter/material.dart';

/// Paleta de cores sofisticada para o Market Express
class AppColors {
  // Azul principal - tom sofisticado e profissional
  static const Color primaryBlue = Color(0xFF1A56DB); // Azul royal profundo
  static const Color primaryBlueDark = Color(0xFF1E429F); // Azul escuro
  static const Color primaryBlueLight = Color(0xFF3B82F6); // Azul claro vibrante

  // Cores de acento
  static const Color accentBlue = Color(0xFF60A5FA); // Azul claro para destaques
  static const Color backgroundBlue = Color(0xFFEFF6FF); // Azul muito claro para backgrounds

  // Cores de status
  static const Color success = Color(0xFF10B981); // Verde para sucesso
  static const Color warning = Color(0xFFF59E0B); // Amarelo/Laranja para avisos
  static const Color error = Color(0xFFEF4444); // Vermelho para erros
  static const Color info = Color(0xFF3B82F6); // Azul para informações

  // Cores neutras
  static const Color textPrimary = Color(0xFF1F2937); // Cinza escuro para textos
  static const Color textSecondary = Color(0xFF6B7280); // Cinza médio
  static const Color textLight = Color(0xFF9CA3AF); // Cinza claro

  static const Color background = Color(0xFFF9FAFB); // Fundo claro
  static const Color cardBackground = Colors.white;
  static const Color divider = Color(0xFFE5E7EB);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryBlueLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentBlue, primaryBlueLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const List<Color> categoryColors = [
    Color(0xFF10B981), // Verde esmeralda
    Color(0xFF3B82F6), // Azul royal
    Color(0xFFF59E0B), // Âmbar
    Color(0xFFEF4444), // Vermelho coral
    Color(0xFF8B5CF6), // Roxo
    Color(0xFFEC4899), // Rosa pink
    Color(0xFF06B6D4), // Ciano
    Color(0xFF84CC16), // Lima
    Color(0xFFF97316), // Laranja
    Color(0xFF14B8A6), // Teal
    Color(0xFF6366F1), // Índigo
    Color(0xFFA855F7), // Púrpura
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
    return getCategoryColor(category).withOpacity(0.15);
  }
}
