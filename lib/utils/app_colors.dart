import 'package:flutter/material.dart';
import 'package:market_express/utils/search_normalizer.dart';

/// Paleta de cores da identidade visual do Comprix
class AppColors {
  // Paleta principal
  static const Color primaryBlue = Color(0xFF111111);
  static const Color primaryBlueDark = Color(0xFF000000);
  static const Color primaryBlueLight = Color(0xFF2C2C2C);

  // Tons de apoio (cinza frio elegante)
  static const Color accentBlue = Color(0xFF334155);
  static const Color backgroundBlue = Colors.white;

  // Cores de status em escala de cinza
  static const Color success = textPrimary;
  static const Color warning = textSecondary;
  static const Color error = textPrimary;
  static const Color info = textSecondary;

  // Cores neutras
  static const Color textPrimary = Color(0xFF111111); // Preto
  static const Color textSecondary = Color(0xFF475569); // Cinza frio médio
  static const Color textLight = Color(0xFF94A3B8); // Cinza claro

  static const Color background = Colors.white; // Fundo da tela
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

  static const Map<String, Color> _categoryColorMap = {
    // Categorias enxutas (atuais)
    'alimentos': Color(0xFFF59E0B),
    'bebidas': Color(0xFF3B82F6),
    'hortifruti': Color(0xFF22C55E),
    'carnes': Color(0xFFDC2626),
    'padaria': Color(0xFFD97706),
    'laticinios e embutidos': Color(0xFFEAB308),
    'limpeza': Color(0xFF66BB6A),
    'higiene e beleza': Color(0xFF8B5CF6),
    'casa': Color(0xFF65A30D),
    'pet': Color(0xFF06B6D4),
    'outros': Color(0xFF64748B),

    // Legado (compatibilidade com itens antigos)
    'padaria e confeitaria': Color(0xFFD97706),
    'carnes e frios': Color(0xFFDC2626),
    'laticinios': Color(0xFFEAB308),
    'congelados': Color(0xFF38BDF8),
    'mercearia': Color(0xFF64748B),
    'doces e sobremesas': Color(0xFFEC4899),
    'cereais e matinais': Color(0xFFCA8A04),
    'massas e farinhas': Color(0xFFF97316),
    'molhos condimentos e temperos': Color(0xFFEF4444),
    'oleos e gorduras': Color(0xFFEA580C),
    'higiene pessoal': Color(0xFF06B6D4),
    'perfumaria e cosmeticos': Color(0xFFA855F7),
    'utilidades domesticas': Color(0xFF475569),
    'pet shop': Color(0xFF8B5CF6),
    'saude e bem estar': Color(0xFF0EA5E9),
    'casa e jardim': Color(0xFF65A30D),
    'produtos naturais e organicos': Color(0xFF16A34A),
    'bebidas alcoolicas': Color(0xFF7C2D12),
  };

  static String _normalizeCategoryKey(String? category) {
    if (category == null || category.trim().isEmpty) {
      return '';
    }

    final normalized = normalizeSearchText(category)
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return normalized;
  }

  static Color getCategoryColor(String? category) {
    final normalizedCategory = _normalizeCategoryKey(category);
    if (normalizedCategory.isEmpty) {
      return textLight;
    }

    final mappedColor = _categoryColorMap[normalizedCategory];
    if (mappedColor != null) {
      return mappedColor;
    }

    int hash = 5381;
    for (int i = 0; i < normalizedCategory.length; i++) {
      hash = ((hash << 5) + hash) + normalizedCategory.codeUnitAt(i);
    }

    final index = hash.abs() % categoryColors.length;
    return categoryColors[index];
  }

  static Color getCategoryColorLight(String? category) {
    return getCategoryColor(category).withValues(alpha: 0.12);
  }
}
