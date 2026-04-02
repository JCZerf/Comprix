import 'package:flutter/material.dart';
import 'package:market_express/screens/CreatePurchasePage.dart';
import 'package:market_express/utils/app_colors.dart';
import 'package:market_express/utils/price_helper.dart';
import 'package:market_express/widgets/comprix_app_bar.dart';
import 'package:provider/provider.dart';

import '../controllers/PurchasesController.dart';
import '../models/PurchaseModel.dart';
import 'Shopping_page.dart';

class PurchasesListPage extends StatelessWidget {
  const PurchasesListPage({super.key});

  void _showOptionsMenu(BuildContext context, Purchase purchase) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.content_copy, color: AppColors.primaryBlue),
                  ),
                  title: const Text(
                    'Usar como Base',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Criar nova compra baseada nesta lista'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CreatePurchasePage(basePurchase: purchase)),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline, color: AppColors.textPrimary),
                  ),
                  title: const Text(
                    'Excluir',
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  subtitle: const Text('Remover esta compra'),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(
                      context,
                      Provider.of<PurchaseController>(context, listen: false),
                      purchase.id!,
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

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
                  color: Colors.white,
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
                          backgroundColor: AppColors.textPrimary,
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
      appBar: ComprixAppBar(
        title: ComprixAppBar.titleText('Minhas Compras', fontSize: 22),
      ),
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Consumer<PurchaseController>(
            builder: (context, controller, child) {
              if (controller.purchases.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 100, color: AppColors.textLight),
                      const SizedBox(height: 24),
                      const Text(
                        'Nenhuma compra cadastrada',
                        style: TextStyle(
                          fontSize: 20,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Toque no botão abaixo para criar sua primeira compra',
                        style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
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
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
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
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        gradient: completedCount == itemCount
                                            ? const LinearGradient(
                                                colors: [AppColors.success, Color(0xFF34D399)],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              )
                                            : AppColors.primaryGradient,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                (completedCount == itemCount
                                                        ? AppColors.success
                                                        : AppColors.primaryBlue)
                                                    .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        completedCount == itemCount
                                            ? Icons.check_circle_rounded
                                            : Icons.shopping_bag_rounded,
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
                                            purchase.name,
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                size: 14,
                                                color: AppColors.textSecondary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${purchase.date.day}/${purchase.date.month}/${purchase.date.year}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
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
                                          style: const TextStyle(
                                            fontSize: 17,
                                            color: AppColors.primaryBlue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.more_vert,
                                            color: AppColors.textSecondary,
                                            size: 24,
                                          ),
                                          tooltip: 'Mais opções',
                                          onPressed: () => _showOptionsMenu(context, purchase),
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
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.backgroundBlue,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppColors.divider),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.shopping_cart_outlined,
                                            size: 14,
                                            color: AppColors.primaryBlue,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$itemCount ${itemCount == 1 ? 'item' : 'itens'}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (completedCount > 0) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: completedCount == itemCount
                                              ? AppColors.success.withOpacity(0.1)
                                              : AppColors.warning.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: completedCount == itemCount
                                                ? AppColors.success
                                                : AppColors.warning,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              completedCount == itemCount
                                                  ? Icons.check_circle
                                                  : Icons.pending_outlined,
                                              size: 14,
                                              color: completedCount == itemCount
                                                  ? AppColors.success
                                                  : AppColors.warning,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              completedCount == itemCount
                                                  ? 'Completa'
                                                  : '$completedCount/$itemCount comprados',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: completedCount == itemCount
                                                    ? AppColors.success
                                                    : AppColors.warning,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
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
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePurchasePage()));
          },
          icon: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 24),
          label: const Text(
            'Nova Compra',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
