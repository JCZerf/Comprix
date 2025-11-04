import 'package:flutter/material.dart';
import 'package:market_express/screens/HomePage.dart';
import 'package:market_express/screens/PurchasesListPage.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [HomePage(), PurchasesListPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.lightBlue[700],
        unselectedItemColor: Colors.lightBlue[200],
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Lista'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Compras'),
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
