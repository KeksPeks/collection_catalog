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
import '../features/overview/presentation/overview_page.dart';
import '../features/settings/presentation/version_history_page.dart';

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
  static const colors = [Colors.indigo, Colors.teal, Colors.deepPurple, Colors.orange, Colors.green];

  ThemeMode themeMode = ThemeMode.system;
  Locale? locale;
  int colorIndex = 0;
  double fontScale = 1.0;
  double uiScale = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  double _validScale(double? value) => value == null || !value.isFinite ? 1.0 : value.clamp(0.70, 1.40).toDouble();
  int _validColor(int? value) => value == null || value < 0 || value >= colors.length ? 0 : value;
  ThemeMode _theme(String? value) => switch (value) { 'light' => ThemeMode.light, 'dark' => ThemeMode.dark, _ => ThemeMode.system };
  String _themeValue(ThemeMode value) => switch (value) { ThemeMode.light => 'light', ThemeMode.dark => 'dark', ThemeMode.system => 'system' };

  Future<void> _loadSettings() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        themeMode = _theme(p.getString(_themeKey));
        colorIndex = _validColor(p.getInt(_colorKey));
        fontScale = _validScale(p.getDouble(_fontScaleKey));
        uiScale = _validScale(p.getDouble(_uiScaleKey));
        final language = p.getString(_localeKey);
        locale = language == null || language.isEmpty ? null : Locale(language);
      });
      await UiLayoutSettings.ensureLoaded();
    } catch (_) {}
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await Future.wait([
      p.setString(_themeKey, _themeValue(themeMode)),
      p.setInt(_colorKey, colorIndex),
      p.setDouble(_fontScaleKey, fontScale),
      p.setDouble(_uiScaleKey, uiScale),
      if (locale == null) p.remove(_localeKey) else p.setString(_localeKey, locale!.languageCode),
    ]);
  }

  void _setTheme(ThemeMode value) { setState(() => themeMode = value); _save(); }
  void _setColor(int value) { setState(() => colorIndex = _validColor(value)); _save(); }
  void _setFont(double value) { setState(() => fontScale = _validScale(value)); _save(); }
  void _setUi(double value) { setState(() => uiScale = _validScale(value)); _save(); }
  void _setLocale(Locale? value) { setState(() => locale = value); _save(); }

  @override
  Widget build(BuildContext context) {
    final densityValue = (uiScale - 1.0) * 4.0;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      onGenerateTitle: (context) => AppLocalizations.of(context).catalog,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: colors[colorIndex], brightness: Brightness.light), useMaterial3: true, visualDensity: VisualDensity(horizontal: densityValue, vertical: densityValue)),
      darkTheme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: colors[colorIndex], brightness: Brightness.dark), useMaterial3: true, visualDensity: VisualDensity(horizontal: densityValue, vertical: densityValue)),
      themeMode: themeMode,
      builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(fontScale)), child: child ?? const SizedBox.shrink()),
      home: MainNavigation(themeMode: themeMode, colorIndex: colorIndex, fontScale: fontScale, uiScale: uiScale, locale: locale, onThemeChanged: _setTheme, onColorChanged: _setColor, onFontScaleChanged: _setFont, onUiScaleChanged: _setUi, onLocaleChanged: _setLocale),
    );
  }
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
      const _Nav('Обзор', 'Overview', Icons.insights_outlined, Icons.insights_rounded),
      _Nav(l10n.catalog, l10n.catalog, Icons.menu_book_outlined, Icons.menu_book),
      _Nav(l10n.favorites, l10n.favorites, Icons.star_border_rounded, Icons.star_rounded),
      _Nav(l10n.myCollections, l10n.myCollections, Icons.collections_bookmark_outlined, Icons.collections_bookmark),
      _Nav(l10n.settings, l10n.settings, Icons.settings_outlined, Icons.settings),
    ];
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: [
        const OverviewPage(),
        const CatalogPage(),
        const FavoritesPage(),
        const CollectionsPage(),
        _SettingsPage(themeMode: widget.themeMode, colorIndex: widget.colorIndex, fontScale: widget.fontScale, uiScale: widget.uiScale, locale: widget.locale, onThemeChanged: widget.onThemeChanged, onColorChanged: widget.onColorChanged, onFontScaleChanged: widget.onFontScaleChanged, onUiScaleChanged: widget.onUiScaleChanged, onLocaleChanged: widget.onLocaleChanged),
      ]),
      bottomNavigationBar: _BottomNavigationBar(destinations: destinations, selectedIndex: currentIndex, onSelected: (value) => setState(() => currentIndex = value)),
    );
  }
}

class _Nav {
  final String ru;
  final String en;
  final IconData icon;
  final IconData selectedIcon;
  const _Nav(this.ru, this.en, this.icon, this.selectedIcon);
  String title(BuildContext context) => Localizations.localeOf(context).languageCode == 'ru' ? ru : en;
}

class _BottomNavigationBar extends StatelessWidget {
  final List<_Nav> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  const _BottomNavigationBar({required this.destinations, required this.selectedIndex, required this.onSelected});
  @override
  Widget build(BuildContext context) => Material(elevation: 3, color: Theme.of(context).colorScheme.surface, child: SafeArea(top: false, child: SizedBox(height: 76, child: Row(children: [for (var i = 0; i < destinations.length; i++) Expanded(child: InkWell(onTap: () => onSelected(i), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i == selectedIndex ? destinations[i].selectedIcon : destinations[i].icon), const SizedBox(height: 3), Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: Text(destinations[i].title(context), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: i == selectedIndex ? FontWeight.w700 : FontWeight.w500)))])))]))));
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<int>(valueListenable: UiLayoutSettings.revision, builder: (context, _, __) => Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _Group(title: _text(context, 'Интерфейс', 'Interface'), children: [
          ListTile(leading: const Icon(Icons.view_column_outlined), title: Text(_text(context, 'Количество колонок', 'Number of columns')), subtitle: Text(UiLayoutSettings.columns == 0 ? _text(context, 'Автоматически', 'Automatic') : '${UiLayoutSettings.columns}'), trailing: const Icon(Icons.chevron_right), onTap: () => _showColumns(context)),
          ListTile(leading: const Icon(Icons.palette_outlined), title: Text(_text(context, 'Тема', 'Theme')), subtitle: Text(_themeName(context, themeMode)), onTap: () => _showTheme(context)),
          ListTile(leading: const Icon(Icons.color_lens_outlined), title: Text(_text(context, 'Цветовая схема', 'Color scheme')), onTap: () => _showColor(context)),
          ListTile(leading: const Icon(Icons.text_fields_outlined), title: Text(_text(context, 'Размер шрифта', 'Font size')), subtitle: Text('${(fontScale * 100).round()}%'), onTap: () => _showScale(context, true)),
          ListTile(leading: const Icon(Icons.view_agenda_outlined), title: Text(_text(context, 'Размер интерфейса', 'Interface size')), subtitle: Text('${(uiScale * 100).round()}%'), onTap: () => _showScale(context, false)),
          ListTile(leading: const Icon(Icons.language_outlined), title: Text(l10n.language), subtitle: Text(locale == null ? l10n.languageSystem : AppLocalizations(locale!).languageName), onTap: () => _showLanguage(context)),
        ]),
        const SizedBox(height: 12),
        _Group(title: _text(context, 'Каталоги', 'Catalogs'), children: [
          ListTile(leading: const Icon(Icons.download_outlined), title: Text(_text(context, 'Загрузки', 'Downloads')), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DownloadsPage()))),
          ListTile(leading: const Icon(Icons.update_outlined), title: Text(_text(context, 'Версии каталогов', 'Catalog versions')), onTap: () => _showCatalogVersions(context)),
        ]),
        const SizedBox(height: 12),
        _Group(title: _text(context, 'Резервная копия', 'Backup'), children: [
          ListTile(leading: const Icon(Icons.backup_outlined), title: Text(_text(context, 'Создать резервную копию', 'Create backup')), onTap: () => _exportBackup(context)),
          ListTile(leading: const Icon(Icons.restore_outlined), title: Text(_text(context, 'Восстановить', 'Restore')), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BackupImportPage()))),
        ]),
        const SizedBox(height: 12),
        _Group(title: _text(context, 'Дополнительно', 'More'), children: [
          ListTile(leading: const Icon(Icons.feedback_outlined), title: Text(_text(context, 'Предложить изменение названия', 'Suggest a name change')), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FeedbackPage()))),
          ListTile(leading: const Icon(Icons.history_rounded), title: Text(_text(context, 'История версий', 'Version history')), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VersionHistoryPage()))),
          ListTile(leading: const Icon(Icons.info_outline_rounded), title: Text(_text(context, 'О приложении', 'About')), onTap: () => showAboutDialog(context: context, applicationName: 'Collection Catalog')),
        ]),
      ]),
    ));
  }

  String _themeName(BuildContext context, ThemeMode mode) => switch (mode) { ThemeMode.system => _text(context, 'Системная', 'System'), ThemeMode.light => _text(context, 'Светлая', 'Light'), ThemeMode.dark => _text(context, 'Тёмная', 'Dark') };

  Future<void> _showColumns(BuildContext context) async {
    final value = await showModalBottomSheet<int>(context: context, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [for (final column in [0, 1, 2, 3, 4]) ListTile(leading: Icon(UiLayoutSettings.columns == column ? Icons.radio_button_checked : Icons.radio_button_unchecked), title: Text(column == 0 ? _text(context, 'Автоматически', 'Automatic') : '$column'), onTap: () => Navigator.pop(context, column))])));
    if (value != null) await UiLayoutSettings.save(columns: value);
  }

  Future<void> _showTheme(BuildContext context) async {
    final value = await showModalBottomSheet<ThemeMode>(context: context, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: ThemeMode.values.map((mode) => ListTile(title: Text(_themeName(context, mode)), selected: mode == themeMode, onTap: () => Navigator.pop(context, mode))).toList())));
    if (value != null) onThemeChanged(value);
  }

  Future<void> _showColor(BuildContext context) async {
    final value = await showModalBottomSheet<int>(context: context, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: List.generate(_MyAppState.colors.length, (i) => ListTile(leading: CircleAvatar(backgroundColor: _MyAppState.colors[i]), title: Text('${(i + 1)}'), selected: i == colorIndex, onTap: () => Navigator.pop(context, i))))));
    if (value != null) onColorChanged(value);
  }

  Future<void> _showScale(BuildContext context, bool font) async {
    final current = font ? fontScale : uiScale;
    final values = font ? const [0.75, 0.875, 1.0, 1.125, 1.25] : const [0.70, 0.85, 1.0, 1.15, 1.30];
    final value = await showModalBottomSheet<double>(context: context, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: values.map((v) => ListTile(leading: Icon((v - current).abs() < 0.01 ? Icons.radio_button_checked : Icons.radio_button_unchecked), title: Text('${(v * 100).round()}%'), onTap: () => Navigator.pop(context, v))).toList())));
    if (value == null) return;
    if (font) onFontScaleChanged(value); else onUiScaleChanged(value);
  }

  Future<void> _showLanguage(BuildContext context) async {
    final result = await showModalBottomSheet<String>(context: context, builder: (_) => SafeArea(child: ListView(shrinkWrap: true, children: [ListTile(title: Text(AppLocalizations.of(context).languageSystem), onTap: () => Navigator.pop(context, '__system__')), ...AppLocalizations.supportedLocales.map((item) => ListTile(title: Text(AppLocalizations(item).languageName), onTap: () => Navigator.pop(context, item.languageCode)))])));
    if (!context.mounted || result == null) return;
    onLocaleChanged(result == '__system__' ? null : Locale(result));
  }

  Future<void> _showCatalogVersions(BuildContext context) async {
    await showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => DraggableScrollableSheet(expand: false, builder: (_, controller) => SafeArea(child: ListView.builder(controller: controller, itemCount: CatalogRegistry.all.length + 1, itemBuilder: (_, index) {
      if (index == 0) return ListTile(title: Text(_text(context, 'Версии каталогов', 'Catalog versions')));
      final catalog = CatalogRegistry.all[index - 1];
      return FutureBuilder<int?>(future: CatalogVersionStore.installedVersion(catalog.id), builder: (_, snapshot) => ListTile(leading: const Icon(Icons.inventory_2_outlined), title: Text(catalog.name), subtitle: Text(snapshot.data == null ? _text(context, 'Не загружен', 'Not installed') : '${_text(context, 'Установлена', 'Installed')}: ${snapshot.data} · ${_text(context, 'Доступна', 'Available')}: ${catalog.version}')));
    }))));
  }

  Future<void> _exportBackup(BuildContext context) async {
    try {
      final states = await ItemStateStore.loadAll();
      final history = await CollectionHistoryStore.load();
      final snapshot = <String, dynamic>{'format': 1, 'createdAt': DateTime.now().toIso8601String(), 'itemStates': states.map((key, value) => MapEntry(key, value.toJson())), 'favorites': (await FavoritesStore.loadKeys()).toList(), 'history': history.map((entry) => entry.toJson()).toList()};
      await BackupExportService.exportJson(snapshot);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_text(context, 'Резервная копия создана', 'Backup created'))));
    } catch (error) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$error')));
    }
  }
}

class _Group extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Group({required this.title, required this.children});
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))), ...children])));
}
