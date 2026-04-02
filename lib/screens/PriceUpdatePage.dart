import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/ItemPriceController.dart';
import '../models/ItemMarketModel.dart';
import '../utils/app_colors.dart';
import '../utils/price_helper.dart';
import '../widgets/comprix_app_bar.dart';
// price_form_field removed: price is updated from ItemDetails now

class PriceUpdatePage extends StatefulWidget {
  final MarketItem item;

  const PriceUpdatePage({super.key, required this.item});

  @override
  State<PriceUpdatePage> createState() => _PriceUpdatePageState();
}

class _PriceUpdatePageState extends State<PriceUpdatePage> {
  @override
  void initState() {
    super.initState();
    // Carrega o histórico de preços
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.item.id != null) {
        Provider.of<ItemPriceController>(context, listen: false).loadPriceHistory(widget.item.id!);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComprixAppBar(
        title: ComprixAppBar.titleText('Atualizar Preço', fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card do produto
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
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
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.inventory_2,
                                    color: AppColors.primaryBlue,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.item.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      if (widget.item.category != null &&
                                          widget.item.category!.isNotEmpty)
                                        Text(
                                          widget.item.category!,
                                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),

                            // Preço atual
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.attach_money, color: Colors.grey[600]),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Preço atual',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        PriceHelper.centavosToFormattedString(
                                          widget.item.priceCentavos ?? 0,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Nota: o preço agora é atualizado a partir da edição do item (ItemDetails).
                            // Esta tela exibe somente o preço atual e o histórico.
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Histórico de preços
                      Consumer<ItemPriceController>(
                        builder: (context, controller, child) {
                          if (controller.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (controller.priceHistory.isEmpty) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.timeline, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Nenhum histórico de preços',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'O histórico será criado após a primeira atualização',
                                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Icon(Icons.history, color: AppColors.primaryBlue),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Histórico de preços',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: controller.priceHistory.length,
                                  separatorBuilder: (context, index) =>
                                      Divider(height: 1, color: Colors.grey[200]),
                                  itemBuilder: (context, index) {
                                    final record = controller.priceHistory[index];
                                    final date = DateTime.parse(record['date']);
                                    final price = record['price'] as double;

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: index == 0
                                                  ? AppColors.primaryBlue
                                                  : Colors.grey[400],
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  PriceHelper.centavosToFormattedString(
                                                    (price * 100).round(),
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: index == 0
                                                        ? FontWeight.w600
                                                        : FontWeight.w500,
                                                    color: index == 0
                                                        ? Colors.black87
                                                        : Colors.grey[700],
                                                  ),
                                                ),
                                                Text(
                                                  '${date.day}/${date.month}/${date.year} às ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (index == 0)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.textPrimary.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                'Atual',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 120), // Espaço para os botões fixos
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size(0, 56),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Fechar',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
