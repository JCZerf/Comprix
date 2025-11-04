import 'package:flutter/material.dart';
import 'package:market_express/controllers/ItemMarketController.dart';
import 'package:market_express/controllers/ItemPriceController.dart';
import 'package:market_express/controllers/PurchasesController.dart';
import 'package:market_express/screens/MainNavigation.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MarketItemController()),
        ChangeNotifierProvider(create: (_) => PurchaseController()),
        ChangeNotifierProvider(create: (_) => ItemPriceController()),
      ],
      child: const MarketExpressApp(),
    ),
  );
}

class MarketExpressApp extends StatelessWidget {
  const MarketExpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Market Express',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.lightBlue[700],
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          shadowColor: Colors.transparent,
          titleTextStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          iconTheme: const IconThemeData(color: Colors.white, size: 24),
          actionsIconTheme: const IconThemeData(color: Colors.white, size: 24),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.lightBlue[700],
          foregroundColor: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue[700],
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
      ),
      home: const MainNavigation(),
    );
  }
}
