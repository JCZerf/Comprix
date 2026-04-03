import 'package:flutter/material.dart';
import 'package:market_express/controllers/ItemMarketController.dart';
import 'package:market_express/models/ItemMarketModel.dart';
import 'package:market_express/screens/AddItemPage.dart';
import 'package:market_express/screens/ItemDetailsPage.dart';
import 'package:market_express/utils/app_colors.dart';
import 'package:market_express/utils/item_search_helper.dart';
import 'package:market_express/utils/price_helper.dart';
import 'package:market_express/utils/watermark_widget.dart';
import 'package:market_express/widgets/comprix_app_bar.dart';
import 'package:market_express/widgets/search_suggestions_panel.dart';
import 'package:provider/provider.dart';

String _normalize(String input) {
  var s = input;
  s = s.replaceAll(RegExp('[ÁÀÂÃÄáàâãä]'), 'a');
  s = s.replaceAll(RegExp('[ÉÈÊËéèêë]'), 'e');
  s = s.replaceAll(RegExp('[ÍÌÎÏíìîï]'), 'i');
  s = s.replaceAll(RegExp('[ÓÒÔÕÖóòôõö]'), 'o');
  s = s.replaceAll(RegExp('[ÚÙÛÜúùûü]'), 'u');
  s = s.replaceAll(RegExp('[Çç]'), 'c');
  s = s.replaceAll(RegExp('[Ññ]'), 'n');
  return s.toLowerCase();
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum HomeSortOption {
  alphabetical,
  categoryAlphabetical,
  priceDescending,
  quantityDescending,
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  HomeSortOption _currentSort = HomeSortOption.alphabetical;

  int _compareByName(MarketItem a, MarketItem b) {
    return _normalize(a.name).compareTo(_normalize(b.name));
  }

  int _compareByCategory(MarketItem a, MarketItem b) {
    final categoryA = _normalize((a.category ?? '').trim());
    final categoryB = _normalize((b.category ?? '').trim());
    final categoryCompare = categoryA.compareTo(categoryB);
    if (categoryCompare != 0) return categoryCompare;
    return _compareByName(a, b);
  }

  int _compareByPriceDescending(MarketItem a, MarketItem b) {
    final priceCompare = (b.priceCentavos ?? 0).compareTo(a.priceCentavos ?? 0);
    if (priceCompare != 0) return priceCompare;
    return _compareByName(a, b);
  }

  int _compareByQuantityDescending(MarketItem a, MarketItem b) {
    final quantityCompare = b.quantity.compareTo(a.quantity);
    if (quantityCompare != 0) return quantityCompare;
    return _compareByName(a, b);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          Provider.of<MarketItemController>(context, listen: false).loadItems(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemController = Provider.of<MarketItemController>(context);
    final searchSuggestions = buildItemNameSuggestions(
      itemController.allItems,
      _searchController.text,
      maxSuggestions: 5,
    );

    return Scaffold(
      appBar: ComprixAppBar(
        title: ComprixAppBar.titleText('Comprix', fontSize: 22),
        actions: [
          PopupMenuButton<HomeSortOption>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            tooltip: 'Ordenar',
            onSelected: (HomeSortOption option) {
              setState(() {
                _currentSort = option;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: HomeSortOption.alphabetical,
                child: Row(
                  children: [
                    Icon(
                      Icons.sort_by_alpha,
                      color: _currentSort == HomeSortOption.alphabetical
                          ? AppColors.primaryBlue
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Ordem alfabética',
                      style: TextStyle(
                        fontWeight:
                            _currentSort == HomeSortOption.alphabetical
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _currentSort == HomeSortOption.alphabetical
                            ? AppColors.primaryBlue
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: HomeSortOption.categoryAlphabetical,
                child: Row(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      color:
                          _currentSort == HomeSortOption.categoryAlphabetical
                          ? AppColors.primaryBlue
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Por categoria',
                      style: TextStyle(
                        fontWeight: _currentSort ==
                                HomeSortOption.categoryAlphabetical
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _currentSort ==
                                HomeSortOption.categoryAlphabetical
                            ? AppColors.primaryBlue
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: HomeSortOption.priceDescending,
                child: Row(
                  children: [
                    Icon(
                      Icons.attach_money_rounded,
                      color: _currentSort == HomeSortOption.priceDescending
                          ? AppColors.primaryBlue
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Preço (maior primeiro)',
                      style: TextStyle(
                        fontWeight:
                            _currentSort == HomeSortOption.priceDescending
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _currentSort == HomeSortOption.priceDescending
                            ? AppColors.primaryBlue
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: HomeSortOption.quantityDescending,
                child: Row(
                  children: [
                    Icon(
                      Icons.numbers_rounded,
                      color:
                          _currentSort == HomeSortOption.quantityDescending
                          ? AppColors.primaryBlue
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Quantidade (maior primeiro)',
                      style: TextStyle(
                        fontWeight:
                            _currentSort == HomeSortOption.quantityDescending
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color:
                            _currentSort == HomeSortOption.quantityDescending
                            ? AppColors.primaryBlue
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              // Barra de pesquisa com design aprimorado
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Pesquisar produtos...',
                        hintStyle: TextStyle(color: AppColors.textLight),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.primaryBlue,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  Provider.of<MarketItemController>(
                                    context,
                                    listen: false,
                                  ).clearSearch();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.divider),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.divider),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryBlue,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.backgroundBlue,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                        Provider.of<MarketItemController>(
                          context,
                          listen: false,
                        ).searchItems(value);
                      },
                    ),
                    SearchSuggestionsPanel(
                      suggestions: searchSuggestions,
                      onSuggestionTap: (suggestion) {
                        _searchController.text = suggestion;
                        _searchController.selection = TextSelection.fromPosition(
                          TextPosition(offset: suggestion.length),
                        );
                        Provider.of<MarketItemController>(
                          context,
                          listen: false,
                        ).searchItems(suggestion);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              // Lista de itens
              Expanded(
                child: Container(
                  color: AppColors.backgroundBlue,
                  child: Consumer<MarketItemController>(
                    builder: (context, controller, child) {
                      if (controller.items.isEmpty) {
                        String emptyMessage = controller.searchQuery.isNotEmpty
                            ? 'Nenhum item encontrado'
                            : 'Sua lista está vazia';
                        String emptySubMessage =
                            controller.searchQuery.isNotEmpty
                            ? 'Tente uma pesquisa diferente'
                            : 'Toque no botão + para adicionar itens';

                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                controller.searchQuery.isNotEmpty
                                    ? Icons.search_off
                                    : Icons.shopping_basket_outlined,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                emptyMessage,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                emptySubMessage,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      final visibleItems = List<MarketItem>.from(
                        controller.items,
                      );
                      switch (_currentSort) {
                        case HomeSortOption.alphabetical:
                          visibleItems.sort(_compareByName);
                          break;
                        case HomeSortOption.categoryAlphabetical:
                          visibleItems.sort(_compareByCategory);
                          break;
                        case HomeSortOption.priceDescending:
                          visibleItems.sort(_compareByPriceDescending);
                          break;
                        case HomeSortOption.quantityDescending:
                          visibleItems.sort(_compareByQuantityDescending);
                          break;
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListView.builder(
                          itemCount: visibleItems.length,
                          itemBuilder: (context, index) {
                            final MarketItem item = visibleItems[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.primaryBlue.withValues(
                                    alpha: 0.12,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.white,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ItemDetailPage(item: item),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      14,
                                      10,
                                      14,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name,
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textPrimary,
                                                  letterSpacing: -0.5,
                                                ),
                                              ),
                                              // Adicionar descrição se existir
                                              if (item.description != null &&
                                                  item
                                                      .description!
                                                      .isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  item.description!,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                              const SizedBox(height: 10),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors
                                                          .backgroundBlue,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            999,
                                                          ),
                                                      border: Border.all(
                                                        color: AppColors.divider
                                                            .withValues(
                                                              alpha: 0.9,
                                                            ),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .inventory_2_outlined,
                                                          size: 14,
                                                          color: AppColors
                                                              .textSecondary,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          'Qtd ${item.quantity}',
                                                          style: const TextStyle(
                                                            fontSize: 12,
                                                            color: AppColors
                                                                .textPrimary,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (item.category != null &&
                                                      item.category!.isNotEmpty)
                                                    Builder(
                                                      builder: (context) {
                                                        final categoryColor =
                                                            AppColors.getCategoryColor(
                                                              item.category,
                                                            );
                                                        return Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 10,
                                                                vertical: 6,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color:
                                                                AppColors.getCategoryColorLight(
                                                                  item.category,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  999,
                                                                ),
                                                            border: Border.all(
                                                              color: categoryColor
                                                                  .withValues(
                                                                    alpha: 0.35,
                                                                  ),
                                                            ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: categoryColor
                                                                    .withValues(
                                                                      alpha:
                                                                          0.12,
                                                                    ),
                                                                blurRadius: 6,
                                                                offset:
                                                                    const Offset(
                                                                      0,
                                                                      2,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .sell_outlined,
                                                                size: 12,
                                                                color:
                                                                    categoryColor,
                                                              ),
                                                              const SizedBox(
                                                                width: 4,
                                                              ),
                                                              Text(
                                                                item.category!,
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      categoryColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.backgroundBlue,
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                                border: Border.all(
                                                  color: AppColors.divider,
                                                ),
                                              ),
                                              child: Text(
                                                PriceHelper.centavosToFormattedString(
                                                  item.priceCentavos ?? 0,
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: AppColors.textPrimary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                              ),
                                              color: AppColors.textSecondary,
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (context) => AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    elevation: 8,
                                                    backgroundColor:
                                                        Colors.white,
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    content: Container(
                                                      width: 320,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  24,
                                                                ),
                                                            child: Column(
                                                              children: [
                                                                RichText(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  text: TextSpan(
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .grey[700],
                                                                      height:
                                                                          1.4,
                                                                    ),
                                                                    children: [
                                                                      const TextSpan(
                                                                        text:
                                                                            'Tem certeza que deseja excluir o item ',
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            '"${item.name}"',
                                                                        style: const TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                      ),
                                                                      const TextSpan(
                                                                        text:
                                                                            '?',
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 8,
                                                                ),
                                                                Text(
                                                                  'Esta ação não pode ser desfeita.',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .grey[500],
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          // Botões
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  20,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  const BorderRadius.only(
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                          20,
                                                                        ),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                          20,
                                                                        ),
                                                                  ),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child: OutlinedButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                          context,
                                                                        ),
                                                                    style: OutlinedButton.styleFrom(
                                                                      padding: const EdgeInsets.symmetric(
                                                                        vertical:
                                                                            14,
                                                                      ),
                                                                      side: BorderSide(
                                                                        color: Colors
                                                                            .grey[300]!,
                                                                      ),
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              12,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                    child: Text(
                                                                      'Cancelar',
                                                                      style: TextStyle(
                                                                        color: Colors
                                                                            .grey[600],
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontSize:
                                                                            16,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 12,
                                                                ),
                                                                Expanded(
                                                                  child: ElevatedButton(
                                                                    onPressed: () {
                                                                      controller
                                                                          .deleteItem(
                                                                            item.id!,
                                                                          );
                                                                      Navigator.pop(
                                                                        context,
                                                                      );
                                                                    },
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .red[600],
                                                                      foregroundColor:
                                                                          Colors
                                                                              .white,
                                                                      padding: const EdgeInsets.symmetric(
                                                                        vertical:
                                                                            14,
                                                                      ),
                                                                      elevation:
                                                                          0,
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              12,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                    child: const Text(
                                                                      'Excluir',
                                                                      style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontSize:
                                                                            16,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              const WatermarkWidget(),
            ],
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.primaryBlue,
          elevation: 0,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddItemPage()),
            );
          },
          icon: const Icon(Icons.add, color: Colors.white, size: 24),
          label: const Text(
            'Novo Item',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
