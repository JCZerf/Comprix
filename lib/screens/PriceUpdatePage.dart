import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/ItemMarketController.dart';
import '../controllers/ItemPriceController.dart';
import '../models/ItemMarketModel.dart';
import '../utils/price_helper.dart';
import '../widgets/price_form_field.dart';

class PriceUpdatePage extends StatefulWidget {
  final MarketItem item;

  const PriceUpdatePage({super.key, required this.item});

  @override
  State<PriceUpdatePage> createState() => _PriceUpdatePageState();
}

class _PriceUpdatePageState extends State<PriceUpdatePage> {
  final _priceController = TextEditingController();
  int? newPriceCentavos;

  @override
  void initState() {
    super.initState();
    final currentCentavos = widget.item.priceCentavos ?? 0;
    _priceController.text = PriceHelper.centavosToFormattedStringNoSymbol(currentCentavos);
    newPriceCentavos = currentCentavos;

    // Carrega o histórico de preços
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.item.id != null) {
        Provider.of<ItemPriceController>(context, listen: false).loadPriceHistory(widget.item.id!);
      }
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atualizar Preço', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.lightBlue[700],
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
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
                                    color: Colors.lightBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.inventory_2,
                                    color: Colors.lightBlue[700],
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
                                color: Colors.grey[50],
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

                            // Campo novo preço
                            PriceFormField(
                              labelText: 'Novo preço',
                              hintText: '0,00',
                              initialCentavos: newPriceCentavos,
                              onChanged: (centavos) {
                                setState(() {
                                  newPriceCentavos = centavos;
                                });
                              },
                              onSaved: (centavos) {
                                setState(() {
                                  newPriceCentavos = centavos;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Novo preço',
                                hintText: '0,00',
                                prefixIcon: const Icon(Icons.price_change),
                                prefixText: 'R\$ ',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Comparação de preços
                            if (newPriceCentavos != null &&
                                newPriceCentavos != (widget.item.priceCentavos ?? 0))
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _getPriceChangeColor().withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getPriceChangeColor().withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getPriceChangeIcon(),
                                      color: _getPriceChangeColor(),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _getPriceChangeText(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: _getPriceChangeColor(),
                                            ),
                                          ),
                                          Text(
                                            'Diferença: ${PriceHelper.centavosToFormattedString((_getPriceDifference().abs() * 100).round())}',
                                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${_getPriceChangePercentage().toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: _getPriceChangeColor(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                                      Icon(Icons.history, color: Colors.lightBlue[700]),
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
                                                  ? Colors.lightBlue[700]
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
                                                color: Colors.green.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                'Atual',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.green[700],
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
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size(0, 56),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue[700],
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size(0, 56),
                          ),
                          onPressed:
                              newPriceCentavos != null &&
                                  newPriceCentavos != (widget.item.priceCentavos ?? 0) &&
                                  newPriceCentavos! > 0
                              ? () async {
                                  if (widget.item.id != null) {
                                    try {
                                      // Atualiza o preço do item e o histórico
                                      await Provider.of<ItemPriceController>(
                                        context,
                                        listen: false,
                                      ).updateItemPrice(widget.item.id!, newPriceCentavos! / 100.0);

                                      // Recarrega os itens no controller principal para sincronizar
                                      await Provider.of<MarketItemController>(
                                        context,
                                        listen: false,
                                      ).loadItems();

                                      Navigator.pop(context, newPriceCentavos! / 100.0);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Erro ao atualizar preço: ${e.toString()}'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              : null,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.update),
                              SizedBox(width: 8),
                              Text(
                                'Atualizar Preço',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
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

  Color _getPriceChangeColor() {
    final difference = _getPriceDifference();
    if (difference > 0) return Colors.red;
    if (difference < 0) return Colors.green;
    return Colors.grey;
  }

  IconData _getPriceChangeIcon() {
    final difference = _getPriceDifference();
    if (difference > 0) return Icons.trending_up;
    if (difference < 0) return Icons.trending_down;
    return Icons.trending_flat;
  }

  String _getPriceChangeText() {
    final difference = _getPriceDifference();
    if (difference > 0) return 'Preço vai subir';
    if (difference < 0) return 'Preço vai descer';
    return 'Preço mantido';
  }

  double _getPriceDifference() {
    final newValueInReais = (newPriceCentavos ?? 0) / 100.0;
    final currentValueInReais = (widget.item.priceCentavos ?? 0) / 100.0;
    return newValueInReais - currentValueInReais;
  }

  double _getPriceChangePercentage() {
    final currentPriceInReais = (widget.item.priceCentavos ?? 0) / 100.0;
    if (currentPriceInReais == 0) return 0.0;
    return ((_getPriceDifference()) / currentPriceInReais) * 100;
  }
}
