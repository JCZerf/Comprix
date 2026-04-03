import 'package:flutter/material.dart';
import 'package:market_express/utils/app_colors.dart';
import 'package:market_express/utils/item_search_helper.dart';
import 'package:market_express/utils/price_helper.dart';
import 'package:market_express/utils/search_normalizer.dart';
import 'package:market_express/widgets/comprix_app_bar.dart';
import 'package:market_express/widgets/search_suggestions_panel.dart';
import 'package:provider/provider.dart';

import '../controllers/ItemMarketController.dart';
import '../models/ItemMarketModel.dart';

class SelectItemPage extends StatefulWidget {
  final List<int> excludeItemIds;

  const SelectItemPage({super.key, required this.excludeItemIds});

  @override
  State<SelectItemPage> createState() => _SelectItemPageState();
}

class _SelectItemPageState extends State<SelectItemPage> {
  final TextEditingController _searchController = TextEditingController();
  String _search = '';
  bool _showSearchSuggestions = true;
  final Set<int> _selectedItemIds = <int>{};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _normalizeForSort(String value) {
    return normalizeSearchText(value.trim()).replaceAll(RegExp(r'\s+'), ' ');
  }

  List<MarketItem> _getSortedAvailableItems(List<MarketItem> allItems) {
    final availableItems = allItems
        .where((item) => !widget.excludeItemIds.contains(item.id))
        .toList();

    availableItems.sort((a, b) {
      final nameComparison = _normalizeForSort(a.name).compareTo(
        _normalizeForSort(b.name),
      );
      if (nameComparison != 0) return nameComparison;
      return _normalizeForSort(a.category ?? '').compareTo(
        _normalizeForSort(b.category ?? ''),
      );
    });

    return availableItems;
  }

  void _submitSelection() {
    if (_selectedItemIds.isEmpty) return;

    final controller = Provider.of<MarketItemController>(context, listen: false);
    final allAvailableItems = _getSortedAvailableItems(controller.items);
    final selectedItems = allAvailableItems.where((item) {
      final itemId = item.id;
      return itemId != null && _selectedItemIds.contains(itemId);
    }).toList();

    if (selectedItems.isEmpty) return;
    Navigator.pop(context, selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    final allAvailableItems = _getSortedAvailableItems(
      Provider.of<MarketItemController>(context).allItems,
    );
    final searchSuggestions = buildItemNameSuggestions(
      allAvailableItems,
      _search,
      maxSuggestions: 5,
    );

    return Scaffold(
      appBar: ComprixAppBar(
        title: ComprixAppBar.titleText('Selecionar Itens'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_selectedItemIds.isNotEmpty)
            TextButton(
              onPressed: _submitSelection,
              child: Text(
                'Adicionar (${_selectedItemIds.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header com gradiente e ícone
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(color: Color(0x2042A5F5), blurRadius: 12, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.playlist_add_rounded, size: 32, color: Colors.white),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Escolher Item Existente',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selecione um ou mais itens da sua lista',
                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),

          // Campo de pesquisa
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar item...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryBlue),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _search = '';
                                _showSearchSuggestions = true;
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _search = _normalizeForSort(value);
                      _showSearchSuggestions = true;
                    });
                  },
                  onSubmitted: (value) {
                    setState(() {
                      _search = _normalizeForSort(value);
                      _showSearchSuggestions = false;
                    });
                  },
                ),
                SearchSuggestionsPanel(
                  suggestions: _showSearchSuggestions
                      ? searchSuggestions
                      : const [],
                  onSuggestionTap: (suggestion) {
                    _searchController.text = suggestion;
                    _searchController.selection = TextSelection.fromPosition(
                      TextPosition(offset: suggestion.length),
                    );
                    setState(() {
                      _search = _normalizeForSort(suggestion);
                      _showSearchSuggestions = false;
                    });
                  },
                ),
              ],
            ),
          ),

          // Lista de itens
          Expanded(
            child: Consumer<MarketItemController>(
              builder: (context, controller, child) {
                final allAvailableItems = _getSortedAvailableItems(
                  controller.allItems,
                );
                final filteredItems = allAvailableItems
                    .where((item) {
                      final normalizedName = _normalizeForSort(item.name);
                      final normalizedCategory = _normalizeForSort(
                        item.category ?? '',
                      );
                      return normalizedName.contains(_search) ||
                          normalizedCategory.contains(_search);
                    })
                    .toList();

                if (filteredItems.isEmpty) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _search.isEmpty
                                      ? Icons.inventory_outlined
                                      : Icons.search_off_rounded,
                                  size: 80,
                                  color: AppColors.textLight,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _search.isEmpty
                                      ? 'Nenhum item disponível'
                                      : 'Nenhum item encontrado',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _search.isEmpty
                                      ? 'Todos os itens já estão na compra'
                                      : 'Tente outro termo de busca',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textLight,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final MarketItem item = filteredItems[index];
                    final itemId = item.id;
                    final isSelected =
                        itemId != null && _selectedItemIds.contains(itemId);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSelected
                              ? [
                                  AppColors.backgroundBlue,
                                  AppColors.backgroundBlue.withOpacity(0.3),
                                ]
                              : [Colors.white, Colors.white],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryBlueLight
                              : Colors.grey[200]!,
                          width: isSelected ? 2 : 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? AppColors.primaryBlue.withOpacity(0.15)
                                : Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: CheckboxListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.black87,
                            letterSpacing: -0.3,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.backgroundBlue,
                                    AppColors.backgroundBlue,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.textSecondary.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.category_rounded,
                                    size: 12,
                                    color: AppColors.textPrimary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.category ?? 'Sem categoria',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.backgroundBlue,
                                        AppColors.backgroundBlue,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.textSecondary.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.inventory_2_rounded,
                                        size: 13,
                                        color: AppColors.textPrimary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Qtd: ${item.quantity}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.backgroundBlue,
                                        AppColors.accentBlue,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryBlue.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.attach_money_rounded,
                                        size: 15,
                                        color: AppColors.primaryBlueDark,
                                      ),
                                      Text(
                                        PriceHelper.centavosToFormattedString(
                                          item.priceCentavos ?? 0,
                                        ),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryBlueDark,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        value: isSelected,
                        onChanged: (checked) {
                          if (itemId == null) return;
                          setState(() {
                            if (checked == true) {
                              _selectedItemIds.add(itemId);
                            } else {
                              _selectedItemIds.remove(itemId);
                            }
                          });
                        },
                        activeColor: AppColors.primaryBlue,
                        checkColor: Colors.white,
                        controlAffinity: ListTileControlAffinity.trailing,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selectedItemIds.isEmpty ? null : _submitSelection,
                  icon: const Icon(Icons.playlist_add_check_rounded),
                  label: Text(
                    _selectedItemIds.isEmpty
                        ? 'Selecione itens para adicionar'
                        : 'Adicionar ${_selectedItemIds.length} item${_selectedItemIds.length > 1 ? 's' : ''}',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[600],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
