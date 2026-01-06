import 'package:flutter/material.dart';
import 'package:market_express/services/LoadCategories.dart';
import 'package:market_express/utils/app_colors.dart';
import 'package:market_express/widgets/price_form_field.dart';
import 'package:provider/provider.dart';

import '../controllers/ItemMarketController.dart';
import '../models/ItemMarketModel.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  int priceCentavos = 0;
  int quantity = 1;
  String description = '';
  String? category;
  List<String> categories = [];
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadCategories();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
        title: const Text(
          'Adicionar Item',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header com gradiente e ícone
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x2042A5F5),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
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
                              child: const Icon(
                                Icons.add_shopping_cart_rounded,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Novo Item',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Preencha as informações do produto',
                              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                            ),
                          ],
                        ),
                      ),

                      // Formulário
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nome do item
                              _buildFormField(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Nome do item *',
                                    hintText: 'Ex: Arroz integral 1kg',
                                    prefixIcon: const Icon(
                                      Icons.inventory_2_rounded,
                                      color: AppColors.primaryBlue,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(color: AppColors.divider),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: AppColors.primaryBlue,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 18,
                                    ),
                                  ),
                                  textCapitalization: TextCapitalization.words,
                                  onSaved: (value) => name = value!.trim(),
                                  validator: (value) =>
                                      value == null || value.isEmpty ? 'Informe o nome' : null,
                                ),
                              ),

                              // Preço e Quantidade lado a lado
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFormField(
                                      child: PriceFormField(
                                        labelText: 'Preço *',
                                        hintText: '0,00',
                                        onSaved: (centavos) => priceCentavos = centavos,
                                        validator: (value) => null,
                                        decoration: InputDecoration(
                                          labelText: 'Preço *',
                                          hintText: '0,00',
                                          prefixIcon: const Icon(
                                            Icons.attach_money_rounded,
                                            color: AppColors.success,
                                          ),
                                          prefixText: 'R\$ ',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: BorderSide(color: AppColors.divider),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: const BorderSide(
                                              color: AppColors.primaryBlue,
                                              width: 2,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildFormField(
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          labelText: 'Quantidade *',
                                          hintText: '1',
                                          prefixIcon: const Icon(
                                            Icons.shopping_cart_rounded,
                                            color: AppColors.primaryBlue,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: BorderSide(color: AppColors.divider),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: const BorderSide(
                                              color: AppColors.primaryBlue,
                                              width: 2,
                                            ),
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

                              // Descrição
                              _buildFormField(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Descrição',
                                    hintText: 'Detalhes sobre o item (opcional)',
                                    prefixIcon: const Icon(
                                      Icons.description_rounded,
                                      color: AppColors.accentBlue,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(color: AppColors.divider),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: AppColors.primaryBlue,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    alignLabelWithHint: true,
                                  ),
                                  maxLines: 3,
                                  textCapitalization: TextCapitalization.sentences,
                                  onSaved: (value) => description = value?.trim() ?? '',
                                  validator: (value) => null,
                                ),
                              ),

                              // Categoria
                              _buildFormField(
                                child: categories.isEmpty
                                    ? Container(
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: AppColors.divider),
                                        ),
                                        child: const Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: AppColors.primaryBlue,
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Carregando categorias...',
                                                style: TextStyle(color: AppColors.textSecondary),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : DropdownButtonFormField<String>(
                                        decoration: InputDecoration(
                                          labelText: 'Categoria',
                                          hintText: 'Selecione uma categoria',
                                          prefixIcon: const Icon(
                                            Icons.category_rounded,
                                            color: AppColors.warning,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: BorderSide(color: AppColors.divider),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: const BorderSide(
                                              color: AppColors.primaryBlue,
                                              width: 2,
                                            ),
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
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Botões fixos na parte inferior com design moderno
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
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
                            side: BorderSide(color: AppColors.divider, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: AppColors.primaryBlue.withOpacity(0.3),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => _isLoading = true);
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

                                    if (mounted) {
                                      Navigator.pop(context, addedItem);
                                    }
                                  }
                                },
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.add_rounded, size: 20),
                          label: Text(
                            _isLoading ? 'Salvando...' : 'Adicionar Item',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({required Widget child}) {
    return Padding(padding: const EdgeInsets.only(bottom: 20), child: child);
  }
}
