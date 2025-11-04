import 'package:flutter/material.dart';
import 'package:market_express/services/LoadCategories.dart';
import 'package:market_express/widgets/price_form_field.dart';
import 'package:provider/provider.dart';

import '../controllers/ItemMarketController.dart';
import '../models/ItemMarketModel.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  int priceCentavos = 0;
  int quantity = 1;
  String description = '';
  String? category;
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final loadedCategories = await CategoryService.loadCategories();
    setState(() {
      categories = loadedCategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Item', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.lightBlue[700],
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ),
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            Icon(Icons.add_shopping_cart, size: 32, color: Colors.lightBlue[700]),
                            const SizedBox(height: 8),
                            const Text(
                              'Novo Item',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Preencha as informações do item',
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFormField(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Nome do item',
                                    hintText: 'Ex: Arroz integral',
                                    prefixIcon: const Icon(Icons.inventory_2_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  onSaved: (value) => name = value!.trim(),
                                  validator: (value) =>
                                      value == null || value.isEmpty ? 'Informe o nome' : null,
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFormField(
                                      child: PriceFormField(
                                        labelText: 'Preço',
                                        hintText: '0,00',
                                        onSaved: (centavos) => priceCentavos = centavos,
                                        validator: (value) => null,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildFormField(
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          labelText: 'Quantidade',
                                          hintText: '1',
                                          prefixIcon: const Icon(Icons.numbers),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        keyboardType: TextInputType.number,
                                        initialValue: '1',
                                        onSaved: (value) =>
                                            quantity = int.tryParse(value ?? '1') ?? 1,
                                        validator: (value) => value == null || value.isEmpty
                                            ? 'Informe a quantidade'
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              _buildFormField(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Descrição',
                                    hintText: 'Detalhes sobre o item (opcional)',
                                    prefixIcon: const Icon(Icons.description_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  maxLines: 3,
                                  onSaved: (value) => description = value?.trim() ?? '',
                                  validator: (value) => null,
                                ),
                              ),
                              _buildFormField(
                                child: categories.isEmpty
                                    ? Container(
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey[300]!),
                                        ),
                                        child: const Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              ),
                                              SizedBox(width: 12),
                                              Text('Carregando categorias...'),
                                            ],
                                          ),
                                        ),
                                      )
                                    : DropdownButtonFormField<String>(
                                        decoration: InputDecoration(
                                          labelText: 'Categoria',
                                          hintText: 'Selecione uma categoria',
                                          prefixIcon: const Icon(Icons.category_outlined),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        value: category,
                                        items: categories
                                            .map(
                                              (cat) =>
                                                  DropdownMenuItem(value: cat, child: Text(cat)),
                                            )
                                            .toList(),
                                        onChanged: (value) => setState(() => category = value),
                                        validator: (value) => null,
                                      ),
                              ),
                              const SizedBox(height: 120), // Espaço para os botões fixos
                            ],
                          ),
                        ),
                      ),
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
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue[700],
                            foregroundColor: Colors.white,
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              final newItem = MarketItem(
                                name: name,
                                priceCentavos: priceCentavos,
                                quantity: quantity,
                                description: description,
                                category: category,
                              );
                              final itemController = Provider.of<MarketItemController>(
                                context,
                                listen: false,
                              );
                              await itemController.addItem(newItem);

                              final allItems = await itemController.getItems();
                              final addedItem = allItems.last;

                              Navigator.pop(
                                context,
                                addedItem,
                              ); // Retorna o item para a tela anterior
                            }
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add),
                              SizedBox(width: 8),
                              Text(
                                'Adicionar Item',
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

  Widget _buildFormField({required Widget child}) {
    return Padding(padding: const EdgeInsets.only(bottom: 20), child: child);
  }
}
