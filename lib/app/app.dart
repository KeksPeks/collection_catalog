import 'package:flutter/material.dart';

import '../features/collections/presentation/pages/catalog_page.dart';
import '../features/collections/presentation/pages/collections_page.dart';
import '../features/downloads/presentation/downloads_page.dart';
import '../features/feedback/presentation/feedback_page.dart';
import '../features/templates/presentation/pages/catalog_admin_page.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

TextTheme _scaleTextTheme(TextTheme base, double scale) {
  TextStyle? scaleStyle(TextStyle? style) {
    if (style == null || style.fontSize == null) return style;
    return style.copyWith(fontSize: style.fontSize! * scale);
  }

  return base.copyWith(
    displayLarge: scaleStyle(base.displayLarge),
    displayMedium: scaleStyle(base.displayMedium),
    displaySmall: scaleStyle(base.displaySmall),
    headlineLarge: scaleStyle(base.headlineLarge),
    headlineMedium: scaleStyle(base.headlineMedium),
    headlineSmall: scaleStyle(base.headlineSmall),
    titleLarge: scaleStyle(base.titleLarge),
    titleMedium: scaleStyle(base.titleMedium),
    titleSmall: scaleStyle(base.titleSmall),
    bodyLarge: scaleStyle(base.bodyLarge),
    bodyMedium: scaleStyle(base.bodyMedium),
    bodySmall: scaleStyle(base.bodySmall),
    labelLarge: scaleStyle(base.labelLarge),
    labelMedium: scaleStyle(base.labelMedium),
    labelSmall: scaleStyle(base.labelSmall),
  );
}

class _MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.system;
  int colorIndex = 0;
  double fontScale = 1.0;
  double uiScale = 1.0;

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
    final density = VisualDensity(
      horizontal: (uiScale - 1) * 2,
      vertical: (uiScale - 1) * 2,
    );

    final lightBaseTextTheme = ThemeData.light().textTheme;
    final darkBaseTextTheme = ThemeData.dark().textTheme;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Collection Catalog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
        visualDensity: density,
        textTheme: _scaleTextTheme(lightBaseTextTheme, fontScale),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        visualDensity: density,
        textTheme: _scaleTextTheme(darkBaseTextTheme, fontScale),
      ),
      themeMode: themeMode,
      home: MainNavigation(
        themeMode: themeMode,
        colorIndex: colorIndex,
        fontScale: fontScale,
        uiScale: uiScale,
        onThemeChanged: (value) => setState(() => themeMode = value),
        onColorChanged: (value) => setState(() => colorIndex = value),
        onFontScaleChanged: (value) => setState(() => fontScale = value),
        onUiScaleChanged: (value) => setState(() => uiScale = value),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final ThemeMode themeMode;
  final int colorIndex;
  final double fontScale;
  final double uiScale;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<int> onColorChanged;
  final ValueChanged<double> onFontScaleChanged;
  final ValueChanged<double> onUiScaleChanged;

  const MainNavigation({
    super.key,
    required this.themeMode,
    required this.colorIndex,
    required this.fontScale,
    required this.uiScale,
    required this.onThemeChanged,
    required this.onColorChanged,
    required this.onFontScaleChanged,
    required this.onUiScaleChanged,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  // Страницы создаются один раз и не пересоздаются при смене настроек.
  late final Widget _catalogPage = const CatalogPage();
  late final Widget _collectionsPage = const CollectionsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          _catalogPage,
          _collectionsPage,
          _SettingsPage(
            themeMode: widget.themeMode,
            colorIndex: widget.colorIndex,
            fontScale: widget.fontScale,
            uiScale: widget.uiScale,
            onThemeChanged: widget.onThemeChanged,
            onColorChanged: widget.onColorChanged,
            onFontScaleChanged: widget.onFontScaleChanged,
            onUiScaleChanged: widget.onUiScaleChanged,
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
            icon: Icon(Icons.collections_bookmark_outlined),
            selectedIcon: Icon(Icons.collections_bookmark),
            label: 'Мои коллекции',
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
  final double fontScale;
  final double uiScale;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<int> onColorChanged;
  final ValueChanged<double> onFontScaleChanged;
  final ValueChanged<double> onUiScaleChanged;

  const _SettingsPage({
    required this.themeMode,
    required this.colorIndex,
    required this.fontScale,
    required this.uiScale,
    required this.onThemeChanged,
    required this.onColorChanged,
    required this.onFontScaleChanged,
    required this.onUiScaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsGroup(
            title: 'Каталоги',
            children: [
              ListTile(
                leading: const Icon(Icons.admin_panel_settings_outlined),
                title: const Text('Администратор каталогов'),
                subtitle: const Text(
                  'Создание, удаление и изменение готовых каталогов',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CatalogAdminPage(),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: const Text('Загрузки'),
                subtitle: const Text('Очередь скачивания каталогов'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DownloadsPage(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SettingsGroup(
            title: 'Оформление',
            children: [
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('Тема оформления'),
                subtitle: Text(_themeName(themeMode)),
                onTap: () => _showThemes(context),
              ),
              ListTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: const Text('Цветовая гамма'),
                subtitle: Text(_MyAppState.colorNames[colorIndex]),
                onTap: () => _showColors(context),
              ),
              ListTile(
                leading: const Icon(Icons.text_fields_outlined),
                title: const Text('Размер шрифта'),
                subtitle: Text(_fontName(fontScale)),
                onTap: () => _showFontSizes(context),
              ),
              ListTile(
                leading: const Icon(Icons.view_agenda_outlined),
                title: const Text('Размер элементов интерфейса'),
                subtitle: Text(_uiSizeName(uiScale)),
                onTap: () => _showUiSizes(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SettingsGroup(
            title: 'Помощь',
            children: [
              ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: const Text('Обратная связь'),
                subtitle: const Text(
                  'Заявка на добавление или изменение данных каталога',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FeedbackPage()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Справка о приложении'),
                subtitle: const Text('Краткая информация и возможности'),
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'Collection Catalog',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.collections_bookmark),
                  children: const [
                    Text(
                      'Collection Catalog предназначен для просмотра готовых каталогов и ведения собственных коллекций. Каталоги можно просматривать онлайн и сохранять на устройство.',
                    ),
                  ],
                ),
              ),
            ],
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

  String _fontName(double value) {
    if (value < 0.95) return 'Маленький';
    if (value > 1.05) return 'Большой';
    return 'Средний';
  }

  String _uiSizeName(double value) {
    if (value < 0.95) return 'Маленький';
    if (value > 1.05) return 'Большой';
    return 'Средний';
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

    if (selected != null) onThemeChanged(selected);
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

    if (selected != null) onColorChanged(selected);
  }

  Future<void> _showFontSizes(BuildContext context) async {
    final selected = await showModalBottomSheet<double>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _optionTile(sheetContext, 'Маленький', 0.90, fontScale),
            _optionTile(sheetContext, 'Средний', 1.00, fontScale),
            _optionTile(sheetContext, 'Большой', 1.15, fontScale),
          ],
        ),
      ),
    );

    if (selected != null) onFontScaleChanged(selected);
  }

  Future<void> _showUiSizes(BuildContext context) async {
    final selected = await showModalBottomSheet<double>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _optionTile(sheetContext, 'Маленький', 0.85, uiScale),
            _optionTile(sheetContext, 'Средний', 1.00, uiScale),
            _optionTile(sheetContext, 'Большой', 1.15, uiScale),
          ],
        ),
      ),
    );

    if (selected != null) onUiScaleChanged(selected);
  }

  Widget _optionTile(
    BuildContext sheetContext,
    String title,
    double value,
    double current,
  ) {
    final selected = (value - current).abs() < 0.01;
    return ListTile(
      title: Text(title),
      trailing: selected ? const Icon(Icons.check) : null,
      onTap: () => Navigator.pop(sheetContext, value),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
