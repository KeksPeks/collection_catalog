import 'package:flutter/material.dart';

import '../../features/catalog/presentation/pages/catalog_page.dart';
import '../../features/downloads/presentation/pages/downloads_page.dart';
import '../../features/owned/presentation/pages/owned_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

	final List<Widget> _pages = const [
	  CatalogPage(),
	  DownloadsPage(),
	  OwnedPage(),
	  SettingsPage(),
	];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,

        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book),
            label: 'Каталог',
          ),

          NavigationDestination(
            icon: Icon(Icons.download),
            label: 'Загрузки',
          ),

          NavigationDestination(
            icon: Icon(Icons.check_circle),
            label: 'Коллекция',
          ),

          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}