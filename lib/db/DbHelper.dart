import 'package:market_express/models/PurchaseModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/ItemMarketModel.dart';

class DBHelper {
  static Future<Database> _getDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'market_express.db'),
      version: 5,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            price REAL,
            priceCentavos INTEGER,
            quantity INTEGER,
            description TEXT,
            category TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE purchases(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            date TEXT,
            itemIds TEXT,
            totalValue REAL,
            isAdded TEXT
          )
        ''');

        await db.execute('''
        CREATE TABLE item_prices(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          itemId INTEGER,
          price REAL,
          date TEXT
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE purchases ADD COLUMN isAdded TEXT');
        }
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS item_prices(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              itemId INTEGER,
              price REAL,
              date TEXT
            )
          ''');
        }
        if (oldVersion < 5) {
          await db.execute('ALTER TABLE items ADD COLUMN priceCentavos INTEGER');

          // Migra os dados existentes: converte price para priceCentavos
          final List<Map<String, dynamic>> items = await db.query('items');
          for (final item in items) {
            if (item['price'] != null) {
              int priceCentavos = ((item['price'] as double) * 100).round();
              await db.update(
                'items',
                {'priceCentavos': priceCentavos},
                where: 'id = ?',
                whereArgs: [item['id']],
              );
            }
          }
        }
      },
    );
  }

  // Métodos para Item
  static Future<int> insertItem(MarketItem item) async {
    final db = await _getDatabase();
    final itemId = await db.insert('items', item.toMap());

    // Registra o preço inicial no histórico se não for null
    if (item.price != null && item.price! > 0) {
      await insertItemPriceHistory(itemId, item.price!);
    }

    return itemId;
  }

  static Future<List<MarketItem>> getItems() async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('items');
    return List.generate(maps.length, (i) => MarketItem.fromMap(maps[i]));
  }

  static Future<int> updateItem(MarketItem item) async {
    final db = await _getDatabase();
    return db.update('items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  static Future<int> deleteItem(int id) async {
    final db = await _getDatabase();
    return db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  // Métodos para Purchase
  static Future<int> insertPurchase(Purchase purchase) async {
    final db = await _getDatabase();
    return db.insert('purchases', purchase.toMap());
  }

  static Future<List<Purchase>> getPurchases() async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'purchases',
      orderBy: 'date DESC, id DESC',
    );
    return List.generate(maps.length, (i) => Purchase.fromMap(maps[i]));
  }

  static Future<int> updatePurchase(Purchase purchase) async {
    final db = await _getDatabase();
    return db.update('purchases', purchase.toMap(), where: 'id = ?', whereArgs: [purchase.id]);
  }

  static Future<int> deletePurchase(int id) async {
    final db = await _getDatabase();
    return db.delete('purchases', where: 'id = ?', whereArgs: [id]);
  }

  // Métodos para histórico de preços
  static Future<void> updateItemPrice(int itemId, double newPrice) async {
    final db = await _getDatabase();
    int priceCentavos = (newPrice * 100).round();

    await db.update(
      'items',
      {'price': newPrice, 'priceCentavos': priceCentavos},
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  static Future<void> insertItemPriceHistory(int itemId, double price) async {
    final db = await _getDatabase();

    await db.insert('item_prices', {
      'itemId': itemId,
      'price': price,
      'date': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getItemPriceHistory(int itemId) async {
    final db = await _getDatabase();
    return await db.query(
      'item_prices',
      where: 'itemId = ?',
      whereArgs: [itemId],
      orderBy: 'date DESC',
    );
  }
}
