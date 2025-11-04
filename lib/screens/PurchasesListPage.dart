import 'package:flutter/material.dart';
import 'package:market_express/screens/CreatePurchasePage.dart';
import 'package:market_express/utils/price_helper.dart';
import 'package:market_express/utils/watermark_widget.dart';
import 'package:provider/provider.dart';

import '../controllers/PurchasesController.dart';
import '../models/PurchaseModel.dart';
import 'Shopping_page.dart';

class PurchasesListPage extends StatelessWidget {
  const PurchasesListPage({super.key});

  void _confirmDelete(BuildContext context, PurchaseController controller, int id) {
    showDialog(
      context: context,
      barrierDismissible: false, // Evita fechar clicando fora
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: 300,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Tem certeza que deseja excluir esta compra?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Esta ação não pode ser desfeita.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              // Botões
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await controller.deletePurchase(id);
                          Navigator.of(ctx).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Excluir', style: TextStyle(fontWeight: FontWeight.w600)),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Compras', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.lightBlue[700],
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          Consumer<PurchaseController>(
            builder: (context, controller, child) {
              if (controller.purchases.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma compra cadastrada',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toque no botão + para criar sua primeira compra',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListView.builder(
                  itemCount: controller.purchases.length,
                  itemBuilder: (context, index) {
                    final Purchase purchase = controller.purchases[index];
                    final itemCount = purchase.itemIds.length;
                    final completedCount = purchase.isAdded.values.where((v) => v).length;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ShoppingPage(purchase: purchase)),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: completedCount == itemCount
                                            ? Colors.green[100]
                                            : Colors.lightBlue[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        completedCount == itemCount
                                            ? Icons.check_circle_outline
                                            : Icons.shopping_cart_outlined,
                                        color: completedCount == itemCount
                                            ? Colors.green[700]
                                            : Colors.lightBlue[700],
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            purchase.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${purchase.date.day}/${purchase.date.month}/${purchase.date.year}',
                                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          PriceHelper.centavosToFormattedString(
                                            (purchase.totalValue * 100).round(),
                                          ),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.lightBlue[700],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.redAccent,
                                            size: 22,
                                          ),
                                          tooltip: 'Excluir compra',
                                          onPressed: () =>
                                              _confirmDelete(context, controller, purchase.id!),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Colors.grey[400],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '$itemCount ${itemCount == 1 ? 'item' : 'itens'}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (completedCount > 0) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: completedCount == itemCount
                                              ? Colors.green[100]
                                              : Colors.orange[100],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          completedCount == itemCount
                                              ? 'Completa'
                                              : '$completedCount/$itemCount comprados',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: completedCount == itemCount
                                                ? Colors.green[700]
                                                : Colors.orange[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
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
          const WatermarkWidget(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.lightBlue[700],
        elevation: 4,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePurchasePage()));
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nova Compra',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
