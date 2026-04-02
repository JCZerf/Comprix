import 'package:flutter/material.dart';
import 'package:market_express/controllers/ItemMarketController.dart';
import 'package:market_express/controllers/PurchasesController.dart';
import 'package:market_express/db/DbHelper.dart';
import 'package:market_express/models/ItemMarketModel.dart';
import 'package:market_express/models/PurchaseModel.dart';
import 'package:market_express/screens/AddItemPage.dart';
import 'package:market_express/screens/ItemDetailsPage.dart';
import 'package:market_express/screens/SelectItemPage.dart';
import 'package:market_express/utils/app_colors.dart';
import 'package:market_express/utils/price_helper.dart';
import 'package:market_express/widgets/comprix_app_bar.dart';
import 'package:market_express/widgets/price_form_field.dart';
import 'package:provider/provider.dart';

enum SortOption { alphabetical, categoryAlphabetical }

enum _CompleteItemAction { updatePrice, markWithoutPrice }

class ShoppingPage extends StatefulWidget {
  final Purchase purchase;
  const ShoppingPage({super.key, required this.purchase});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  late Map<int, bool> _isAdded;
  SortOption _currentSort = SortOption.alphabetical;
  bool _showBoughtItems = false;
  bool _isProcessingCheckAction = false;

  String _normalize(String input) {
    final withNoDiacritics = input
        .replaceAll(RegExp(r'[ÀÁÂÃÄÅàáâãäå]'), 'a')
        .replaceAll(RegExp(r'[ÈÉÊËèéêë]'), 'e')
        .replaceAll(RegExp(r'[ÌÍÎÏìíîï]'), 'i')
        .replaceAll(RegExp(r'[ÒÓÔÕÖØòóôõöø]'), 'o')
        .replaceAll(RegExp(r'[ÙÚÛÜùúûü]'), 'u')
        .replaceAll(RegExp(r'[Çç]'), 'c')
        .replaceAll(RegExp(r'[Ññ]'), 'n');
    return withNoDiacritics.toLowerCase();
  }

  @override
  void initState() {
    super.initState();
    _isAdded = Map<int, bool>.from(widget.purchase.isAdded);
  }

  Future<void> _savePurchaseState(Map<int, bool> updatedIsAdded) async {
    final updatedPurchase = Purchase(
      id: widget.purchase.id,
      name: widget.purchase.name,
      date: widget.purchase.date,
      itemIds: widget.purchase.itemIds,
      totalValue: widget.purchase.totalValue,
      isAdded: updatedIsAdded,
    );

    await Provider.of<PurchaseController>(
      context,
      listen: false,
    ).updatePurchase(updatedPurchase);

    if (!mounted) return;
    setState(() {
      _isAdded = updatedIsAdded;
    });
  }

  void _showInfoMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primaryBlue,
      ),
    );
  }

  Future<_CompleteItemAction?> _askCompleteAction(MarketItem item) async {
    return showDialog<_CompleteItemAction>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Concluir item'),
        content: Text(
          'Deseja atualizar o preço de "${item.name}" antes de concluir?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, _CompleteItemAction.markWithoutPrice),
            child: const Text('Não, só concluir'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, _CompleteItemAction.updatePrice),
            child: const Text('Sim, atualizar preço'),
          ),
        ],
      ),
    );
  }

  Future<int?> _askNewPriceCentavos(MarketItem item) async {
    String priceText = PriceHelper.centavosToFormattedStringNoSymbol(
      item.priceCentavos ?? 0,
    );
    String? errorText;

    return showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Atualizar preço'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: priceText,
                  keyboardType: TextInputType.number,
                  inputFormatters: [BrazilianCurrencyInputFormatter()],
                  decoration: InputDecoration(
                    labelText: 'Novo preço',
                    prefixText: 'R\$ ',
                    errorText: errorText,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  autofocus: true,
                  onChanged: (value) {
                    priceText = value;
                    if (errorText != null) {
                      setStateDialog(() {
                        errorText = null;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final centavos = PriceHelper.formattedStringToCentavos(
                  priceText,
                );
                if (centavos <= 0) {
                  setStateDialog(() {
                    errorText = 'Informe um preço válido';
                  });
                  return;
                }
                Navigator.pop(context, centavos);
              },
              child: const Text('Salvar e concluir'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markAsBought(MarketItem item) async {
    if (_isProcessingCheckAction) return;
    if (item.id == null) return;
    setState(() {
      _isProcessingCheckAction = true;
    });

    try {
      final action = await _askCompleteAction(item);
      if (action == null) return;

      if (action == _CompleteItemAction.updatePrice) {
        final newPriceCentavos = await _askNewPriceCentavos(item);
        if (newPriceCentavos == null) return;

        final newPrice = PriceHelper.centavosToDouble(newPriceCentavos);
        await DBHelper.updateItemPrice(item.id!, newPrice);
        await DBHelper.insertItemPriceHistory(item.id!, newPrice);
        await Provider.of<MarketItemController>(
          context,
          listen: false,
        ).loadItems();
      }

      final updatedIsAdded = Map<int, bool>.from(_isAdded)..[item.id!] = true;
      await _savePurchaseState(updatedIsAdded);
    } catch (_) {
      _showInfoMessage(
        'Não foi possível concluir o item agora. Tente novamente.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingCheckAction = false;
        });
      }
    }
  }

  Future<void> _unmarkBought(MarketItem item) async {
    if (_isProcessingCheckAction) return;
    if (item.id == null) return;
    setState(() {
      _isProcessingCheckAction = true;
    });

    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Desmarcar item?'),
          content: Text('Deseja desmarcar "${item.name}" como comprado?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Desmarcar'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
      final updatedIsAdded = Map<int, bool>.from(_isAdded)..[item.id!] = false;
      await _savePurchaseState(updatedIsAdded);
    } catch (_) {
      _showInfoMessage(
        'Não foi possível desmarcar o item agora. Tente novamente.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingCheckAction = false;
        });
      }
    }
  }

  Future<void> _handleItemToggle(MarketItem item, bool isChecked) async {
    if (_isProcessingCheckAction) return;
    if (isChecked) {
      await _unmarkBought(item);
    } else {
      await _markAsBought(item);
    }
  }

  List<MarketItem> _sortItems(List<MarketItem> items) {
    int compareItems(MarketItem a, MarketItem b) {
      if (_currentSort == SortOption.alphabetical) {
        return _normalize(a.name).compareTo(_normalize(b.name));
      }

      final categoryA = _normalize(a.category ?? '');
      final categoryB = _normalize(b.category ?? '');
      final categoryComparison = categoryA.compareTo(categoryB);
      if (categoryComparison != 0) return categoryComparison;

      return _normalize(a.name).compareTo(_normalize(b.name));
    }

    final pending = <MarketItem>[];
    final bought = <MarketItem>[];

    for (final item in items) {
      final isAdded = _isAdded[item.id] ?? false;
      if (isAdded) {
        bought.add(item);
      } else {
        pending.add(item);
      }
    }

    pending.sort(compareItems);
    bought.sort(compareItems);

    return [...pending, ...bought];
  }

  @override
  Widget build(BuildContext context) {
    final allItems = Provider.of<MarketItemController>(
      context,
    ).items.where((item) => widget.purchase.itemIds.contains(item.id)).toList();

    // Aplicar ordenação
    final sortedItems = _sortItems(allItems);
    final visibleItems = _showBoughtItems
        ? sortedItems
        : sortedItems.where((item) => !(_isAdded[item.id] ?? false)).toList();

    double _calculateTotal(List<MarketItem> items) {
      int totalCentavos = items.fold(
        0,
        (sum, item) => sum + ((item.priceCentavos ?? 0) * item.quantity),
      );
      return totalCentavos / 100.0;
    }

    final completedCount = allItems
        .where((item) => _isAdded[item.id] == true)
        .length;
    final totalItems = allItems.length;
    final hiddenBoughtCount = sortedItems.length - visibleItems.length;
    final progress = totalItems > 0 ? completedCount / totalItems : 0.0;

    return Scaffold(
      appBar: ComprixAppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.purchase.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Text(
              '$completedCount de $totalItems itens',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          // Botão de filtro
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            tooltip: 'Ordenar',
            onSelected: (SortOption option) {
              setState(() {
                _currentSort = option;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: SortOption.alphabetical,
                child: Row(
                  children: [
                    Icon(
                      Icons.sort_by_alpha,
                      color: _currentSort == SortOption.alphabetical
                          ? AppColors.primaryBlue
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Ordem Alfabética',
                      style: TextStyle(
                        fontWeight: _currentSort == SortOption.alphabetical
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _currentSort == SortOption.alphabetical
                            ? AppColors.primaryBlue
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SortOption.categoryAlphabetical,
                child: Row(
                  children: [
                    Icon(
                      Icons.category,
                      color: _currentSort == SortOption.categoryAlphabetical
                          ? AppColors.primaryBlue
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Por Categoria',
                      style: TextStyle(
                        fontWeight:
                            _currentSort == SortOption.categoryAlphabetical
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _currentSort == SortOption.categoryAlphabetical
                            ? AppColors.primaryBlue
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              completedCount == totalItems
                  ? Icons.check_circle
                  : Icons.shopping_cart_outlined,
              color: Colors.white,
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
                          color: AppColors.backgroundBlue,
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
                                      color: AppColors.backgroundBlue,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.playlist_add,
                                      color: AppColors.primaryBlue,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey[400],
                                  ),
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
                          color: AppColors.backgroundBlue,
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
                                      color: AppColors.backgroundBlue,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.add_circle_outline,
                                      color: AppColors.textPrimary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey[400],
                                  ),
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
                  final itemController = Provider.of<MarketItemController>(
                    context,
                    listen: false,
                  );
                  final allItems = await itemController.getItems();
                  final addedItem = allItems.last;

                  final purchaseController = Provider.of<PurchaseController>(
                    context,
                    listen: false,
                  );
                  final updatedItemIds = List<int>.from(widget.purchase.itemIds)
                    ..add(addedItem.id!);
                  final updatedIsAdded = Map<int, bool>.from(_isAdded)
                    ..[addedItem.id!] = false;
                  final updatedPurchase = Purchase(
                    id: widget.purchase.id,
                    name: widget.purchase.name,
                    date: widget.purchase.date,
                    itemIds: updatedItemIds,
                    totalValue:
                        widget.purchase.totalValue +
                        (((addedItem.priceCentavos ?? 0) * addedItem.quantity) /
                            100.0),
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
                    builder: (_) =>
                        SelectItemPage(excludeItemIds: widget.purchase.itemIds),
                  ),
                );

                if (selectedItem != null) {
                  final purchaseController = Provider.of<PurchaseController>(
                    context,
                    listen: false,
                  );
                  final updatedItemIds = List<int>.from(widget.purchase.itemIds)
                    ..add(selectedItem.id!);
                  final updatedIsAdded = Map<int, bool>.from(_isAdded)
                    ..[selectedItem.id!] = false;
                  final updatedPurchase = Purchase(
                    id: widget.purchase.id,
                    name: widget.purchase.name,
                    date: widget.purchase.date,
                    itemIds: updatedItemIds,
                    totalValue:
                        widget.purchase.totalValue +
                        (((selectedItem.priceCentavos ?? 0) *
                                selectedItem.quantity) /
                            100.0),
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // Header com progresso (compacto)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.white],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryBlue.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.shopping_cart_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Progresso da compra',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[800],
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: completedCount == totalItems
                                ? LinearGradient(
                                    colors: [
                                      AppColors.textSecondary,
                                      AppColors.textPrimary,
                                    ],
                                  )
                                : AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (completedCount == totalItems
                                            ? AppColors.textPrimary
                                            : AppColors.primaryBlue)
                                        .withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Stack(
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              gradient: completedCount == totalItems
                                  ? LinearGradient(
                                      colors: [
                                        AppColors.textSecondary,
                                        AppColors.textPrimary,
                                      ],
                                    )
                                  : AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (completedCount == totalItems
                                              ? AppColors.textPrimary
                                              : AppColors.primaryBlue)
                                          .withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _showBoughtItems = !_showBoughtItems;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.divider),
                            foregroundColor: AppColors.textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          icon: Icon(
                            _showBoughtItems
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 16,
                          ),
                          label: Text(
                            _showBoughtItems
                                ? 'Ocultar comprados'
                                : 'Mostrar comprados',
                          ),
                        ),
                        if (!_showBoughtItems && hiddenBoughtCount > 0) ...[
                          const SizedBox(width: 10),
                          Text(
                            '$hiddenBoughtCount oculto${hiddenBoughtCount > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (completedCount == totalItems)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.backgroundBlue,
                              AppColors.backgroundBlue,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.divider,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColors.textPrimary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.textPrimary.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Compra finalizada com sucesso!',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: visibleItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.grey[100]!,
                                    Colors.grey[200]!,
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.shopping_basket_rounded,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              totalItems == 0
                                  ? 'Nenhum item nesta compra'
                                  : 'Itens comprados ocultos',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              totalItems == 0
                                  ? 'Adicione itens para começar'
                                  : 'Toque em "Mostrar comprados" para visualizar',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            if (totalItems > 0 && !_showBoughtItems) ...[
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _showBoughtItems = true;
                                  });
                                },
                                child: const Text('Mostrar comprados'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: ListView.builder(
                          itemCount: visibleItems.length,
                          itemBuilder: (context, index) {
                            final MarketItem item = visibleItems[index];
                            final isChecked = _isAdded[item.id] ?? false;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isChecked
                                      ? AppColors.divider
                                      : AppColors.primaryBlue.withValues(
                                          alpha: 0.12,
                                        ),
                                  width: 1.2,
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
                                  onTap: () async {
                                    await _handleItemToggle(item, isChecked);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isChecked
                                                  ? AppColors.textPrimary
                                                  : Colors.grey[400]!,
                                              width: 2,
                                            ),
                                            gradient: isChecked
                                                ? LinearGradient(
                                                    colors: [
                                                      AppColors.textSecondary,
                                                      AppColors.textPrimary,
                                                    ],
                                                  )
                                                : null,
                                            color: isChecked
                                                ? null
                                                : Colors.transparent,
                                            boxShadow: isChecked
                                                ? [
                                                    BoxShadow(
                                                      color: AppColors
                                                          .textPrimary
                                                          .withOpacity(0.4),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: isChecked
                                              ? const Icon(
                                                  Icons.check_rounded,
                                                  size: 16,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.textPrimary,
                                                  decoration: isChecked
                                                      ? TextDecoration
                                                            .lineThrough
                                                      : null,
                                                  decorationColor:
                                                      Colors.grey[500],
                                                  decorationThickness: 2,
                                                  letterSpacing: -0.3,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColors.getCategoryColorLight(
                                                            item.category,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                      border: Border.all(
                                                        color:
                                                            AppColors.getCategoryColor(
                                                              item.category,
                                                            ).withOpacity(0.4),
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .category_rounded,
                                                          size: 10,
                                                          color:
                                                              AppColors.getCategoryColor(
                                                                item.category,
                                                              ).withOpacity(
                                                                0.85,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          width: 3,
                                                        ),
                                                        Text(
                                                          item.category ??
                                                              'Sem categoria',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color:
                                                                AppColors.getCategoryColor(
                                                                  item.category,
                                                                ).withOpacity(
                                                                  0.85,
                                                                ),
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          AppColors
                                                              .backgroundBlue,
                                                          AppColors
                                                              .backgroundBlue,
                                                        ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: AppColors
                                                              .textSecondary
                                                              .withOpacity(0.2),
                                                          blurRadius: 4,
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
                                                              .inventory_2_rounded,
                                                          size: 12,
                                                          color: AppColors
                                                              .textPrimary,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          'Qtd: ${item.quantity}',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: AppColors
                                                                .textPrimary,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: isChecked
                                                            ? [
                                                                AppColors
                                                                    .backgroundBlue,
                                                                AppColors
                                                                    .divider,
                                                              ]
                                                            : [
                                                                AppColors
                                                                    .backgroundBlue,
                                                                AppColors
                                                                    .accentBlue,
                                                              ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color:
                                                              (isChecked
                                                                      ? AppColors
                                                                            .textPrimary
                                                                      : AppColors
                                                                            .primaryBlue)
                                                                  .withOpacity(
                                                                    0.2,
                                                                  ),
                                                          blurRadius: 4,
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
                                                              .attach_money_rounded,
                                                          size: 14,
                                                          color: isChecked
                                                              ? AppColors
                                                                    .textPrimary
                                                              : AppColors
                                                                    .primaryBlueDark,
                                                        ),
                                                        Text(
                                                          PriceHelper.centavosToFormattedString(
                                                            item.priceCentavos ??
                                                                0,
                                                          ),
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: isChecked
                                                                ? AppColors
                                                                      .textPrimary
                                                                : AppColors
                                                                      .primaryBlueDark,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            letterSpacing: -0.5,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        PopupMenuButton<String>(
                                          icon: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.grey[100]!,
                                                  Colors.grey[200]!,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.more_vert_rounded,
                                              size: 20,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 8,
                                          shadowColor: Colors.black.withOpacity(
                                            0.1,
                                          ),
                                          color: Colors.white,
                                          onSelected: (value) async {
                                            if (value == 'editar') {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ItemDetailPage(
                                                        item: item,
                                                      ),
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
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets.all(24),
                                                  title: Row(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: AppColors
                                                              .textPrimary
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        child: Icon(
                                                          Icons
                                                              .warning_amber_rounded,
                                                          color: AppColors
                                                              .textPrimary,
                                                          size: 24,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      const Expanded(
                                                        child: Text(
                                                          'Remover item?',
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Tem certeza que deseja remover "${item.name}" do seu carrinho de compras?',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors.grey[700],
                                                          height: 1.4,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 16,
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              12,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          border: Border.all(
                                                            color: Colors
                                                                .grey[200]!,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .info_outline,
                                                              size: 16,
                                                              color: AppColors
                                                                  .primaryBlue,
                                                            ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                'Esta ação não pode ser desfeita.',
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .grey[600],
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
                                                          Navigator.pop(
                                                            context,
                                                            false,
                                                          ),
                                                      style: TextButton.styleFrom(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 20,
                                                              vertical: 12,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        'Cancelar',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            true,
                                                          ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            AppColors
                                                                .textPrimary,
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 20,
                                                              vertical: 12,
                                                            ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        'Remover',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirmed == true) {
                                                final purchaseController =
                                                    Provider.of<
                                                      PurchaseController
                                                    >(context, listen: false);
                                                final updatedItemIds =
                                                    List<int>.from(
                                                      widget.purchase.itemIds,
                                                    )..remove(item.id);
                                                final updatedIsAdded =
                                                    Map<int, bool>.from(
                                                      _isAdded,
                                                    )..remove(item.id);
                                                final updatedPurchase = Purchase(
                                                  id: widget.purchase.id,
                                                  name: widget.purchase.name,
                                                  date: widget.purchase.date,
                                                  itemIds: updatedItemIds,
                                                  totalValue:
                                                      widget
                                                          .purchase
                                                          .totalValue -
                                                      (((item.priceCentavos ??
                                                                  0) *
                                                              item.quantity) /
                                                          100.0),
                                                  isAdded: updatedIsAdded,
                                                );
                                                await purchaseController
                                                    .updatePurchase(
                                                      updatedPurchase,
                                                    );
                                                setState(() {
                                                  _isAdded = updatedIsAdded;
                                                  widget.purchase.itemIds
                                                      .remove(item.id);
                                                });
                                              }
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: 'editar',
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .primaryBlue
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                      child: Icon(
                                                        Icons.edit_rounded,
                                                        size: 16,
                                                        color: AppColors
                                                            .primaryBlue,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          'Editar item',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors
                                                                .grey[800],
                                                          ),
                                                        ),
                                                        Text(
                                                          'Alterar dados do produto',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey[600],
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .textPrimary
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .remove_shopping_cart_outlined,
                                                        size: 16,
                                                        color: AppColors
                                                            .textPrimary,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          'Remover do carrinho',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: AppColors
                                                                .textPrimary,
                                                          ),
                                                        ),
                                                        Text(
                                                          'Excluir da lista de compras',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: AppColors
                                                                .textSecondary,
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
              // Footer com total (compacto)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.white],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, -2),
                    ),
                  ],
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: completedCount == totalItems
                              ? [
                                  AppColors.backgroundBlue,
                                  AppColors.backgroundBlue,
                                ]
                              : [
                                  AppColors.backgroundBlue,
                                  AppColors.backgroundBlue,
                                ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: completedCount == totalItems
                              ? AppColors.divider
                              : AppColors.primaryBlueLight.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (completedCount == totalItems
                                        ? AppColors.textPrimary
                                        : AppColors.primaryBlue)
                                    .withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: completedCount == totalItems
                                      ? LinearGradient(
                                          colors: [
                                            AppColors.textSecondary,
                                            AppColors.textPrimary,
                                          ],
                                        )
                                      : AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          (completedCount == totalItems
                                                  ? AppColors.textPrimary
                                                  : AppColors.primaryBlue)
                                              .withOpacity(0.4),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  completedCount == totalItems
                                      ? Icons.check_circle_rounded
                                      : Icons.shopping_cart_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Total da compra: ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  Text(
                                    PriceHelper.centavosToFormattedString(
                                      (_calculateTotal(sortedItems) * 100)
                                          .round(),
                                    ),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: completedCount == totalItems
                                          ? AppColors.textPrimary
                                          : AppColors.primaryBlue,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (completedCount == totalItems)
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.textPrimary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.textPrimary.withOpacity(
                                      0.4,
                                    ),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.celebration_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (completedCount == totalItems) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.textSecondary,
                              AppColors.textPrimary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.textPrimary.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Parabéns! Compra Finalizada',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                letterSpacing: -0.5,
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
