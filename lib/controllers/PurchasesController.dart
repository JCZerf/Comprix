import 'package:flutter/material.dart';
import 'package:market_express/db/DbHelper.dart';

import '../models/PurchaseModel.dart';

class PurchaseController extends ChangeNotifier {
  List<Purchase> _purchases = [];

  List<Purchase> get purchases => _purchases;

  PurchaseController() {
    loadPurchases();
  }

  Future<void> loadPurchases() async {
    _purchases = await DBHelper.getPurchases();
    notifyListeners();
  }

  Future<void> addPurchase(Purchase purchase) async {
    await DBHelper.insertPurchase(purchase);
    await loadPurchases();
  }

  Future<void> updatePurchase(Purchase purchase) async {
    await DBHelper.updatePurchase(purchase);
    await loadPurchases();
  }

  Future<void> deletePurchase(int id) async {
    await DBHelper.deletePurchase(id);
    await loadPurchases();
  }

  Purchase? getPurchaseById(int id) {
    try {
      return _purchases.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
