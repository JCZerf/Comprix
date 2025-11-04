import 'package:flutter/material.dart';
import 'package:market_express/controllers/ItemMarketController.dart';
import 'package:market_express/controllers/PurchasesController.dart';
import 'package:market_express/models/ItemMarketModel.dart';
import 'package:market_express/models/PurchaseModel.dart';
import 'package:market_express/screens/AddItemPage.dart';
import 'package:market_express/screens/ItemDetailsPage.dart';
import 'package:market_express/screens/SelectItemPage.dart';
import 'package:market_express/utils/price_helper.dart';
import 'package:provider/provider.dart';

class ShoppingPage extends StatefulWidget {
  final Purchase purchase;
  const ShoppingPage({super.key, required this.purchase});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  late Map<int, bool> _isAdded;

  @override
  void initState() {
    super.initState();
    _isAdded = Map<int, bool>.from(widget.purchase.isAdded);
  }

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<MarketItemController>(
      context,
    ).items.where((item) => widget.purchase.itemIds.contains(item.id)).toList();

    double _calculateTotal(List<MarketItem> items) {
      int totalCentavos = items.fold(
        0,
        (sum, item) => sum + ((item.priceCentavos ?? 0) * item.quantity),
      );
      return totalCentavos / 100.0;
    }

    final completedCount = _isAdded.values.where((v) => v).length;
    final totalItems = items.length;
    final progress = totalItems > 0 ? completedCount / totalItems : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.purchase.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            Text(
              '$completedCount de $totalItems itens',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        backgroundColor: Colors.lightBlue[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              completedCount == totalItems ? Icons.check_circle : Icons.shopping_cart_outlined,
              color: completedCount == totalItems ? Colors.green : Colors.white,
            ),
            onPressed: () async {
              final option = await showModalBottomSheet<String>(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                backgroundColor: Colors.white,
                builder: (context) => Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Adicionar Item à Compra',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Escolha como deseja adicionar um novo item',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.lightBlue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.pop(context, 'existente'),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.lightBlue[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.playlist_add,
                                      color: Colors.lightBlue[700],
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Adicionar item existente',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Escolher da sua lista de itens',
                                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.pop(context, 'novo'),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.green[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.green[700],
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Criar novo item',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Cadastrar um item totalmente novo',
                                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );

              if (option == 'novo') {
                // Fluxo já existente:
                final result = await Navigator.push<MarketItem>(
                  context,
                  MaterialPageRoute(builder: (_) => const AddItemPage()),
                );
                if (result != null) {
                  final itemController = Provider.of<MarketItemController>(context, listen: false);
                  final allItems = await itemController.getItems();
                  final addedItem = allItems.last;

                  final purchaseController = Provider.of<PurchaseController>(
                    context,
                    listen: false,
                  );
                  final updatedItemIds = List<int>.from(widget.purchase.itemIds)
                    ..add(addedItem.id!);
                  final updatedIsAdded = Map<int, bool>.from(_isAdded)..[addedItem.id!] = false;
                  final updatedPurchase = Purchase(
                    id: widget.purchase.id,
                    name: widget.purchase.name,
                    date: widget.purchase.date,
                    itemIds: updatedItemIds,
                    totalValue:
                        widget.purchase.totalValue +
                        (((addedItem.priceCentavos ?? 0) * addedItem.quantity) / 100.0),
                    isAdded: updatedIsAdded,
                  );
                  await purchaseController.updatePurchase(updatedPurchase);

                  setState(() {
                    _isAdded = updatedIsAdded;
                    widget.purchase.itemIds.add(addedItem.id!);
                  });
                }
              } else if (option == 'existente') {
                // Navega para a tela de seleção de itens
                final selectedItem = await Navigator.push<MarketItem>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SelectItemPage(excludeItemIds: widget.purchase.itemIds),
                  ),
                );

                if (selectedItem != null) {
                  final purchaseController = Provider.of<PurchaseController>(
                    context,
                    listen: false,
                  );
                  final updatedItemIds = List<int>.from(widget.purchase.itemIds)
                    ..add(selectedItem.id!);
                  final updatedIsAdded = Map<int, bool>.from(_isAdded)..[selectedItem.id!] = false;
                  final updatedPurchase = Purchase(
                    id: widget.purchase.id,
                    name: widget.purchase.name,
                    date: widget.purchase.date,
                    itemIds: updatedItemIds,
                    totalValue:
                        widget.purchase.totalValue +
                        (((selectedItem.priceCentavos ?? 0) * selectedItem.quantity) / 100.0),
                    isAdded: updatedIsAdded,
                  );
                  await purchaseController.updatePurchase(updatedPurchase);

                  setState(() {
                    _isAdded = updatedIsAdded;
                    widget.purchase.itemIds.add(selectedItem.id!);
                  });
                }
              }
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          Column(
            children: [
              // Header com progresso
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progresso da compra',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        completedCount == totalItems ? Colors.green : Colors.lightBlue[700]!,
                      ),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    if (completedCount == totalItems)
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Compra finalizada!',
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum item nesta compra',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final MarketItem item = items[index];
                            final isChecked = _isAdded[item.id] ?? false;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isChecked ? Colors.green[300]! : Colors.grey[200]!,
                                  width: isChecked ? 2 : 1,
                                ),
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
                                  onTap: () async {
                                    setState(() {
                                      _isAdded[item.id!] = !(_isAdded[item.id] ?? false);
                                    });
                                    final updatedPurchase = Purchase(
                                      id: widget.purchase.id,
                                      name: widget.purchase.name,
                                      date: widget.purchase.date,
                                      itemIds: widget.purchase.itemIds,
                                      totalValue: widget.purchase.totalValue,
                                      isAdded: _isAdded,
                                    );
                                    await Provider.of<PurchaseController>(
                                      context,
                                      listen: false,
                                    ).updatePurchase(updatedPurchase);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isChecked ? Colors.green : Colors.grey[400]!,
                                              width: 2,
                                            ),
                                            color: isChecked ? Colors.green : Colors.transparent,
                                          ),
                                          child: isChecked
                                              ? const Icon(
                                                  Icons.check,
                                                  size: 16,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 16),
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: isChecked
                                                ? Colors.green[100]
                                                : Colors.lightBlue[100],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            isChecked
                                                ? Icons.check_box
                                                : Icons.inventory_2_outlined,
                                            color: isChecked
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
                                                item.name,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                  decoration: isChecked
                                                      ? TextDecoration.lineThrough
                                                      : null,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                item.category ?? '',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 8),
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
                                                      'Qtd: ${item.quantity}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[700],
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    PriceHelper.centavosToFormattedString(
                                                      item.priceCentavos ?? 0,
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: isChecked
                                                          ? Colors.green[700]
                                                          : Colors.lightBlue[700],
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        PopupMenuButton<String>(
                                          icon: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Icon(
                                              Icons.more_vert_rounded,
                                              size: 18,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          elevation: 8,
                                          shadowColor: Colors.black.withOpacity(0.1),
                                          color: Colors.white,
                                          onSelected: (value) async {
                                            if (value == 'editar') {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => ItemDetailPage(item: item),
                                                ),
                                              );
                                              setState(() {});
                                            } else if (value == 'remover') {
                                              // Modal de confirmação moderno
                                              final confirmed = await showDialog<bool>(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (context) => AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  contentPadding: const EdgeInsets.all(24),
                                                  title: Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          color: Colors.red.withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Icon(
                                                          Icons.warning_amber_rounded,
                                                          color: Colors.red[600],
                                                          size: 24,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      const Expanded(
                                                        child: Text(
                                                          'Remover item?',
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  content: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Tem certeza que deseja remover "${item.name}" do seu carrinho de compras?',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.grey[700],
                                                          height: 1.4,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 16),
                                                      Container(
                                                        padding: const EdgeInsets.all(12),
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey[50],
                                                          borderRadius: BorderRadius.circular(8),
                                                          border: Border.all(
                                                            color: Colors.grey[200]!,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons.info_outline,
                                                              size: 16,
                                                              color: Colors.blue[600],
                                                            ),
                                                            const SizedBox(width: 8),
                                                            Expanded(
                                                              child: Text(
                                                                'Esta ação não pode ser desfeita.',
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors.grey[600],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(context, false),
                                                      style: TextButton.styleFrom(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 20,
                                                          vertical: 12,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Cancelar',
                                                        style: TextStyle(
                                                          color: Colors.grey[600],
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () => Navigator.pop(context, true),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.red[600],
                                                        foregroundColor: Colors.white,
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 20,
                                                          vertical: 12,
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        'Remover',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirmed == true) {
                                                final purchaseController =
                                                    Provider.of<PurchaseController>(
                                                      context,
                                                      listen: false,
                                                    );
                                                final updatedItemIds = List<int>.from(
                                                  widget.purchase.itemIds,
                                                )..remove(item.id);
                                                final updatedIsAdded = Map<int, bool>.from(_isAdded)
                                                  ..remove(item.id);
                                                final updatedPurchase = Purchase(
                                                  id: widget.purchase.id,
                                                  name: widget.purchase.name,
                                                  date: widget.purchase.date,
                                                  itemIds: updatedItemIds,
                                                  totalValue:
                                                      widget.purchase.totalValue -
                                                      (((item.priceCentavos ?? 0) * item.quantity) /
                                                          100.0),
                                                  isAdded: updatedIsAdded,
                                                );
                                                await purchaseController.updatePurchase(
                                                  updatedPurchase,
                                                );
                                                setState(() {
                                                  _isAdded = updatedIsAdded;
                                                  widget.purchase.itemIds.remove(item.id);
                                                });
                                              }
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: 'editar',
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                              child: Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(6),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Icon(
                                                        Icons.edit_rounded,
                                                        size: 16,
                                                        color: Colors.blue[600],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          'Editar item',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.w600,
                                                            color: Colors.grey[800],
                                                          ),
                                                        ),
                                                        Text(
                                                          'Alterar dados do produto',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'remover',
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                              child: Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(6),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Icon(
                                                        Icons.remove_shopping_cart_outlined,
                                                        size: 16,
                                                        color: Colors.red[600],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          'Remover do carrinho',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.w600,
                                                            color: Colors.red[700],
                                                          ),
                                                        ),
                                                        Text(
                                                          'Excluir da lista de compras',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.red[500],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
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
                      ),
              ),
              // Footer com total
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total da compra:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          PriceHelper.centavosToFormattedString(
                            (_calculateTotal(items) * 100).round(),
                          ),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: completedCount == totalItems
                                ? Colors.green
                                : Colors.lightBlue[700],
                          ),
                        ),
                      ],
                    ),
                    if (completedCount == totalItems) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.celebration, color: Colors.green[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Parabéns! Compra finalizada',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
