import 'package:flutter/material.dart';
import 'package:market_express/screens/AnalysisPage.dart';
import 'package:market_express/screens/HomePage.dart';
import 'package:market_express/screens/PurchasesListPage.dart';
import 'package:market_express/utils/app_colors.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [HomePage(), PurchasesListPage(), AnalysisPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textLight,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedFontSize: 13,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_rounded), label: 'Lista'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_rounded), label: 'Compras'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: 'Análise'),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
