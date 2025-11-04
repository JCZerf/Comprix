import 'package:flutter/material.dart';

import '../db/DbHelper.dart';

class ItemPriceController extends ChangeNotifier {
  List<Map<String, dynamic>> _priceHistory = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get priceHistory => _priceHistory;
  bool get isLoading => _isLoading;

  // Atualiza o preço do item e registra no histórico
  Future<void> updateItemPrice(int itemId, double newPrice) async {
    _isLoading = true;
    notifyListeners();

    try {
      await DBHelper.updateItemPrice(itemId, newPrice);
      await DBHelper.insertItemPriceHistory(itemId, newPrice);
      await loadPriceHistory(itemId);
    } catch (e) {
      print('Erro ao atualizar preço: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Carrega o histórico de preços do item
  Future<void> loadPriceHistory(int itemId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _priceHistory = await DBHelper.getItemPriceHistory(itemId);
    } catch (e) {
      print('Erro ao carregar histórico: $e');
      _priceHistory = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Registra o primeiro preço quando o item é criado (se não for null)
  Future<void> registerInitialPrice(int itemId, double? price) async {
    if (price != null && price > 0) {
      await DBHelper.insertItemPriceHistory(itemId, price);
    }
  }

  // Limpa o histórico ao sair da tela
  void clearHistory() {
    _priceHistory = [];
    notifyListeners();
  }
}
