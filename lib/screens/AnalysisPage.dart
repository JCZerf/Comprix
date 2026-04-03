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
  final FocusNode _itemSearchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _searchSectionKey = GlobalKey();
  final GlobalKey _searchBottomKey = GlobalKey();
  String _itemSearchQuery = '';
  bool _showSearchSuggestions = true;
  bool _isSearchFieldFocused = false;

  @override
  void initState() {
    super.initState();
    _itemSearchFocusNode.addListener(_onSearchFocusChanged);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _itemSearchFocusNode.removeListener(_onSearchFocusChanged);
    _itemSearchFocusNode.dispose();
    _scrollController.dispose();
    _itemSearchController.dispose();
    super.dispose();
  }

  void _onSearchFocusChanged() {
    if (!mounted) return;
    setState(() {
      _isSearchFieldFocused = _itemSearchFocusNode.hasFocus;
    });

    if (_itemSearchFocusNode.hasFocus) {
      _ensureSearchSectionVisible();
    }
  }

  void _ensureSearchSectionVisible() {
    void ensure() {
      if (!mounted) return;
      final context =
          _searchBottomKey.currentContext ?? _searchSectionKey.currentContext;
      if (context == null) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        alignment: 1,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => ensure());
    for (final delayMs in const [120, 260, 420, 620]) {
      Future<void>.delayed(Duration(milliseconds: delayMs), () {
        if (!mounted || !_itemSearchFocusNode.hasFocus) return;
        ensure();
      });
    }
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

    return null;
  }

  void _applySearchQuery(
    String value, {
    bool preferExactName = false,
    bool showSuggestions = true,
  }) {
    final normalizedValue = normalizeSearchText(value.trim());
    final visibleEntries = _filterEntriesByQuery(_entries, value);
    int? preferredId;

    if (preferExactName) {
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
      _selectedItemId = normalizedValue.isEmpty
          ? null
          : _resolveSelectedItemId(
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
        final hasActiveQuery = normalizeSearchText(_itemSearchQuery.trim()).isNotEmpty;
        if (!hasActiveQuery) {
          _selectedItemId = null;
        } else {
          final visibleEntries = _filterEntriesByQuery(_entries, _itemSearchQuery);
          _selectedItemId = _resolveSelectedItemId(visibleEntries, _selectedItemId);
        }
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
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final isKeyboardOpen = keyboardInset > 0;
    final filteredEntries = _filterEntriesByQuery(_entries, _itemSearchQuery);
    final selectedEntry = filteredEntries.cast<_PriceAnalysisEntry?>().firstWhere(
          (entry) => entry?.item.id == _selectedItemId,
          orElse: () => null,
        );
    final selectedCategory = selectedEntry == null
        ? 'A definir'
        : ((selectedEntry.item.category ?? '').trim().isEmpty
              ? 'A definir'
              : selectedEntry.item.category!.trim());
    final selectedHistoryCount = selectedEntry?.history.length ?? 0;
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
                  controller: _scrollController,
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    16 + keyboardInset + (_isSearchFieldFocused ? 120 : 0),
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF111111), Color(0xFF2C2C2C)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.analytics_rounded, color: Colors.white, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Acompanhe a diferença de preços e veja quais produtos subiram ou caíram.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.15,
                      children: [
                        _DashboardStatCard(
                          label: 'Produtos',
                          value: '${_entries.length}',
                          icon: Icons.inventory_2_rounded,
                          accentColor: const Color(0xFF334155),
                        ),
                        _DashboardStatCard(
                          label: 'Subiram',
                          value: '$increasedCount',
                          icon: Icons.trending_up_rounded,
                          accentColor: const Color(0xFFB91C1C),
                        ),
                        _DashboardStatCard(
                          label: 'Caíram',
                          value: '$decreasedCount',
                          icon: Icons.trending_down_rounded,
                          accentColor: const Color(0xFF0F766E),
                        ),
                        _DashboardStatCard(
                          label: 'Estáveis',
                          value: '$stableCount',
                          icon: Icons.horizontal_rule_rounded,
                          accentColor: const Color(0xFF475569),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      key: _searchSectionKey,
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
                            focusNode: _itemSearchFocusNode,
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
                                _onSearchChanged(value),
                            onSubmitted: (value) {
                              _applySearchQuery(value, showSuggestions: false);
                              _closeSearchKeyboard();
                            },
                            onTap: _ensureSearchSectionVisible,
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
                              _closeSearchKeyboard();
                            },
                          ),
                          SizedBox(key: _searchBottomKey),
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
                          if (_itemSearchQuery.trim().isEmpty) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Pesquise um produto para exibir a análise.',
                              style: TextStyle(
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
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF111111), Color(0xFF2C2C2C)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.14),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedEntry.item.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.2,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          selectedCategory,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.2,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          '$selectedHistoryCount registro${selectedHistoryCount == 1 ? '' : 's'}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.insights_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricCard(
                              label: 'Preço inicial',
                              value: PriceHelper.centavosToFormattedString(
                                selectedEntry.firstPriceCentavos,
                              ),
                              icon: Icons.flag_rounded,
                              accentColor: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MetricCard(
                              label: 'Preço atual',
                              value: PriceHelper.centavosToFormattedString(
                                selectedEntry.currentPriceCentavos,
                              ),
                              icon: Icons.payments_rounded,
                              accentColor: const Color(0xFF111111),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _deltaColor(
                            selectedEntry.deltaCentavos,
                          ).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _deltaColor(
                              selectedEntry.deltaCentavos,
                            ).withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _deltaIcon(selectedEntry.deltaCentavos),
                                color: _deltaColor(selectedEntry.deltaCentavos),
                                size: 22,
                              ),
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
                                      fontSize: 17,
                                      color: _deltaColor(selectedEntry.deltaCentavos),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                _formatPercent(selectedEntry.deltaPercent),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _deltaColor(selectedEntry.deltaCentavos),
                                  fontWeight: FontWeight.w800,
                                ),
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
                            Row(
                              children: [
                                const Icon(
                                  Icons.timeline_rounded,
                                  color: AppColors.textPrimary,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Histórico de preços',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Últimos ${selectedEntry.history.length >= 8 ? '8' : selectedEntry.history.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 9,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundBlue,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.divider),
                                    ),
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
                                          PriceHelper.centavosToFormattedString(
                                            point.priceCentavos,
                                          ),
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
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
          if (!isKeyboardOpen && !_isSearchFieldFocused) const WatermarkWidget(),
        ],
      ),
    );
  }

  void _onSearchChanged(String value) {
    _applySearchQuery(value, showSuggestions: true);
    if (_itemSearchFocusNode.hasFocus) {
      _ensureSearchSectionVisible();
    }
  }

  void _closeSearchKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}

class _DashboardStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _DashboardStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
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
  final IconData icon;
  final Color accentColor;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 14,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
