import 'package:flutter/material.dart';

import '../features/collections/presentation/pages/catalog_page.dart';
import '../features/collections/presentation/pages/collections_page.dart';
import '../features/templates/presentation/pages/catalog_admin_page.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.system;
  int colorIndex = 0;

  static const colors = [
    Colors.indigo,
    Colors.teal,
    Colors.deepPurple,
    Colors.orange,
    Colors.green,
  ];

  static const colorNames = [
    'Индиго',
    'Бирюзовый',
    'Фиолетовый',
    'Оранжевый',
    'Зелёный',
  ];

  @override
  Widget build(BuildContext context) {
    final seed = colors[colorIndex];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Collection Catalog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeMode,
      home: MainNavigation(
        themeMode: themeMode,
        colorIndex: colorIndex,
        onThemeChanged: (value) => setState(() => themeMode = value),
        onColorChanged: (value) => setState(() => colorIndex = value),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final ThemeMode themeMode;
  final int colorIndex;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<int> onColorChanged;

  const MainNavigation({
    super.key,
    required this.themeMode,
    required this.colorIndex,
    required this.onThemeChanged,
    required this.onColorChanged,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  // Эти страницы не пересоздаются при каждом изменении темы или цвета.
  // Это сохраняет их State и не ломает открытые поля, диалоги и навигацию.
  late final Widget _catalogPage = const CatalogPage();
  late final Widget _downloadsPage = const Center(
    child: Text('Загрузки пока не используются'),
  );
  late final Widget _collectionsPage = const CollectionsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          _catalogPage,
          _downloadsPage,
          _collectionsPage,
          _SettingsPage(
            themeMode: widget.themeMode,
            colorIndex: widget.colorIndex,
            onThemeChanged: widget.onThemeChanged,
            onColorChanged: widget.onColorChanged,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => setState(() => currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Каталог',
          ),
          NavigationDestination(
            icon: Icon(Icons.download_outlined),
            selectedIcon: Icon(Icons.download),
            label: 'Загрузки',
          ),
          NavigationDestination(
            icon: Icon(Icons.collections_bookmark_outlined),
            selectedIcon: Icon(Icons.collections_bookmark),
            label: 'Коллекции',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  final ThemeMode themeMode;
  final int colorIndex;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<int> onColorChanged;

  const _SettingsPage({
    required this.themeMode,
    required this.colorIndex,
    required this.onThemeChanged,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: const Text('Администратор каталогов'),
              subtitle: const Text('Создание, удаление и настройка каталогов'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CatalogAdminPage(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('Тема оформления'),
              subtitle: Text(_themeName(themeMode)),
              onTap: () => _showThemes(context),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.color_lens_outlined),
              title: const Text('Цвет приложения'),
              subtitle: Text(_MyAppState.colorNames[colorIndex]),
              onTap: () => _showColors(context),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Справка о приложении'),
              subtitle: const Text('Краткая информация и основные возможности'),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'Collection Catalog',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.collections_bookmark),
                children: const [
                  Text(
                    'Приложение помогает создавать каталоги, добавлять предметы, поля, изображения и вложения, а также организовывать коллекции по выбранной структуре.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _themeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Системная';
      case ThemeMode.light:
        return 'Светлая';
      case ThemeMode.dark:
        return 'Тёмная';
    }
  }

  Future<void> _showThemes(BuildContext context) async {
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            final isSelected = mode == themeMode;
            return ListTile(
              leading: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              title: Text(_themeName(mode)),
              selected: isSelected,
              onTap: () => Navigator.pop(sheetContext, mode),
            );
          }).toList(),
        ),
      ),
    );

    if (selected != null) {
      onThemeChanged(selected);
    }
  }

  Future<void> _showColors(BuildContext context) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: List.generate(
            _MyAppState.colors.length,
            (index) => ListTile(
              leading: CircleAvatar(
                backgroundColor: _MyAppState.colors[index],
              ),
              title: Text(_MyAppState.colorNames[index]),
              trailing: index == colorIndex ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(sheetContext, index),
            ),
          ),
        ),
      ),
    );

    if (selected != null) {
      onColorChanged(selected);
    }
  }
}
