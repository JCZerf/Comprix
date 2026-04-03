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
  if (normalizedQuery.isEmpty) return const [];

  final candidates = items.where((item) {
    final normalizedName = normalizeItemSearchInput(item.name);
    final normalizedCategory = normalizeItemSearchInput(item.category ?? '');
    return normalizedName.contains(normalizedQuery) ||
        normalizedCategory.contains(normalizedQuery);
  }).toList();

  candidates.sort((a, b) {
    final scoreA = _matchScore(a, normalizedQuery);
    final scoreB = _matchScore(b, normalizedQuery);
    if (scoreA != scoreB) return scoreA.compareTo(scoreB);
    return normalizeItemSearchInput(a.name).compareTo(
      normalizeItemSearchInput(b.name),
    );
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
