import 'package:flutter/material.dart';
import 'package:market_express/controllers/ItemMarketController.dart';
import 'package:market_express/models/ItemMarketModel.dart';
import 'package:market_express/screens/AddItemPage.dart';
import 'package:market_express/screens/ItemDetailsPage.dart';
import 'package:market_express/utils/price_helper.dart';
import 'package:market_express/utils/watermark_widget.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<MarketItemController>(context, listen: false).loadItems());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Express', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.lightBlue[700],
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          Column(
            children: [
              // Barra de pesquisa
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar produtos...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[600]),
                            onPressed: () {
                              _searchController.clear();
                              Provider.of<MarketItemController>(
                                context,
                                listen: false,
                              ).clearSearch();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.lightBlue[700]!),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (value) {
                    setState(() {});
                    Provider.of<MarketItemController>(context, listen: false).searchItems(value);
                  },
                ),
              ),
              // Lista de itens
              Expanded(
                child: Consumer<MarketItemController>(
                  builder: (context, controller, child) {
                    if (controller.items.isEmpty) {
                      String emptyMessage = controller.searchQuery.isNotEmpty
                          ? 'Nenhum item encontrado'
                          : 'Sua lista está vazia';
                      String emptySubMessage = controller.searchQuery.isNotEmpty
                          ? 'Tente uma pesquisa diferente'
                          : 'Toque no botão + para adicionar itens';

                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              controller.searchQuery.isNotEmpty
                                  ? Icons.search_off
                                  : Icons.shopping_basket_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              emptyMessage,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              emptySubMessage,
                              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListView.builder(
                        itemCount: controller.items.length,
                        itemBuilder: (context, index) {
                          final MarketItem item = controller.items[index];
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
                                    MaterialPageRoute(builder: (_) => ItemDetailPage(item: item)),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Colors.lightBlue[100],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.inventory_2_outlined,
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
                                              item.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            // Adicionar descrição se existir
                                            if (item.description != null &&
                                                item.description!.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                item.description!,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[700],
                                                  fontStyle: FontStyle.italic,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
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
                                                    color: Colors.lightBlue[700],
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        color: Colors.red[400],
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) => AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              elevation: 8,
                                              backgroundColor: Colors.white,
                                              contentPadding: EdgeInsets.zero,
                                              content: Container(
                                                width: 320,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.all(24),
                                                      child: Column(
                                                        children: [
                                                          RichText(
                                                            textAlign: TextAlign.center,
                                                            text: TextSpan(
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors.grey[700],
                                                                height: 1.4,
                                                              ),
                                                              children: [
                                                                const TextSpan(
                                                                  text:
                                                                      'Tem certeza que deseja excluir o item ',
                                                                ),
                                                                TextSpan(
                                                                  text: '"${item.name}"',
                                                                  style: const TextStyle(
                                                                    fontWeight: FontWeight.w600,
                                                                    color: Colors.black87,
                                                                  ),
                                                                ),
                                                                const TextSpan(text: '?'),
                                                              ],
                                                            ),
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
                                                      padding: const EdgeInsets.all(20),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[50],
                                                        borderRadius: const BorderRadius.only(
                                                          bottomLeft: Radius.circular(20),
                                                          bottomRight: Radius.circular(20),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: OutlinedButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(context),
                                                              style: OutlinedButton.styleFrom(
                                                                padding: const EdgeInsets.symmetric(
                                                                  vertical: 14,
                                                                ),
                                                                side: BorderSide(
                                                                  color: Colors.grey[300]!,
                                                                ),
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(12),
                                                                ),
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
                                                            child: ElevatedButton(
                                                              onPressed: () {
                                                                controller.deleteItem(item.id!);
                                                                Navigator.pop(context);
                                                              },
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor: Colors.red[600],
                                                                foregroundColor: Colors.white,
                                                                padding: const EdgeInsets.symmetric(
                                                                  vertical: 14,
                                                                ),
                                                                elevation: 0,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(12),
                                                                ),
                                                              ),
                                                              child: const Text(
                                                                'Excluir',
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.w600,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
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
                                        },
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
              ),
            ],
          ),
          const WatermarkWidget(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue[700],
        elevation: 4,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddItemPage()));
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
