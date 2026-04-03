import 'package:market_express/utils/search_normalizer.dart';

const Set<String> _variablePriceCategoryKeys = {
  'hortifruti',
  'carnes e frios',
  'produtos naturais e organicos',
};

String _normalizeCategory(String? category) {
  if (category == null || category.trim().isEmpty) return '';
  return normalizeSearchText(category)
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

bool isVariablePriceCategory(String? category) {
  final normalized = _normalizeCategory(category);
  if (normalized.isEmpty) return false;
  if (_variablePriceCategoryKeys.contains(normalized)) return true;

  // Fallback por palavras-chave para categorias personalizadas do usuário.
  return normalized.contains('hortifruti') ||
      normalized.contains('carne') ||
      normalized.contains('frio') ||
      normalized.contains('verdura') ||
      normalized.contains('legume') ||
      normalized.contains('fruta');
}
