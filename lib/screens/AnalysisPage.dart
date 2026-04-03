import 'package:flutter/material.dart';
import 'package:market_express/db/DbHelper.dart';
import 'package:market_express/models/ItemMarketModel.dart';
import 'package:market_express/utils/app_colors.dart';
import 'package:market_express/utils/item_search_helper.dart';
import 'package:market_express/utils/price_helper.dart';
import 'package:market_express/utils/search_normalizer.dart';
import 'package:market_express/utils/watermark_widget.dart';
import 'package:market_express/widgets/comprix_app_bar.dart';
import 'package:market_express/widgets/search_suggestions_panel.dart';

class _PriceHistoryPoint {
  final DateTime date;
  final int priceCentavos;

  const _PriceHistoryPoint({
    required this.date,
    required this.priceCentavos,
  });
}

class _PriceAnalysisEntry {
  final MarketItem item;
  final int currentPriceCentavos;
  final int firstPriceCentavos;
  final List<_PriceHistoryPoint> history;

  const _PriceAnalysisEntry({
    required this.item,
    required this.currentPriceCentavos,
    required this.firstPriceCentavos,
    required this.history,
  });

  int get deltaCentavos => currentPriceCentavos - firstPriceCentavos;

  double get deltaPercent {
    if (firstPriceCentavos <= 0) return 0;
    return (deltaCentavos / firstPriceCentavos) * 100;
  }

  bool get hasVariationData => currentPriceCentavos > 0 || firstPriceCentavos > 0;
}

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  bool _isLoading = true;
  List<_PriceAnalysisEntry> _entries = [];
  int? _selectedItemId;
  final TextEditingController _itemSearchController = TextEditingController();
  String _itemSearchQuery = '';
  bool _showSearchSuggestions = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _itemSearchController.dispose();
    super.dispose();
  }

  String _formatShortDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = (value.year % 100).toString().padLeft(2, '0');
    return '$day/$month/$year';
  }

  String _formatDelta(int centavos) {
    final sign = centavos >= 0 ? '+' : '-';
    final absValue = centavos.abs();
    return '$sign ${PriceHelper.centavosToFormattedString(absValue)}';
  }

  String _formatPercent(double value) {
    final sign = value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(1)}%';
  }

  Color _deltaColor(int deltaCentavos) {
    if (deltaCentavos > 0) return const Color(0xFFB91C1C);
    if (deltaCentavos < 0) return AppColors.primaryBlue;
    return AppColors.textSecondary;
  }

  IconData _deltaIcon(int deltaCentavos) {
    if (deltaCentavos > 0) return Icons.trending_up_rounded;
    if (deltaCentavos < 0) return Icons.trending_down_rounded;
    return Icons.remove_rounded;
  }

  List<_PriceAnalysisEntry> _filterEntriesByQuery(
    List<_PriceAnalysisEntry> source,
    String rawQuery,
  ) {
    final normalizedQuery = normalizeSearchText(rawQuery.trim());
    if (normalizedQuery.isEmpty) return source;

    return source.where((entry) {
      final normalizedName = normalizeSearchText(entry.item.name);
      final normalizedCategory = normalizeSearchText(entry.item.category ?? '');
      return normalizedName.contains(normalizedQuery) ||
          normalizedCategory.contains(normalizedQuery);
    }).toList();
  }

  int? _resolveSelectedItemId(
    List<_PriceAnalysisEntry> visibleEntries,
    int? currentSelectedId, {
    int? preferredId,
  }) {
    if (visibleEntries.isEmpty) return null;

    if (preferredId != null &&
        visibleEntries.any((entry) => entry.item.id == preferredId)) {
      return preferredId;
    }

    if (currentSelectedId != null &&
        visibleEntries.any((entry) => entry.item.id == currentSelectedId)) {
      return currentSelectedId;
    }

    return visibleEntries.first.item.id;
  }

  void _applySearchQuery(
    String value, {
    bool preferExactName = false,
    bool showSuggestions = true,
  }) {
    final visibleEntries = _filterEntriesByQuery(_entries, value);
    int? preferredId;

    if (preferExactName) {
      final normalizedValue = normalizeSearchText(value.trim());
      if (normalizedValue.isNotEmpty) {
        for (final entry in visibleEntries) {
          if (normalizeSearchText(entry.item.name) == normalizedValue) {
            preferredId = entry.item.id;
            break;
          }
        }
      }
    }

    setState(() {
      _itemSearchQuery = value;
      _showSearchSuggestions = showSuggestions;
      _selectedItemId = _resolveSelectedItemId(
        visibleEntries,
        _selectedItemId,
        preferredId: preferredId,
      );
    });
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await DBHelper.getItems();
      final entries = <_PriceAnalysisEntry>[];

      for (final item in items) {
        if (item.id == null) continue;

        final historyRaw = await DBHelper.getItemPriceHistory(item.id!);
        final history = historyRaw.map((row) {
          final rawPrice = row['price'];
          final value = rawPrice is num ? rawPrice.toDouble() : 0.0;
          final rawDate = row['date']?.toString() ?? '';

          return _PriceHistoryPoint(
            date: DateTime.tryParse(rawDate) ?? DateTime.now(),
            priceCentavos: PriceHelper.doubleToCentavos(value),
          );
        }).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        final firstPriceCentavos =
            history.isNotEmpty ? history.last.priceCentavos : (item.priceCentavos ?? 0);
        final currentPriceCentavos =
            item.priceCentavos ?? (history.isNotEmpty ? history.first.priceCentavos : 0);

        entries.add(
          _PriceAnalysisEntry(
            item: item,
            currentPriceCentavos: currentPriceCentavos,
            firstPriceCentavos: firstPriceCentavos,
            history: history,
          ),
        );
      }

      entries.sort(
        (a, b) => normalizeSearchText(a.item.name).compareTo(normalizeSearchText(b.item.name)),
      );

      if (!mounted) return;
      setState(() {
        _entries = entries;
        final visibleEntries = _filterEntriesByQuery(_entries, _itemSearchQuery);
        _selectedItemId = _resolveSelectedItemId(visibleEntries, _selectedItemId);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredEntries = _filterEntriesByQuery(_entries, _itemSearchQuery);
    final selectedEntry = filteredEntries.cast<_PriceAnalysisEntry?>().firstWhere(
          (entry) => entry?.item.id == _selectedItemId,
          orElse: () => filteredEntries.isNotEmpty ? filteredEntries.first : null,
        );
    final searchSuggestions = buildItemNameSuggestions(
      _entries.map((entry) => entry.item).toList(),
      _itemSearchQuery,
      maxSuggestions: 6,
    );

    final trackedEntries = _entries.where((e) => e.hasVariationData).toList();
    final increasedCount = trackedEntries.where((e) => e.deltaCentavos > 0).length;
    final decreasedCount = trackedEntries.where((e) => e.deltaCentavos < 0).length;
    final stableCount = trackedEntries.where((e) => e.deltaCentavos == 0).length;
    final Widget bodyContent = _isLoading
        ? const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          )
        : _entries.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.insights_outlined, size: 72, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'Sem dados para análise',
                        style: TextStyle(
                          fontSize: 20,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Cadastre itens e atualize preços para visualizar a evolução.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadDashboardData,
                color: AppColors.primaryBlue,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.divider),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.analytics_rounded, color: AppColors.primaryBlue, size: 26),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Acompanhe a diferença de preços e veja quais produtos subiram ou caíram.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SummaryChip(label: 'Produtos', value: '${_entries.length}'),
                        _SummaryChip(label: 'Subiram', value: '$increasedCount'),
                        _SummaryChip(label: 'Caíram', value: '$decreasedCount'),
                        _SummaryChip(label: 'Estáveis', value: '$stableCount'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pesquisar produto',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _itemSearchController,
                            decoration: InputDecoration(
                              hintText: 'Digite nome ou categoria',
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppColors.primaryBlue,
                              ),
                              suffixIcon: _itemSearchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded),
                                      onPressed: () {
                                        _itemSearchController.clear();
                                        _applySearchQuery(
                                          '',
                                          showSuggestions: true,
                                        );
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.divider),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primaryBlue,
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: (value) =>
                                _applySearchQuery(value, showSuggestions: true),
                            onSubmitted: (value) =>
                                _applySearchQuery(value, showSuggestions: false),
                          ),
                          SearchSuggestionsPanel(
                            suggestions: _showSearchSuggestions
                                ? searchSuggestions
                                : const [],
                            onSuggestionTap: (suggestion) {
                              _itemSearchController.text = suggestion;
                              _itemSearchController.selection =
                                  TextSelection.fromPosition(
                                TextPosition(offset: suggestion.length),
                              );
                              _applySearchQuery(
                                suggestion,
                                preferExactName: true,
                                showSuggestions: false,
                              );
                            },
                          ),
                          if (_itemSearchQuery.trim().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              filteredEntries.isEmpty
                                  ? 'Nenhum item encontrado para esta pesquisa'
                                  : '${filteredEntries.length} item${filteredEntries.length == 1 ? '' : 's'} encontrado${filteredEntries.length == 1 ? '' : 's'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          if (selectedEntry == null &&
                              _itemSearchQuery.trim().isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundBlue,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: const Text(
                                'Ajuste a pesquisa para selecionar um item e ver os detalhes.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (selectedEntry != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricCard(
                              label: 'Preço inicial',
                              value: PriceHelper.centavosToFormattedString(
                                selectedEntry.firstPriceCentavos,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MetricCard(
                              label: 'Preço atual',
                              value: PriceHelper.centavosToFormattedString(
                                selectedEntry.currentPriceCentavos,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _deltaIcon(selectedEntry.deltaCentavos),
                              color: _deltaColor(selectedEntry.deltaCentavos),
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Diferença acumulada',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_formatDelta(selectedEntry.deltaCentavos)} (${_formatPercent(selectedEntry.deltaPercent)})',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _deltaColor(selectedEntry.deltaCentavos),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Histórico de preços',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (selectedEntry.history.isEmpty)
                              const Text(
                                'Sem histórico registrado para este produto.',
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              )
                            else
                              ...selectedEntry.history.take(8).map(
                                (point) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _formatShortDate(point.date),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        PriceHelper.centavosToFormattedString(point.priceCentavos),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );

    return Scaffold(
      appBar: ComprixAppBar(
        title: ComprixAppBar.titleText('Análise', fontSize: 22),
        actions: [
          IconButton(
            tooltip: 'Atualizar dados',
            onPressed: _isLoading ? null : _loadDashboardData,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(child: bodyContent),
          const WatermarkWidget(),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const _MetricCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
