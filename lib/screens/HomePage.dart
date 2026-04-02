import 'package:flutter/material.dart';
import 'package:market_express/controllers/ItemMarketController.dart';
import 'package:market_express/models/ItemMarketModel.dart';
import 'package:market_express/screens/AddItemPage.dart';
import 'package:market_express/screens/ItemDetailsPage.dart';
import 'package:market_express/utils/app_colors.dart';
import 'package:market_express/utils/price_helper.dart';
import 'package:market_express/utils/watermark_widget.dart';
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

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Comprix',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
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
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
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
                      String emptySubMessage = controller.searchQuery.isNotEmpty
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
                    visibleItems.sort(
                      (a, b) =>
                          _normalize(a.name).compareTo(_normalize(b.name)),
                    );

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
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.divider),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
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
                                    8,
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
                                                overflow: TextOverflow.ellipsis,
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
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          999,
                                                        ),
                                                    border: Border.all(
                                                      color: AppColors.divider,
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
                                                      const SizedBox(width: 4),
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
                                                          AppColors
                                                              .getCategoryColor(
                                                                item.category,
                                                              );
                                                      return Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 6,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: AppColors
                                                              .getCategoryColorLight(
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
                                                              offset: const Offset(
                                                                0,
                                                                2,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
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
                                          Text(
                                            PriceHelper.centavosToFormattedString(
                                              item.priceCentavos ?? 0,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w700,
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
                                                  backgroundColor: Colors.white,
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
                                                                    height: 1.4,
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
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                    ),
                                                                    const TextSpan(
                                                                      text: '?',
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
                                                                  fontSize: 14,
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
                                                            color: Colors.white,
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
                                                                    padding:
                                                                        const EdgeInsets.symmetric(
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
                                                                          FontWeight
                                                                              .w600,
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
                                                                    padding:
                                                                        const EdgeInsets.symmetric(
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
                                                                          FontWeight
                                                                              .w600,
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
              color: AppColors.primaryBlue.withOpacity(0.4),
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
