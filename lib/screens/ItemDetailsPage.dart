import 'package:flutter/material.dart';
import 'package:market_express/controllers/ItemMarketController.dart';
import 'package:market_express/controllers/ItemPriceController.dart';
import 'package:market_express/models/ItemMarketModel.dart';
import 'package:market_express/screens/PriceUpdatePage.dart';
import 'package:market_express/services/LoadCategories.dart';
import 'package:market_express/utils/watermark_widget.dart';
import 'package:market_express/widgets/price_form_field.dart';
import 'package:provider/provider.dart';

class ItemDetailPage extends StatefulWidget {
  final MarketItem item;
  const ItemDetailPage({super.key, required this.item});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late int priceCentavos;
  late int quantity;
  late String description;
  late String category;
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    name = widget.item.name;
    priceCentavos = widget.item.priceCentavos ?? 0;
    quantity = widget.item.quantity;
    description = widget.item.description ?? '';
    category = widget.item.category ?? '';
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final loadedCategories = await CategoryService.loadCategories();
    setState(() {
      categories = loadedCategories;
      if (category.isNotEmpty && !categories.contains(category)) {
        categories = [category, ...categories];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Item', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.lightBlue[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Excluir item'),
                  content: Text('Deseja excluir "${widget.item.name}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<MarketItemController>(
                          context,
                          listen: false,
                        ).deleteItem(widget.item.id!);
                        Navigator.pop(context); // Fecha o dialog
                        Navigator.pop(context); // Volta para a homepage
                      },
                      child: const Text('Excluir'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: categories.isEmpty
                    ? Container(
                        color: Colors.white,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Carregando categorias...'),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
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
                                  Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Colors.lightBlue[100],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.edit_outlined,
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
                                              'Editar Item',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              'Modifique as informações do item',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
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
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFormField(
                                      child: TextFormField(
                                        initialValue: name,
                                        decoration: InputDecoration(
                                          labelText: 'Nome do item',
                                          prefixIcon: const Icon(Icons.inventory_2_outlined),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        onSaved: (value) => name = value!.trim(),
                                        validator: (value) => value == null || value.isEmpty
                                            ? 'Informe o nome'
                                            : null,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildFormField(
                                            child: PriceFormField(
                                              labelText: 'Preço',
                                              initialCentavos: priceCentavos,
                                              onSaved: (centavos) => priceCentavos = centavos,
                                              validator: (value) => null,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildFormField(
                                            child: TextFormField(
                                              initialValue: quantity.toString(),
                                              decoration: InputDecoration(
                                                labelText: 'Quantidade',
                                                prefixIcon: const Icon(Icons.numbers),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                filled: true,
                                                fillColor: Colors.white,
                                              ),
                                              keyboardType: TextInputType.number,
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
                                        initialValue: description,
                                        decoration: InputDecoration(
                                          labelText: 'Descrição',
                                          prefixIcon: const Icon(Icons.description_outlined),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        maxLines: 3,
                                        onSaved: (value) => description = value!.trim(),
                                        validator: (value) => value == null || value.isEmpty
                                            ? 'Informe a descrição'
                                            : null,
                                      ),
                                    ),
                                    _buildFormField(
                                      child: DropdownButtonFormField<String>(
                                        decoration: InputDecoration(
                                          labelText: 'Categoria',
                                          prefixIcon: const Icon(Icons.category_outlined),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        value: category.isEmpty || !categories.contains(category)
                                            ? null
                                            : category,
                                        items: categories
                                            .map(
                                              (cat) =>
                                                  DropdownMenuItem(value: cat, child: Text(cat)),
                                            )
                                            .toList(),
                                        onChanged: (value) =>
                                            setState(() => category = value ?? ''),
                                        validator: (value) => null,
                                      ),
                                    ),
                                    const SizedBox(height: 4),

                                    // Botão de atualizar preço
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.blue[700],
                                          side: BorderSide(color: Colors.blue[300]!),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: () async {
                                          final updatedPrice = await Navigator.push<double>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ChangeNotifierProvider(
                                                create: (_) => ItemPriceController(),
                                                child: PriceUpdatePage(item: widget.item),
                                              ),
                                            ),
                                          );

                                          if (updatedPrice != null) {
                                            final newPriceCentavos = (updatedPrice * 100).round();
                                            setState(() {
                                              priceCentavos = newPriceCentavos;
                                            });
                                            // A atualização no banco já foi feita pelo PriceUpdatePage
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.price_change, color: Colors.blue[700]),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Atualizar Preço e Ver Histórico',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue[700],
                                              ),
                                            ),
                                          ],
                                        ),
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
              // Marca de água acima dos botões
              const Padding(
                padding: EdgeInsets.only(bottom: 8, left: 16, right: 16),
                child: WatermarkWidget(),
              ),
              // Botões fixos na parte inferior
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
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              final updatedItem = MarketItem(
                                id: widget.item.id,
                                name: name,
                                priceCentavos: priceCentavos,
                                quantity: quantity,
                                description: description,
                                category: category,
                              );
                              await Provider.of<MarketItemController>(
                                context,
                                listen: false,
                              ).updateItem(updatedItem);
                              Navigator.pop(context);
                            }
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_outlined),
                              SizedBox(width: 8),
                              Text(
                                'Salvar Alterações',
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
