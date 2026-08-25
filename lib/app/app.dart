import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/localization/app_localizations.dart';
import '../core/settings/ui_layout_settings.dart';
import '../features/catalogs/data/catalog_registry.dart';
import '../features/catalogs/data/catalog_version_store.dart';
import '../features/catalogs/data/favorites_store.dart';
import '../features/catalogs/presentation/favorites_page.dart';
import '../features/collections/data/backup_export_service.dart';
import '../features/collections/data/collection_history_store.dart';
import '../features/collections/presentation/pages/backup_import_page.dart';
import '../features/collections/presentation/pages/catalog_page.dart';
import '../features/collections/presentation/pages/collections_page.dart';
import '../features/downloads/presentation/downloads_page.dart';
import '../features/feedback/presentation/feedback_page.dart';
import '../features/items/data/item_state_store.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _themeKey = 'settings.themeMode';
  static const _colorKey = 'settings.colorIndex';
  static const _fontScaleKey = 'settings.fontScale';
  static const _uiScaleKey = 'settings.uiScale';
  static const _localeKey = 'settings.locale';

  ThemeMode themeMode = ThemeMode.system;
  Locale? locale;
  int colorIndex = 0;
  double fontScale = 1.0;
  double uiScale = 1.0;

  static const colors = [Colors.indigo, Colors.teal, Colors.deepPurple, Colors.orange, Colors.green];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  double _validScale(double? value) => value == null || !value.isFinite ? 1.0 : value.clamp(0.70, 1.40).toDouble();
  int _validColorIndex(int? value) => value == null || value < 0 || value >= colors.length ? 0 : value;
  ThemeMode _themeModeFromString(String? value) => switch (value) { 'light' => ThemeMode.light, 'dark' => ThemeMode.dark, _ => ThemeMode.system };
  String _themeModeToString(ThemeMode value) => switch (value) { ThemeMode.light => 'light', ThemeMode.dark => 'dark', ThemeMode.system => 'system' };

  Future<void> _loadSettings() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!mounted) return;
      final language = preferences.getString(_localeKey);
      setState(() {
        themeMode = _themeModeFromString(preferences.getString(_themeKey));
        colorIndex = _validColorIndex(preferences.getInt(_colorKey));
        fontScale = _validScale(preferences.getDouble(_fontScaleKey));
        uiScale = _validScale(preferences.getDouble(_uiScaleKey));
        locale = language == null || language.isEmpty ? null : Locale(language);
      });
      await UiLayoutSettings.ensureLoaded();
    } catch (_) {}
  }

  Future<void> _saveSettings() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await Future.wait([
        preferences.setString(_themeKey, _themeModeToString(themeMode)),
        preferences.setInt(_colorKey, colorIndex),
        preferences.setDouble(_fontScaleKey, fontScale),
        preferences.setDouble(_uiScaleKey, uiScale),
        if (locale == null) preferences.remove(_localeKey) else preferences.setString(_localeKey, locale!.languageCode),
      ]);
    } catch (_) {}
  }

  void _changeTheme(ThemeMode value) { setState(() => themeMode = value); _saveSettings(); }
  void _changeColor(int value) { setState(() => colorIndex = _validColorIndex(value)); _saveSettings(); }
  void _changeFontScale(double value) { setState(() => fontScale = _validScale(value)); _saveSettings(); }
  void _changeUiScale(double value) { setState(() => uiScale = _validScale(value)); _saveSettings(); }
  void _changeLocale(Locale? value) { setState(() => locale = value); _saveSettings(); }

  @override
  Widget build(BuildContext context) {
    final seed = colors[colorIndex];
    final densityValue = (uiScale - 1.0) * 4.0;
    final density = VisualDensity(horizontal: densityValue, vertical: densityValue);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      onGenerateTitle: (context) => AppLocalizations.of(context).catalog,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      theme: _buildTheme(seed, Brightness.light, density),
      darkTheme: _buildTheme(seed, Brightness.dark, density),
      themeMode: themeMode,
      builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(fontScale)), child: child ?? const SizedBox.shrink()),
      home: MainNavigation(themeMode: themeMode, colorIndex: colorIndex, fontScale: fontScale, uiScale: uiScale, locale: locale, onThemeChanged: _changeTheme, onColorChanged: _changeColor, onFontScaleChanged: _changeFontScale, onUiScaleChanged: _changeUiScale, onLocaleChanged: _changeLocale),
    );
  }

  ThemeData _buildTheme(Color seed, Brightness brightness, VisualDensity density) => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
        useMaterial3: true,
        visualDensity: density,
        listTileTheme: ListTileThemeData(contentPadding: EdgeInsets.symmetric(horizontal: 16 * uiScale, vertical: 2 * uiScale), minVerticalPadding: 8 * uiScale),
        cardTheme: CardThemeData(margin: EdgeInsets.all(4 * uiScale)),
        inputDecorationTheme: InputDecorationTheme(contentPadding: EdgeInsets.symmetric(horizontal: 16 * uiScale, vertical: 14 * uiScale)),
      );
}

class MainNavigation extends StatefulWidget {
  final ThemeMode themeMode;
  final int colorIndex;
  final double fontScale;
  final double uiScale;
  final Locale? locale;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<int> onColorChanged;
  final ValueChanged<double> onFontScaleChanged;
  final ValueChanged<double> onUiScaleChanged;
  final ValueChanged<Locale?> onLocaleChanged;
  const MainNavigation({super.key, required this.themeMode, required this.colorIndex, required this.fontScale, required this.uiScale, required this.locale, required this.onThemeChanged, required this.onColorChanged, required this.onFontScaleChanged, required this.onUiScaleChanged, required this.onLocaleChanged});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destinations = [
      _NavigationDestinationData(label: l10n.catalog, icon: Icons.menu_book_outlined, selectedIcon: Icons.menu_book),
      _NavigationDestinationData(label: l10n.favorites, icon: Icons.star_border_rounded, selectedIcon: Icons.star_rounded),
      _NavigationDestinationData(label: l10n.myCollections, icon: Icons.collections_bookmark_outlined, selectedIcon: Icons.collections_bookmark),
      _NavigationDestinationData(label: l10n.settings, icon: Icons.settings_outlined, selectedIcon: Icons.settings),
    ];
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: [
        const CatalogPage(),
        const FavoritesPage(),
        const CollectionsPage(),
        _SettingsPage(themeMode: widget.themeMode, colorIndex: widget.colorIndex, fontScale: widget.fontScale, uiScale: widget.uiScale, locale: widget.locale, onThemeChanged: widget.onThemeChanged, onColorChanged: widget.onColorChanged, onFontScaleChanged: widget.onFontScaleChanged, onUiScaleChanged: widget.onUiScaleChanged, onLocaleChanged: widget.onLocaleChanged),
      ]),
      bottomNavigationBar: _BottomNavigationBar(destinations: destinations, selectedIndex: currentIndex, onSelected: (index) => setState(() => currentIndex = index)),
    );
  }
}

class _NavigationDestinationData {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  const _NavigationDestinationData({required this.label, required this.icon, required this.selectedIcon});
}

class _BottomNavigationBar extends StatelessWidget {
  final List<_NavigationDestinationData> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  const _BottomNavigationBar({required this.destinations, required this.selectedIndex, required this.onSelected});
  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 3,
        child: SafeArea(top: false, child: SizedBox(height: 76, child: Row(children: [for (var index = 0; index < destinations.length; index++) Expanded(child: _BottomNavigationItem(data: destinations[index], selected: index == selectedIndex, onTap: () => onSelected(index)))]))),
      );
}

class _BottomNavigationItem extends StatelessWidget {
  final _NavigationDestinationData data;
  final bool selected;
  final VoidCallback onTap;
  const _BottomNavigationItem({required this.data, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(button: true, selected: selected, label: data.label, child: InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      AnimatedContainer(duration: const Duration(milliseconds: 180), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4), decoration: BoxDecoration(color: selected ? colors.secondaryContainer : Colors.transparent, borderRadius: BorderRadius.circular(20)), child: Icon(selected ? data.selectedIcon : data.icon, color: selected ? colors.onSecondaryContainer : colors.onSurfaceVariant, size: 24)),
      const SizedBox(height: 3),
      SizedBox(width: double.infinity, child: Text(data.label, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? colors.onSurface : colors.onSurfaceVariant))),
    ]))));
  }
}

class _SettingsPage extends StatelessWidget {
  final ThemeMode themeMode;
  final int colorIndex;
  final double fontScale;
  final double uiScale;
  final Locale? locale;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<int> onColorChanged;
  final ValueChanged<double> onFontScaleChanged;
  final ValueChanged<double> onUiScaleChanged;
  final ValueChanged<Locale?> onLocaleChanged;
  const _SettingsPage({required this.themeMode, required this.colorIndex, required this.fontScale, required this.uiScale, required this.locale, required this.onThemeChanged, required this.onColorChanged, required this.onFontScaleChanged, required this.onUiScaleChanged, required this.onLocaleChanged});

  String _text(BuildContext context, String ru, String en) => Localizations.localeOf(context).languageCode == 'ru' ? ru : en;
  String _scaleName(BuildContext context, double value) {
    if (value < 0.82) return _text(context, 'Очень маленький', 'Very small');
    if (value < 0.95) return _text(context, 'Маленький', 'Small');
    if (value < 1.06) return _text(context, 'Средний', 'Medium');
    if (value < 1.19) return _text(context, 'Большой', 'Large');
    return _text(context, 'Очень большой', 'Very large');
  }
  String _themeName(BuildContext context, ThemeMode mode) => switch (mode) { ThemeMode.system => _text(context, 'Системная', 'System'), ThemeMode.light => _text(context, 'Светлая', 'Light'), ThemeMode.dark => _text(context, 'Тёмная', 'Dark') };
  String _colorName(BuildContext context, int index) => [_text(context, 'Индиго', 'Indigo'), _text(context, 'Бирюзовый', 'Teal'), _text(context, 'Фиолетовый', 'Purple'), _text(context, 'Оранжевый', 'Orange'), _text(context, 'Зелёный', 'Green')][index];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _SettingsGroup(title: _text(context, 'Интерфейс', 'Interface'), children: [
          ListTile(leading: const Icon(Icons.view_column_outlined), title: Text(_text(context, 'Количество колонок', 'Number of columns')), subtitle: Text(UiLayoutSettings.columns == 0 ? _text(context, 'Автоматически', 'Automatic') : '${UiLayoutSettings.columns}'), trailing: const Icon(Icons.chevron_right), onTap: () => _showColumns(context)),
          ListTile(leading: const Icon(Icons.palette_outlined), title: Text(_text(context, 'Тема', 'Theme')), subtitle: Text(_themeName(context, themeMode)), onTap: () => _showThemes(context)),
          ListTile(leading: const Icon(Icons.color_lens_outlined), title: Text(_text(context, 'Цветовая схема', 'Color scheme')), subtitle: Text(_colorName(context, colorIndex)), onTap: () => _showColors(context)),
          ListTile(leading: const Icon(Icons.text_fields_outlined), title: Text(_text(context, 'Размер шрифта', 'Font size')), subtitle: Text(_scaleName(context, fontScale)), onTap: () => _showScale(context, true)),
          ListTile(leading: const Icon(Icons.view_agenda_outlined), title: Text(_text(context, 'Размер интерфейса', 'Interface size')), subtitle: Text(_scaleName(context, uiScale)), onTap: () => _showScale(context, false)),
          ListTile(leading: const Icon(Icons.language_outlined), title: Text(l10n.language), subtitle: Text(locale == null ? l10n.languageSystem : AppLocalizations(locale!).languageName), onTap: () => _showLanguages(context)),
        ]),
        const SizedBox(height: 12),
        _SettingsGroup(title: _text(context, 'Каталоги', 'Catalogs'), children: [
          ListTile(leading: const Icon(Icons.download_outlined), title: Text(_text(context, 'Загрузки', 'Downloads')), subtitle: Text(_text(context, 'Очередь загрузки каталогов', 'Catalog download queue')), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DownloadsPage()))),
          ListTile(leading: const Icon(Icons.update_outlined), title: Text(_text(context, 'Версии каталогов', 'Catalog versions')), subtitle: Text(_text(context, 'Установленные и доступные версии', 'Installed and available versions')), trailing: const Icon(Icons.chevron_right), onTap: () => _showCatalogVersions(context)),
        ]),
        const SizedBox(height: 12),
        _SettingsGroup(title: _text(context, 'Резервная копия', 'Backup'), children: [
          ListTile(leading: const Icon(Icons.backup_outlined), title: Text(_text(context, 'Создать резервную копию', 'Create backup')), subtitle: Text(_text(context, 'Состояния, избранное и история', 'States, favorites and history')), trailing: const Icon(Icons.chevron_right), onTap: () => _exportBackup(context)),
          ListTile(leading: const Icon(Icons.restore_outlined), title: Text(_text(context, 'Восстановить', 'Restore')), subtitle: Text(_text(context, 'Импорт JSON без изменения структуры каталога', 'Import JSON without changing catalog structure')), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BackupImportPage()))),
        ]),
        const SizedBox(height: 12),
        _SettingsGroup(title: _text(context, 'Дополнительно', 'More'), children: [
          ListTile(leading: const Icon(Icons.feedback_outlined), title: Text(_text(context, 'Предложить изменение названия', 'Suggest a name change')), subtitle: Text(_text(context, 'Предложения по названиям каталогов и разделов', 'Suggest catalog and section names')), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FeedbackPage()))),
          ListTile(leading: const Icon(Icons.help_outline), title: Text(_text(context, 'О приложении', 'About')), subtitle: const Text('Collection Catalog'), onTap: () => showAboutDialog(context: context, applicationName: 'Collection Catalog')),
        ]),
      ]),
    );
  }

  Future<void> _showColumns(BuildContext context) async {
    final selected = await showModalBottomSheet<int>(context: context, builder: (sheetContext) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [for (final value in [0, 1, 2, 3, 4]) ListTile(leading: Icon(UiLayoutSettings.columns == value ? Icons.radio_button_checked : Icons.radio_button_unchecked), title: Text(value == 0 ? _text(context, 'Автоматически', 'Automatic') : '$value'), subtitle: value == 0 ? Text(_text(context, 'Адаптация под ширину экрана', 'Adapt to screen width')) : null, onTap: () => Navigator.pop(sheetContext, value))])));
    if (selected != null) await UiLayoutSettings.save(columns: selected);
  }

  Future<void> _showLanguages(BuildContext context) async {
    final result = await showModalBottomSheet<String>(context: context, builder: (sheetContext) => SafeArea(child: ListView(shrinkWrap: true, children: [ListTile(leading: Icon(locale == null ? Icons.radio_button_checked : Icons.radio_button_unchecked), title: Text(AppLocalizations.of(context).languageSystem), onTap: () => Navigator.pop(sheetContext, '__system__')), ...AppLocalizations.supportedLocales.map((item) => ListTile(leading: Icon(locale?.languageCode == item.languageCode ? Icons.radio_button_checked : Icons.radio_button_unchecked), title: Text(AppLocalizations(item).languageName), onTap: () => Navigator.pop(sheetContext, item.languageCode))) ])));
    if (!context.mounted || result == null) return;
    onLocaleChanged(result == '__system__' ? null : Locale(result));
  }

  Future<void> _showThemes(BuildContext context) async {
    final selected = await showModalBottomSheet<ThemeMode>(context: context, builder: (sheetContext) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: ThemeMode.values.map((mode) => ListTile(title: Text(_themeName(context, mode)), selected: mode == themeMode, onTap: () => Navigator.pop(sheetContext, mode))).toList())));
    if (selected != null) onThemeChanged(selected);
  }

  Future<void> _showColors(BuildContext context) async {
    final selected = await showModalBottomSheet<int>(context: context, builder: (sheetContext) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: List.generate(_MyAppState.colors.length, (index) => ListTile(leading: CircleAvatar(backgroundColor: _MyAppState.colors[index]), title: Text(_colorName(context, index)), selected: index == colorIndex, onTap: () => Navigator.pop(sheetContext, index))))));
    if (selected != null) onColorChanged(selected);
  }

  Future<void> _showScale(BuildContext context, bool font) async {
    final current = font ? fontScale : uiScale;
    final values = font ? const [0.75, 0.875, 1.0, 1.125, 1.25] : const [0.70, 0.85, 1.0, 1.15, 1.30];
    final selected = await showModalBottomSheet<double>(context: context, builder: (sheetContext) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: values.map((value) => ListTile(leading: Icon((value - current).abs() < 0.01 ? Icons.radio_button_checked : Icons.radio_button_unchecked), title: Text(_scaleName(context, value)), subtitle: Text('${(value * 100).round()}%'), onTap: () => Navigator.pop(sheetContext, value))).toList())));
    if (selected == null) return;
    if (font) onFontScaleChanged(selected); else onUiScaleChanged(selected);
  }

  Future<void> _showCatalogVersions(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        maxChildSize: 0.92,
        builder: (_, controller) => SafeArea(child: ListView.builder(controller: controller, itemCount: CatalogRegistry.all.length + 1, itemBuilder: (_, index) {
          if (index == 0) return ListTile(title: Text(_text(context, 'Версии каталогов', 'Catalog versions')), subtitle: Text(_text(context, 'Версия структуры и установленная версия', 'Structure version and installed version')));
          final catalog = CatalogRegistry.all[index - 1];
          return FutureBuilder<int?>(future: CatalogVersionStore.installedVersion(catalog.id), builder: (_, snapshot) => ListTile(leading: const Icon(Icons.inventory_2_outlined), title: Text(catalog.name), subtitle: Text(snapshot.data == null ? _text(context, 'Не загружен', 'Not installed') : '${_text(context, 'Установлена', 'Installed')}: ${snapshot.data} · ${_text(context, 'Доступна', 'Available')}: ${catalog.version}')));
        })),
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context) async {
    try {
      final states = await ItemStateStore.loadAll();
      final history = await CollectionHistoryStore.load();
      final snapshot = <String, dynamic>{
        'format': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'itemStates': states.map((key, value) => MapEntry(key, value.toJson())),
        'favorites': (await FavoritesStore.loadKeys()).toList(),
        'history': history.map((entry) => entry.toJson()).toList(),
      };
      await BackupExportService.exportJson(snapshot);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_text(context, 'Резервная копия создана', 'Backup created'))));
    } catch (error) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_text(context, 'Ошибка резервной копии', 'Backup error')}: $error')));
    }
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsGroup({required this.title, required this.children});
  @override
  Widget build(BuildContext context) => Card(clipBehavior: Clip.antiAlias, child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))), ...children])));
}
