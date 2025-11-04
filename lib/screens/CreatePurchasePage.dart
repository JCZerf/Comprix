import 'package:flutter/material.dart';
import 'package:market_express/utils/price_helper.dart';
import 'package:provider/provider.dart';

import '../controllers/ItemMarketController.dart';
import '../controllers/PurchasesController.dart';
import '../models/PurchaseModel.dart';

class CreatePurchasePage extends StatefulWidget {
  const CreatePurchasePage({super.key});

  @override
  State<CreatePurchasePage> createState() => _CreatePurchasePageState();
}

class _CreatePurchasePageState extends State<CreatePurchasePage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  DateTime date = DateTime.now();
  final Set<int> selectedItemIds = {};

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<MarketItemController>(context).items;
    final selectedTotalCentavos = items
        .where((item) => selectedItemIds.contains(item.id))
        .fold<int>(0, (sum, item) => sum + ((item.priceCentavos ?? 0) * item.quantity));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Compra', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.lightBlue[700],
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ),
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          Column(
            children: [
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
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.lightBlue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.playlist_add, color: Colors.lightBlue[700], size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Nova Lista de Compras',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Selecione os itens para sua compra',
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Nome da compra',
                              hintText: 'Ex: Compra do mês',
                              prefixIcon: const Icon(Icons.edit_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onSaved: (value) => name = value!.trim(),
                            validator: (value) =>
                                value == null || value.isEmpty ? 'Informe o nome' : null,
                          ),
                          const SizedBox(height: 20),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: date,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) setState(() => date = picked);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, color: Colors.grey[600]),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Data da compra',
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${date.day}/${date.month}/${date.year}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Itens disponíveis',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              if (selectedItemIds.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlue[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${selectedItemIds.length} selecionado${selectedItemIds.length != 1 ? 's' : ''}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.lightBlue[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (items.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.inventory_outlined,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Nenhum item cadastrado',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Adicione itens na lista primeiro',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...items.map(
                              (item) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selectedItemIds.contains(item.id)
                                        ? Colors.lightBlue[300]!
                                        : Colors.grey[200]!,
                                    width: selectedItemIds.contains(item.id) ? 2 : 1,
                                  ),
                                ),
                                child: CheckboxListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  title: Text(
                                    item.name,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.category ?? ''),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Qtd: ${item.quantity}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            PriceHelper.centavosToFormattedString(
                                              item.priceCentavos ?? 0,
                                            ),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.lightBlue[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  value: selectedItemIds.contains(item.id),
                                  onChanged: (checked) {
                                    setState(() {
                                      if (checked == true) {
                                        selectedItemIds.add(item.id!);
                                      } else {
                                        selectedItemIds.remove(item.id);
                                      }
                                    });
                                  },
                                  activeColor: Colors.lightBlue[700],
                                  controlAffinity: ListTileControlAffinity.trailing,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (selectedItemIds.isNotEmpty)
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
                            'Total estimado:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            PriceHelper.centavosToFormattedString(selectedTotalCentavos),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue[700],
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate() && selectedItemIds.isNotEmpty) {
                              _formKey.currentState!.save();
                              final Map<int, bool> isAdded = {
                                for (var id in selectedItemIds) id: false,
                              };
                              final purchase = Purchase(
                                name: name,
                                date: date,
                                itemIds: selectedItemIds.toList(),
                                totalValue: selectedTotalCentavos / 100.0,
                                isAdded: isAdded,
                              );
                              Provider.of<PurchaseController>(
                                context,
                                listen: false,
                              ).addPurchase(purchase);
                              Navigator.pop(context);
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.shopping_cart),
                              const SizedBox(width: 8),
                              Text(
                                'Criar Compra (${selectedItemIds.length} ${selectedItemIds.length == 1 ? 'item' : 'itens'})',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
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
