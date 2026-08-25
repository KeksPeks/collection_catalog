import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/localization/app_localizations.dart';
import '../core/settings/ui_layout_settings.dart';
import '../core/utils/responsive.dart';
import '../features/catalogs/data/catalog_registry.dart';
import '../features/catalogs/data/catalog_version_store.dart';
import '../features/catalogs/presentation/favorites_page.dart';
import '../features/collections/data/backup_export_service.dart';
import '../features/collections/data/collection_history_store.dart';
import '../features/collections/domain/entities/collection.dart';
import '../features/collections/presentation/pages/backup_import_page.dart';
import '../features/collections/presentation/pages/catalog_page.dart';
import '../features/collections/presentation/pages/collections_page.dart';
import '../features/collections/presentation/providers/collection_provider.dart';
import '../features/downloads/presentation/downloads_page.dart';
import '../features/feedback/presentation/feedback_page.dart';
import '../features/items/data/item_state_store.dart';
import '../features/items/presentation/providers/item_service_provider.dart';
import '../features/overview/presentation/overview_page.dart';
import '../features/templates/presentation/pages/catalog_admin_page.dart';

class CollectionCatalogApp extends StatefulWidget {
  const CollectionCatalogApp({super.key});

  @override
  State<CollectionCatalogApp> createState() => _CollectionCatalogAppState();
}

class _CollectionCatalogAppState extends State<CollectionCatalogApp> {
  static const _themeKey = 'settings.themeMode';
  static const _colorKey = 'settings.colorIndex';
  static const _fontKey = 'settings.fontScale';
  static const _localeKey = 'settings.locale';
  static const _colors = <Color>[Colors.indigo, Colors.teal, Colors.deepPurple, Colors.orange, Colors.green];

  ThemeMode _theme = ThemeMode.system;
  Locale? _locale;
  int _colorIndex = 0;
  double _fontScale = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  double _scale(double? value) => value == null || !value.isFinite ? 1.0 : value.clamp(0.70, 1.40).toDouble();

  Future<void> _loadSettings() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!mounted) return;
      final color = preferences.getInt(_colorKey) ?? 0;
      final language = preferences.getString(_localeKey);
      setState(() {
        final theme = preferences.getString(_themeKey);
        _theme = theme == 'light' ? ThemeMode.light : theme == 'dark' ? ThemeMode.dark : ThemeMode.system;
        _colorIndex = color >= 0 && color < _colors.length ? color : 0;
        _fontScale = _scale(preferences.getDouble(_fontKey));
        _locale = language == null || language.isEmpty ? null : Locale(language);
      });
    } catch (_) {}
  }

  Future<void> _saveSettings() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await Future.wait([
        preferences.setString(_themeKey, _theme.name),
        preferences.setInt(_colorKey, _colorIndex),
        preferences.setDouble(_fontKey, _fontScale),
        if (_locale == null) preferences.remove(_localeKey) else preferences.setString(_localeKey, _locale!.languageCode),
      ]);
    } catch (_) {}
  }

  ThemeData _themeData(Brightness brightness) => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _colors[_colorIndex], brightness: brightness),
        useMaterial3: true,
        visualDensity: VisualDensity.standard,
        listTileTheme: const ListTileThemeData(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2), minVerticalPadding: 8),
        cardTheme: const CardThemeData(margin: EdgeInsets.all(4)),
        inputDecorationTheme: const InputDecorationTheme(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
      );

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: _locale,
        onGenerateTitle: (context) => AppLocalizations.of(context).catalog,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
        theme: _themeData(Brightness.light),
        darkTheme: _themeData(Brightness.dark),
        themeMode: _theme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(_fontScale)),
          child: child ?? const SizedBox.shrink(),
        ),
        home: _CollectionShell(
          theme: _theme,
          colorIndex: _colorIndex,
          fontScale: _fontScale,
          locale: _locale,
          onThemeChanged: (value) {
            setState(() => _theme = value);
            _saveSettings();
          },
          onColorChanged: (value) {
            setState(() => _colorIndex = value);
            _saveSettings();
          },
          onFontChanged: (value) {
            setState(() => _fontScale = _scale(value));
            _saveSettings();
          },
          onLocaleChanged: (value) {
            setState(() => _locale = value);
            _saveSettings();
          },
        ),
      );
}

class _CollectionShell extends StatefulWidget {
  final ThemeMode theme;
  final int colorIndex;
  final double fontScale;
  final Locale? locale;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<int> onColorChanged;
  final ValueChanged<double> onFontChanged;
  final ValueChanged<Locale?> onLocaleChanged;

  const _CollectionShell({required this.theme, required this.colorIndex, required this.fontScale, required this.locale, required this.onThemeChanged, required this.onColorChanged, required this.onFontChanged, required this.onLocaleChanged});

  @override
  State<_CollectionShell> createState() => _CollectionShellState();
}

class _CollectionShellState extends State<_CollectionShell> {
  int _index = 0;
  VoidCallback? _layoutListener;

  @override
  void initState() {
    super.initState();
    _layoutListener = () {
      if (mounted) setState(() {});
    };
    UiLayoutSettings.revision.addListener(_layoutListener!);
    UiLayoutSettings.ensureLoaded();
  }

  @override
  void dispose() {
    final listener = _layoutListener;
    if (listener != null) UiLayoutSettings.revision.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final info = ResponsiveInfo.of(context);
    final navigation = UiLayoutSettings.navigation;
    final useRail = navigation == 'side' || (navigation == 'auto' && info.useRail);
    final pages = <Widget>[
      const CatalogPage(),
      const FavoritesPage(),
      const CollectionsPage(),
      const OverviewPage(),
      _SettingsPage(theme: widget.theme, colorIndex: widget.colorIndex, fontScale: widget.fontScale, locale: widget.locale, onThemeChanged: widget.onThemeChanged, onColorChanged: widget.onColorChanged, onFontChanged: widget.onFontChanged, onLocaleChanged: widget.onLocaleChanged),
    ];
    final destinations = <_Destination>[
      _Destination(Icons.menu_book_outlined, Icons.menu_book, l10n.catalog),
      _Destination(Icons.star_border_rounded, Icons.star_rounded, l10n.favorites),
      _Destination(Icons.collections_bookmark_outlined, Icons.collections_bookmark, l10n.myCollections),
      _Destination(Icons.insights_outlined, Icons.insights_rounded, l10n.overview),
      _Destination(Icons.settings_outlined, Icons.settings, l10n.settings),
    ];

    if (useRail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (value) => setState(() => _index = value),
              labelType: NavigationRailLabelType.all,
              groupAlignment: -0.85,
              destinations: [
                for (final d in destinations) NavigationRailDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selectedIcon), label: Text(d.label)),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: IndexedStack(index: _index, children: pages)),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [for (final d in destinations) NavigationDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selectedIcon), label: d.label)],
      ),
    );
  }
}

class _Destination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _Destination(this.icon, this.selectedIcon, this.label);
}

class _SettingsPage extends StatelessWidget {
  final ThemeMode theme;
  final int colorIndex;
  final double fontScale;
  final Locale? locale;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<int> onColorChanged;
  final ValueChanged<double> onFontChanged;
  final ValueChanged<Locale?> onLocaleChanged;

  const _SettingsPage({required this.theme, required this.colorIndex, required this.fontScale, required this.locale, required this.onThemeChanged, required this.onColorChanged, required this.onFontChanged, required this.onLocaleChanged});

  String _text(BuildContext context, String ru, String en) => Localizations.localeOf(context).languageCode == 'ru' ? ru : en;

  String _themeName(BuildContext context, ThemeMode value) => switch (value) {
        ThemeMode.system => _text(context, 'Системная', 'System'),
        ThemeMode.light => _text(context, 'Светлая', 'Light'),
        ThemeMode.dark => _text(context, 'Тёмная', 'Dark'),
      };

  String _columnsName(BuildContext context, int value) => value == 0 ? _text(context, 'Автоматически', 'Automatic') : '$value';

  static const _colors = <Color>[Colors.indigo, Colors.teal, Colors.deepPurple, Colors.orange, Colors.green];
  static const _colorNames = ['Индиго', 'Бирюзовый', 'Фиолетовый', 'Оранжевый', 'Зелёный'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final info = ResponsiveInfo.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: EdgeInsets.all(info.pagePadding),
        children: [
          _SettingsGroup(
            title: l10n.appearance,
            children: [
              ListTile(leading: const Icon(Icons.grid_view_rounded), title: Text(l10n.columns), subtitle: Text(_columnsName(context, UiLayoutSettings.columns)), trailing: const Icon(Icons.chevron_right), onTap: () => _showColumns(context)),
              ListTile(leading: const Icon(Icons.palette_outlined), title: Text(l10n.theme), subtitle: Text(_themeName(context, theme)), onTap: () => _showTheme(context)),
              ListTile(leading: const Icon(Icons.color_lens_outlined), title: Text(l10n.colorScheme), subtitle: Text(_colorNames[colorIndex]), onTap: () => _showColor(context)),
              ListTile(leading: const Icon(Icons.translate_rounded), title: Text(l10n.language), subtitle: Text(locale == null ? l10n.languageSystem : AppLocalizations(locale!).languageName), trailing: const Icon(Icons.chevron_right), onTap: () => _showLanguage(context)),
            ],
          ),
          const SizedBox(height: 12),
          _SettingsGroup(
            title: 'Данные и каталоги',
            children: [
              ListTile(leading: const Icon(Icons.new_releases_outlined), title: const Text('Версии каталогов'), subtitle: const Text('Опубликованные и установленные версии'), trailing: const Icon(Icons.chevron_right), onTap: () => _showCatalogVersions(context)),
              ListTile(leading: const Icon(Icons.backup_outlined), title: const Text('Резервная копия'), subtitle: const Text('Сохранение и восстановление данных'), trailing: const Icon(Icons.chevron_right), onTap: () => _showBackup(context)),
              ListTile(leading: const Icon(Icons.download_outlined), title: const Text('Загрузки'), subtitle: const Text('Очередь загрузки каталогов'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DownloadsPage()))),
              ListTile(leading: const Icon(Icons.lock_outline), title: const Text('Структура каталогов'), subtitle: const Text('Централизованный каталог доступен только для чтения'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CatalogAdminPage()))),
            ],
          ),
          const SizedBox(height: 12),
          _SettingsGroup(
            title: 'Обратная связь',
            children: [
              ListTile(leading: const Icon(Icons.feedback_outlined), title: const Text('Предложить изменение каталога'), subtitle: const Text('Предложения передаются разработчику'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FeedbackPage()))),
            ],
          ),
          const SizedBox(height: 12),
          _SettingsGroup(
            title: 'О приложении',
            children: [
              ListTile(leading: const Icon(Icons.info_outline), title: const Text('О приложении'), subtitle: const Text('Collection Catalog'), trailing: const Icon(Icons.chevron_right), onTap: () => showAboutDialog(context: context, applicationName: 'Collection Catalog', applicationVersion: '1.1.0+2', applicationLegalese: 'Universal collection engine application.')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showColumns(BuildContext context) async {
    final result = await showModalBottomSheet<int>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final value in [0, 1, 2, 3, 4])
              ListTile(
                leading: Icon(UiLayoutSettings.columns == value ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                title: Text(value == 0 ? _text(context, 'Автоматически', 'Automatic') : '${_text(context, 'Колонки', 'Columns')}: $value'),
                onTap: () => Navigator.pop(sheetContext, value),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (result != null) await UiLayoutSettings.save(columns: result);
  }

  Future<void> _showCatalogVersions(BuildContext context) async {
    final rows = <Widget>[];
    for (final catalog in CatalogRegistry.all) {
      final installed = await CatalogVersionStore.installedVersion(catalog.id);
      rows.add(ListTile(leading: const Icon(Icons.new_releases_outlined), title: Text(catalog.name), subtitle: Text('Опубликовано ${catalog.version} · На устройстве ${installed ?? '—'}')));
    }
    if (!context.mounted) return;
    await showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => SafeArea(child: ListView(shrinkWrap: true, padding: const EdgeInsets.only(bottom: 24), children: [const Padding(padding: EdgeInsets.fromLTRB(20, 20, 20, 8), child: Text('Версии каталогов', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))), ...rows])));
  }

  Future<Map<String, dynamic>> _buildBackup(BuildContext context) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final collections = container.read(collectionsProvider).valueOrNull ?? const <Collection>[];
    final service = container.read(itemServiceProvider);
    final states = await ItemStateStore.loadAll();
    final history = await CollectionHistoryStore.load();
    final collectionsData = <Map<String, dynamic>>[];
    for (final collection in collections) {
      final items = await service.getItems(collection.id);
      collectionsData.add({'id': collection.id, 'name': collection.name, 'templateId': collection.templateId, 'total': items.length});
    }
    return {'format': 'collection_catalog_backup_v1', 'createdAt': DateTime.now().toIso8601String(), 'catalogVersions': {for (final catalog in CatalogRegistry.all) catalog.id: catalog.version}, 'collections': collectionsData, 'itemStates': states.map((key, value) => MapEntry(key, value.toJson())), 'history': history.map((entry) => entry.toJson()).toList()};
  }

  Future<void> _showBackup(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Резервная копия', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            const Text('Сохраните данные коллекций и состояния предметов или восстановите их из ранее созданной копии.'),
            const SizedBox(height: 16),
            Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () async { await _exportBackup(context, false); if (sheetContext.mounted) Navigator.pop(sheetContext); }, icon: const Icon(Icons.data_object), label: const Text('JSON'))), const SizedBox(width: 8), Expanded(child: FilledButton.icon(onPressed: () async { await _exportBackup(context, true); if (sheetContext.mounted) Navigator.pop(sheetContext); }, icon: const Icon(Icons.archive_outlined), label: const Text('ZIP')))]),
            const Divider(height: 28),
            ListTile(leading: const Icon(Icons.restore_outlined), title: const Text('Восстановить данные'), subtitle: const Text('Импорт резервной копии'), trailing: const Icon(Icons.chevron_right), onTap: () async { Navigator.pop(sheetContext); await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BackupImportPage())); }),
          ],
        ),
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context, bool zip) async {
    try {
      final snapshot = await _buildBackup(context);
      if (zip) {
        await BackupExportService.exportZip(snapshot);
      } else {
        await BackupExportService.exportJson(snapshot);
      }
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Резервная копия сформирована.')));
    } catch (error) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка резервного копирования: $error')));
    }
  }

  Future<void> _showLanguage(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(leading: Icon(locale == null ? Icons.radio_button_checked : Icons.radio_button_unchecked), title: Text(AppLocalizations.of(context).languageSystem), onTap: () => Navigator.pop(sheetContext, '__system__')),
            ...AppLocalizations.supportedLocales.map((item) => ListTile(leading: Icon(locale?.languageCode == item.languageCode ? Icons.radio_button_checked : Icons.radio_button_unchecked), title: Text(AppLocalizations(item).languageName), onTap: () => Navigator.pop(sheetContext, item.languageCode))),
          ],
        ),
      ),
    );
    if (!context.mounted || result == null) return;
    onLocaleChanged(result == '__system__' ? null : Locale(result));
  }

  Future<void> _showTheme(BuildContext context) async {
    final result = await showModalBottomSheet<ThemeMode>(context: context, builder: (sheetContext) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: ThemeMode.values.map((value) => ListTile(title: Text(_themeName(context, value)), selected: value == theme, onTap: () => Navigator.pop(sheetContext, value))).toList())));
    if (result != null) onThemeChanged(result);
  }

  Future<void> _showColor(BuildContext context) async {
    final result = await showModalBottomSheet<int>(context: context, builder: (sheetContext) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: List.generate(_colors.length, (index) => ListTile(leading: CircleAvatar(backgroundColor: _colors[index]), title: Text(_colorNames[index]), selected: index == colorIndex, onTap: () => Navigator.pop(sheetContext, index))))));
    if (result != null) onColorChanged(result);
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))), ...children]),
        ),
      );
}
