import 'package:flutter/material.dart';
import 'package:market_express/utils/app_colors.dart';
import 'package:market_express/utils/price_helper.dart';
import 'package:market_express/widgets/comprix_app_bar.dart';
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
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComprixAppBar(
        title: ComprixAppBar.titleText('Selecionar Item'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
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
                  'Selecione um item da sua lista para adicionar',
                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),

          // Campo de pesquisa
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar item...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryBlue),
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
                  _search = value.trim().toLowerCase();
                });
              },
            ),
          ),

          // Lista de itens
          Expanded(
            child: Consumer<MarketItemController>(
              builder: (context, controller, child) {
                final allItems = controller.items;
                final availableItems = allItems
                    .where((item) => !widget.excludeItemIds.contains(item.id))
                    .where((item) {
                      return item.name.toLowerCase().contains(_search) ||
                          (item.category ?? '').toLowerCase().contains(_search);
                    })
                    .toList();

                if (availableItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _search.isEmpty ? Icons.inventory_outlined : Icons.search_off_rounded,
                          size: 80,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _search.isEmpty ? 'Nenhum item disponível' : 'Nenhum item encontrado',
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _search.isEmpty
                              ? 'Todos os itens já estão na compra'
                              : 'Tente outro termo de busca',
                          style: const TextStyle(fontSize: 14, color: AppColors.textLight),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: availableItems.length,
                  itemBuilder: (context, index) {
                    final MarketItem item = availableItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.divider, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.pop(context, item),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.inventory_2_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      if (item.category != null && item.category!.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.getCategoryColorLight(item.category),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: AppColors.getCategoryColor(
                                                item.category,
                                              ).withOpacity(0.4),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Text(
                                            item.category!,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.getCategoryColor(
                                                item.category,
                                              ).withOpacity(0.85),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.backgroundBlue,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: AppColors.accentBlue.withOpacity(0.3),
                                              ),
                                            ),
                                            child: Text(
                                              'Qtd: ${item.quantity}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.primaryBlue,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            PriceHelper.centavosToFormattedString(
                                              item.priceCentavos ?? 0,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.success,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 18,
                                  color: AppColors.textLight,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
