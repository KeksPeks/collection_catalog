import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/localization/app_localizations.dart';
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
  static const colorNames = ['Indigo', 'Teal', 'Purple', 'Orange', 'Green'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
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
  }

  ThemeMode _themeModeFromString(String? value) {
    switch (value) { case 'light': return ThemeMode.light; case 'dark': return ThemeMode.dark; default: return ThemeMode.system; }
  }

  String _themeModeToString(ThemeMode value) {
    switch (value) { case ThemeMode.light: return 'light'; case ThemeMode.dark: return 'dark'; case ThemeMode.system: return 'system'; }
  }

  int _validColorIndex(int? value) => value == null || value < 0 || value >= colors.length ? 0 : value;

  double _validScale(double? value) => value == null || !value.isFinite || value <= 0 ? 1.0 : value.clamp(0.5, 2.0).toDouble();

  Future<void> _saveSettings() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.setString(_themeKey, _themeModeToString(themeMode)),
      preferences.setInt(_colorKey, colorIndex),
      preferences.setDouble(_fontScaleKey, fontScale),
      preferences.setDouble(_uiScaleKey, uiScale),
      if (locale == null) preferences.remove(_localeKey) else preferences.setString(_localeKey, locale!.languageCode),
    ]);
  }

  void _changeTheme(ThemeMode value) { setState(() => themeMode = value); _saveSettings(); }
  void _changeColor(int value) { setState(() => colorIndex = _validColorIndex(value)); _saveSettings(); }
  void _changeFontScale(double value) { setState(() => fontScale = _validScale(value)); _saveSettings(); }
  void _changeUiScale(double value) { setState(() => uiScale = _validScale(value)); _saveSettings(); }
  void _changeLocale(Locale? value) { setState(() => locale = value); _saveSettings(); }

  TextTheme _scaleTextTheme(TextTheme base) {
    TextStyle? scale(TextStyle? style) => style?.fontSize == null ? style : style!.copyWith(fontSize: style.fontSize! * fontScale);
    return base.copyWith(
      displayLarge: scale(base.displayLarge), displayMedium: scale(base.displayMedium), displaySmall: scale(base.displaySmall),
      headlineLarge: scale(base.headlineLarge), headlineMedium: scale(base.headlineMedium), headlineSmall: scale(base.headlineSmall),
      titleLarge: scale(base.titleLarge), titleMedium: scale(base.titleMedium), titleSmall: scale(base.titleSmall),
      bodyLarge: scale(base.bodyLarge), bodyMedium: scale(base.bodyMedium), bodySmall: scale(base.bodySmall),
      labelLarge: scale(base.labelLarge), labelMedium: scale(base.labelMedium), labelSmall: scale(base.labelSmall),
    );
  }

  @override
  Widget build(BuildContext context) {
    final seed = colors[colorIndex];
    final density = VisualDensity(horizontal: (uiScale - 1) * 2, vertical: (uiScale - 1) * 2);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).catalog,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: seed), useMaterial3: true, visualDensity: density, textTheme: _scaleTextTheme(ThemeData.light().textTheme)),
      darkTheme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark), useMaterial3: true, visualDensity: density, textTheme: _scaleTextTheme(ThemeData.dark().textTheme)),
      themeMode: themeMode,
      home: MainNavigation(
        themeMode: themeMode, colorIndex: colorIndex, fontScale: fontScale, uiScale: uiScale, locale: locale,
        onThemeChanged: _changeTheme, onColorChanged: _changeColor, onFontScaleChanged: _changeFontScale, onUiScaleChanged: _changeUiScale, onLocaleChanged: _changeLocale,
      ),
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
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: [
        const CatalogPage(),
        const CollectionsPage(),
        _SettingsPage(themeMode: widget.themeMode, colorIndex: widget.colorIndex, fontScale: widget.fontScale, uiScale: widget.uiScale, locale: widget.locale, onThemeChanged: widget.onThemeChanged, onColorChanged: widget.onColorChanged, onFontScaleChanged: widget.onFontScaleChanged, onUiScaleChanged: widget.onUiScaleChanged, onLocaleChanged: widget.onLocaleChanged),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => setState(() => currentIndex = index),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.menu_book_outlined), selectedIcon: const Icon(Icons.menu_book), label: l10n.catalog),
          NavigationDestination(icon: const Icon(Icons.collections_bookmark_outlined), selectedIcon: const Icon(Icons.collections_bookmark), label: l10n.myCollections),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: l10n.settings),
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
  final Locale? locale;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<int> onColorChanged;
  final ValueChanged<double> onFontScaleChanged;
  final ValueChanged<double> onUiScaleChanged;
  final ValueChanged<Locale?> onLocaleChanged;

  const _SettingsPage({required this.themeMode, required this.colorIndex, required this.fontScale, required this.uiScale, required this.locale, required this.onThemeChanged, required this.onColorChanged, required this.onFontScaleChanged, required this.onUiScaleChanged, required this.onLocaleChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _SettingsGroup(title: l10n.settings, children: [
          ListTile(leading: const Icon(Icons.translate_rounded), title: Text(l10n.language), subtitle: Text(locale == null ? l10n.languageSystem : AppLocalizations(Locale(locale!.languageCode)).languageName), trailing: const Icon(Icons.chevron_right), onTap: () => _showLanguages(context)),
        ]),
        const SizedBox(height: 12),
        _SettingsGroup(title: l10n.catalog, children: [
          ListTile(leading: const Icon(Icons.admin_panel_settings_outlined), title: const Text('Catalog administrator'), subtitle: const Text('Create and edit ready-made catalogs'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CatalogAdminPage()))),
          ListTile(leading: const Icon(Icons.download_outlined), title: const Text('Downloads'), subtitle: const Text('Catalog download queue'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DownloadsPage()))),
        ]),
        const SizedBox(height: 12),
        _SettingsGroup(title: l10n.appearance, children: [
          ListTile(leading: const Icon(Icons.palette_outlined), title: const Text('Theme'), subtitle: Text(_themeName(themeMode)), onTap: () => _showThemes(context)),
          ListTile(leading: const Icon(Icons.color_lens_outlined), title: const Text('Color scheme'), subtitle: Text(_MyAppState.colorNames[colorIndex]), onTap: () => _showColors(context)),
          ListTile(leading: const Icon(Icons.text_fields_outlined), title: const Text('Font size'), subtitle: Text(_sizeName(fontScale)), onTap: () => _showScale(context, true)),
          ListTile(leading: const Icon(Icons.view_agenda_outlined), title: const Text('Interface size'), subtitle: Text(_sizeName(uiScale)), onTap: () => _showScale(context, false)),
        ]),
        const SizedBox(height: 12),
        _SettingsGroup(title: 'Help', children: [
          ListTile(leading: const Icon(Icons.feedback_outlined), title: const Text('Feedback'), subtitle: const Text('Request catalog changes'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FeedbackPage()))),
          ListTile(leading: const Icon(Icons.help_outline), title: const Text('About'), subtitle: const Text('Application information'), onTap: () => showAboutDialog(context: context, applicationName: 'Collection Catalog', applicationVersion: '1.0.0')),
        ]),
      ]),
    );
  }

  String _themeName(ThemeMode mode) { switch (mode) { case ThemeMode.system: return 'System'; case ThemeMode.light: return 'Light'; case ThemeMode.dark: return 'Dark'; } }
  String _sizeName(double value) => value < 0.95 ? 'Small' : value > 1.05 ? 'Large' : 'Medium';

  Future<void> _showLanguages(BuildContext context) async {
    final selected = await showModalBottomSheet<Locale?>(context: context, builder: (sheetContext) => SafeArea(child: ListView(shrinkWrap: true, children: [
      ListTile(title: Text(AppLocalizations.of(context).languageSystem), leading: Icon(locale == null ? Icons.radio_button_checked : Icons.radio_button_unchecked), onTap: () => Navigator.pop(sheetContext, null)),
      ...AppLocalizations.supportedLocales.map((item) => ListTile(title: Text(AppLocalizations(item).languageName), leading: Icon(locale?.languageCode == item.languageCode ? Icons.radio_button_checked : Icons.radio_button_unchecked), onTap: () => Navigator.pop(sheetContext, item))),
    ])));
    onLocaleChanged(selected);
  }

  Future<void> _showThemes(BuildContext context) async {
    final selected = await showModalBottomSheet<ThemeMode>(context: context, builder: (sheetContext) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: ThemeMode.values.map((mode) => ListTile(title: Text(_themeName(mode)), selected: mode == themeMode, onTap: () => Navigator.pop(sheetContext, mode))).toList())));
    if (selected != null) onThemeChanged(selected);
  }

  Future<void> _showColors(BuildContext context) async {
    final selected = await showModalBottomSheet<int>(context: context, builder: (sheetContext) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: List.generate(_MyAppState.colors.length, (index) => ListTile(leading: CircleAvatar(backgroundColor: _MyAppState.colors[index]), title: Text(_MyAppState.colorNames[index]), selected: index == colorIndex, onTap: () => Navigator.pop(sheetContext, index))))));
    if (selected != null) onColorChanged(selected);
  }

  Future<void> _showScale(BuildContext context, bool font) async {
    final current = font ? fontScale : uiScale;
    final selected = await showModalBottomSheet<double>(context: context, builder: (sheetContext) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(title: const Text('Small'), onTap: () => Navigator.pop(sheetContext, font ? 0.90 : 0.85)),
      ListTile(title: const Text('Medium'), onTap: () => Navigator.pop(sheetContext, 1.0)),
      ListTile(title: const Text('Large'), onTap: () => Navigator.pop(sheetContext, 1.15)),
    ])));
    if (selected == null) return;
    if (font) onFontScaleChanged(selected); else onUiScaleChanged(selected);
    if (current == selected) return;
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsGroup({required this.title, required this.children});
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))), ...children])));
}
