import 'package:market_express/models/ItemMarketModel.dart';
import 'package:market_express/utils/search_normalizer.dart';

class ItemNameDuplicateFeedback {
  final bool hasExactMatch;
  final List<String> similarNames;

  const ItemNameDuplicateFeedback({
    required this.hasExactMatch,
    required this.similarNames,
  });
}

String normalizeItemSearchInput(String input) {
  return normalizeSearchText(input.trim()).replaceAll(RegExp(r'\s+'), ' ');
}

List<String> _tokenizeNormalized(String value) {
  return value
      .split(RegExp(r'\s+'))
      .map((token) => token.trim())
      .where((token) => token.isNotEmpty)
      .toList();
}

bool _matchesNameByWordPrefix(String normalizedName, List<String> queryTokens) {
  if (queryTokens.isEmpty) return false;
  final nameWords = _tokenizeNormalized(normalizedName);
  if (nameWords.isEmpty) return false;
  return queryTokens.every(
    (token) => nameWords.any((word) => word.startsWith(token)),
  );
}

bool _containsAllTokens(String normalizedText, List<String> queryTokens) {
  if (queryTokens.isEmpty) return false;
  return queryTokens.every((token) => normalizedText.contains(token));
}

int _matchScore(MarketItem item, String normalizedQuery) {
  final normalizedName = normalizeItemSearchInput(item.name);
  final normalizedCategory = normalizeItemSearchInput(item.category ?? '');

  if (normalizedName == normalizedQuery) return 0;
  if (normalizedName.startsWith(normalizedQuery)) return 1;
  if (normalizedName.contains(normalizedQuery)) return 2;
  if (normalizedCategory.startsWith(normalizedQuery)) return 3;
  if (normalizedCategory.contains(normalizedQuery)) return 4;
  return 99;
}

List<String> buildItemNameSuggestions(
  List<MarketItem> items,
  String query, {
  int maxSuggestions = 6,
}) {
  final normalizedQuery = normalizeItemSearchInput(query);
  if (normalizedQuery.length < 2) return const [];
  final queryTokens = _tokenizeNormalized(normalizedQuery);
  if (queryTokens.isEmpty) return const [];
  final canMatchCategory = normalizedQuery.length >= 3;

  final candidates = items.where((item) {
    final normalizedName = normalizeItemSearchInput(item.name);
    final normalizedCategory = normalizeItemSearchInput(item.category ?? '');
    final matchesName =
        _matchesNameByWordPrefix(normalizedName, queryTokens) ||
        _containsAllTokens(normalizedName, queryTokens);
    final matchesCategory = canMatchCategory &&
        (_matchesNameByWordPrefix(normalizedCategory, queryTokens) ||
            _containsAllTokens(normalizedCategory, queryTokens));
    return matchesName || matchesCategory;
  }).toList();

  candidates.sort((a, b) {
    final normalizedNameA = normalizeItemSearchInput(a.name);
    final normalizedNameB = normalizeItemSearchInput(b.name);
    final normalizedCategoryA = normalizeItemSearchInput(a.category ?? '');
    final normalizedCategoryB = normalizeItemSearchInput(b.category ?? '');

    int scoreFor(String normalizedName, String normalizedCategory) {
      if (normalizedName == normalizedQuery) return 0;
      if (_matchesNameByWordPrefix(normalizedName, queryTokens)) return 1;
      if (normalizedName.startsWith(normalizedQuery)) return 2;
      if (_containsAllTokens(normalizedName, queryTokens)) return 3;
      if (canMatchCategory &&
          _matchesNameByWordPrefix(normalizedCategory, queryTokens)) {
        return 4;
      }
      if (canMatchCategory &&
          _containsAllTokens(normalizedCategory, queryTokens)) {
        return 5;
      }
      return 99;
    }

    final scoreA = scoreFor(normalizedNameA, normalizedCategoryA);
    final scoreB = scoreFor(normalizedNameB, normalizedCategoryB);
    if (scoreA != scoreB) return scoreA.compareTo(scoreB);
    return normalizedNameA.compareTo(normalizedNameB);
  });

  final seen = <String>{};
  final suggestions = <String>[];
  for (final item in candidates) {
    final normalizedName = normalizeItemSearchInput(item.name);
    if (seen.contains(normalizedName)) continue;
    seen.add(normalizedName);
    suggestions.add(item.name);
    if (suggestions.length >= maxSuggestions) break;
  }

  return suggestions;
}

ItemNameDuplicateFeedback getItemNameDuplicateFeedback(
  List<MarketItem> items,
  String rawName, {
  int maxSuggestions = 4,
}) {
  final normalizedInput = normalizeItemSearchInput(rawName);
  if (normalizedInput.isEmpty) {
    return const ItemNameDuplicateFeedback(
      hasExactMatch: false,
      similarNames: [],
    );
  }

  final hasExactMatch = items.any(
    (item) => normalizeItemSearchInput(item.name) == normalizedInput,
  );

  final similarItems = items.where((item) {
    final normalizedName = normalizeItemSearchInput(item.name);
    if (normalizedName == normalizedInput) return true;
    return normalizedName.contains(normalizedInput) ||
        normalizedInput.contains(normalizedName);
  }).toList();

  similarItems.sort((a, b) {
    final scoreA = _matchScore(a, normalizedInput);
    final scoreB = _matchScore(b, normalizedInput);
    if (scoreA != scoreB) return scoreA.compareTo(scoreB);
    return normalizeItemSearchInput(a.name).compareTo(
      normalizeItemSearchInput(b.name),
    );
  });

  final seen = <String>{};
  final similarNames = <String>[];
  for (final item in similarItems) {
    final normalizedName = normalizeItemSearchInput(item.name);
    if (seen.contains(normalizedName)) continue;
    seen.add(normalizedName);
    similarNames.add(item.name);
    if (similarNames.length >= maxSuggestions) break;
  }

  return ItemNameDuplicateFeedback(
    hasExactMatch: hasExactMatch,
    similarNames: similarNames,
  );
}
