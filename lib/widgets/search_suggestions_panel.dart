import 'package:flutter/material.dart';
import 'package:market_express/utils/app_colors.dart';

class SearchSuggestionsPanel extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSuggestionTap;
  final String title;

  const SearchSuggestionsPanel({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
    this.title = 'Sugestões',
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 15,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions
                .map(
                  (suggestion) => ActionChip(
                    label: Text(
                      suggestion,
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      onSuggestionTap(suggestion);
                    },
                    avatar: const Icon(
                      Icons.search_rounded,
                      size: 16,
                      color: AppColors.primaryBlue,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: AppColors.backgroundBlue,
                    side: const BorderSide(color: AppColors.divider),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
