import 'package:flutter/material.dart';

import '../db/DbHelper.dart';
import '../models/ItemMarketModel.dart';

class MarketItemController extends ChangeNotifier {
  List<MarketItem> _items = [];
  List<MarketItem> _filteredItems = [];
  String _searchQuery = '';

  List<MarketItem> get items => _searchQuery.isEmpty ? _items : _filteredItems;
  String get searchQuery => _searchQuery;

  Future<void> loadItems() async {
    _items = await DBHelper.getItems();
    _filterItems();
    notifyListeners();
  }

  Future<List<MarketItem>> getItems() async {
    _items = await DBHelper.getItems();
    return _items;
  }

  Future<void> addItem(MarketItem item) async {
    await DBHelper.insertItem(item);
    await loadItems();
  }

  Future<void> updateItem(MarketItem item) async {
    await DBHelper.updateItem(item);
    await loadItems();
  }

  Future<void> deleteItem(int id) async {
    await DBHelper.deleteItem(id);
    await loadItems();
  }

  void searchItems(String query) {
    _searchQuery = query.toLowerCase();
    _filterItems();
    notifyListeners();
  }

  void _filterItems() {
    if (_searchQuery.isEmpty) {
      _filteredItems = [];
    } else {
      _filteredItems = _items.where((item) {
        return item.name.toLowerCase().contains(_searchQuery);
      }).toList();
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredItems = [];
    notifyListeners();
  }
}
