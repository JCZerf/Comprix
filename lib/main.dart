import 'package:flutter/material.dart';
import 'package:market_express/controllers/ItemMarketController.dart';
import 'package:market_express/controllers/ItemPriceController.dart';
import 'package:market_express/controllers/PurchasesController.dart';
import 'package:market_express/screens/MainNavigation.dart';
import 'package:market_express/utils/app_colors.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MarketItemController()),
        ChangeNotifierProvider(create: (_) => PurchaseController()),
        ChangeNotifierProvider(create: (_) => ItemPriceController()),
      ],
      child: const ComprixApp(),
    ),
  );
}

class ComprixApp extends StatelessWidget {
  const ComprixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comprix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryBlue,
          onPrimary: Colors.white,
          secondary: AppColors.accentBlue,
          onSecondary: Colors.white,
          surface: AppColors.cardBackground,
          onSurface: AppColors.textPrimary,
          error: AppColors.primaryBlue,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        canvasColor: Colors.white,
        cardColor: Colors.white,
        dividerColor: AppColors.divider,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white, size: 24),
          actionsIconTheme: const IconThemeData(color: Colors.white, size: 24),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
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
