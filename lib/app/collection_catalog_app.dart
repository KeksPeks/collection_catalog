import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/localization/app_localizations.dart';
import '../core/utils/responsive.dart';
import '../features/catalogs/presentation/favorites_page.dart';
import '../features/collections/presentation/pages/catalog_page.dart';
import '../features/collections/presentation/pages/collection_tools_page.dart';
import '../features/collections/presentation/pages/collections_page.dart';
import '../features/downloads/presentation/downloads_page.dart';
import '../features/feedback/presentation/feedback_page.dart';
import '../features/templates/presentation/pages/catalog_admin_page.dart';

/// Основная оболочка приложения.
///
/// Оболочка намеренно отделена от централизованного каталога: пользователь
/// может менять только личное состояние коллекции, избранное, заметки и
/// настройки интерфейса. Структура каталога остаётся только для чтения.
class CollectionCatalogApp extends StatefulWidget {
  const CollectionCatalogApp({super.key});

  @override
  State<CollectionCatalogApp> createState() => _CollectionCatalogAppState();
}

class _CollectionCatalogAppState extends State<CollectionCatalogApp> {
  static const _themeKey = 'settings.themeMode';
  static const _colorKey = 'settings.colorIndex';
  static const _fontKey = 'settings.fontScale';
  static const _uiKey = 'settings.uiScale';
  static const _localeKey = 'settings.locale';

  static const _colors = <Color>[
    Colors.indigo,
    Colors.teal,
    Colors.deepPurple,
    Colors.orange,
    Colors.green,
  ];

  ThemeMode _theme = ThemeMode.system;
  Locale? _locale;
  int _colorIndex = 0;
  double _fontScale = 1.0;
  double _uiScale = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  double _scale(double? value) {
    if (value == null || !value.isFinite) return 1.0;
    return value.clamp(0.70, 1.40).toDouble();
  }

  Future<void> _loadSettings() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!mounted) return;
      final color = preferences.getInt(_colorKey) ?? 0;
      final language = preferences.getString(_localeKey);
      setState(() {
        final theme = preferences.getString(_themeKey);
        _theme = theme == 'light'
            ? ThemeMode.light
            : theme == 'dark'
                ? ThemeMode.dark
                : ThemeMode.system;
        _colorIndex = color >= 0 && color < _colors.length ? color : 0;
        _fontScale = _scale(preferences.getDouble(_fontKey));
        _uiScale = _scale(preferences.getDouble(_uiKey));
        _locale = language == null || language.isEmpty ? null : Locale(language);
      });
    } catch (_) {
      // Локальные настройки не должны блокировать запуск приложения.
    }
  }

  Future<void> _saveSettings() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await Future.wait([
        preferences.setString(_themeKey, _theme.name),
        preferences.setInt(_colorKey, _colorIndex),
        preferences.setDouble(_fontKey, _fontScale),
        preferences.setDouble(_uiKey, _uiScale),
        if (_locale == null)
          preferences.remove(_localeKey)
        else
          preferences.setString(_localeKey, _locale!.languageCode),
      ]);
    } catch (_) {
      // Настройки не должны ломать приложение.
    }
  }

  ThemeData _themeData(Brightness brightness) {
    final density = (_uiScale - 1.0) * 4.0;
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _colors[_colorIndex],
        brightness: brightness,
      ),
      useMaterial3: true,
      visualDensity: VisualDensity(horizontal: density, vertical: density),
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * _uiScale,
          vertical: 2 * _uiScale,
        ),
        minVerticalPadding: 8 * _uiScale,
      ),
      cardTheme: CardThemeData(margin: EdgeInsets.all(4 * _uiScale)),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * _uiScale,
          vertical: 14 * _uiScale,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      onGenerateTitle: (context) => AppLocalizations.of(context).catalog,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: _themeData(Brightness.light),
      darkTheme: _themeData(Brightness.dark),
      themeMode: _theme,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(_fontScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: _CollectionShell(
        theme: _theme,
        colorIndex: _colorIndex,
        fontScale: _fontScale,
        uiScale: _uiScale,
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
        onUiChanged: (value) {
          setState(() => _uiScale = _scale(value));
          _saveSettings();
        },
        onLocaleChanged: (value) {
          setState(() => _locale = value);
          _saveSettings();
        },
      ),
    );
  }
}

class _CollectionShell extends StatefulWidget {
  final ThemeMode theme;
  final int colorIndex;
  final double fontScale;
  final double uiScale;
  final Locale? locale;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<int> onColorChanged;
  final ValueChanged<double> onFontChanged;
  final ValueChanged<double> onUiChanged;
  final ValueChanged<Locale?> onLocaleChanged;

  const _CollectionShell({
    required this.theme,
    required this.colorIndex,
    required this.fontScale,
    required this.uiScale,
    required this.locale,
    required this.onThemeChanged,
    required this.onColorChanged,
    required this.onFontChanged,
    required this.onUiChanged,
    required this.onLocaleChanged,
  });

  @override
  State<_CollectionShell> createState() => _CollectionShellState();
}

class _CollectionShellState extends State<_CollectionShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final info = ResponsiveInfo.of(context);

    final pages = <Widget>[
      const CollectionToolsPage(),
      const CatalogPage(),
      const FavoritesPage(),
      const CollectionsPage(),
      _SettingsPage(
        theme: widget.theme,
        colorIndex: widget.colorIndex,
        fontScale: widget.fontScale,
        uiScale: widget.uiScale,
        locale: widget.locale,
        onThemeChanged: widget.onThemeChanged,
        onColorChanged: widget.onColorChanged,
        onFontChanged: widget.onFontChanged,
        onUiChanged: widget.onUiChanged,
        onLocaleChanged: widget.onLocaleChanged,
      ),
    ];

    final destinations = <_Destination>[
      const _Destination(Icons.insights_outlined, Icons.insights, 'Обзор'),
      _Destination(Icons.menu_book_outlined, Icons.menu_book, l10n.catalog),
      _Destination(Icons.star_border_rounded, Icons.star_rounded, l10n.favorites),
      _Destination(Icons.collections_bookmark_outlined, Icons.collections_bookmark, l10n.myCollections),
      _Destination(Icons.settings_outlined, Icons.settings, l10n.settings),
    ];

    if (info.useRail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (value) => setState(() => _index = value),
              labelType: NavigationRailLabelType.all,
              groupAlignment: -0.85,
              destinations: [
                for (final destination in destinations)
                  NavigationRailDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: Text(destination.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: IndexedStack(index: _index, children: pages),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          for (final destination in destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
            ),
        ],
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
  final double uiScale;
  final Locale? locale;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<int> onColorChanged;
  final ValueChanged<double> onFontChanged;
  final ValueChanged<double> onUiChanged;
  final ValueChanged<Locale?> onLocaleChanged;

  const _SettingsPage({
    required this.theme,
    required this.colorIndex,
    required this.fontScale,
    required this.uiScale,
    required this.locale,
    required this.onThemeChanged,
    required this.onColorChanged,
    required this.onFontChanged,
    required this.onUiChanged,
    required this.onLocaleChanged,
  });

  String _text(
    BuildContext context,
    String ru,
    String en,
    String de,
    String fr,
    String es,
    String it,
    String pt,
    String zh,
    String ja,
    String ko,
    String ar,
  ) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'ru': return ru;
      case 'de': return de;
      case 'fr': return fr;
      case 'es': return es;
      case 'it': return it;
      case 'pt': return pt;
      case 'zh': return zh;
      case 'ja': return ja;
      case 'ko': return ko;
      case 'ar': return ar;
      default: return en;
    }
  }

  String _themeName(BuildContext context, ThemeMode value) {
    switch (value) {
      case ThemeMode.system:
        return _text(context, 'Системная', 'System', 'System', 'Système', 'Sistema', 'Sistema', 'Sistema', '系统', 'システム', '시스템', 'النظام');
      case ThemeMode.light:
        return _text(context, 'Светлая', 'Light', 'Hell', 'Clair', 'Claro', 'Chiaro', 'Claro', '浅色', 'ライト', '라이트', 'فاتح');
      case ThemeMode.dark:
        return _text(context, 'Тёмная', 'Dark', 'Dunkel', 'Sombre', 'Oscuro', 'Scuro', 'Escuro', '深色', 'ダーク', '다크', 'داكن');
    }
  }

  String _sizeName(BuildContext context, double value) {
    if (value < .8125) return _text(context, 'Очень маленький', 'Very small', 'Sehr klein', 'Très petit', 'Muy pequeño', 'Molto piccolo', 'Muito pequeno', '极小', '極小', '매우 작게', 'صغير جدًا');
    if (value < .9375) return _text(context, 'Маленький', 'Small', 'Klein', 'Petit', 'Pequeño', 'Piccolo', 'Pequeno', '小', '小', '작게', 'صغير');
    if (value < 1.0625) return _text(context, 'Средний', 'Medium', 'Mittel', 'Moyen', 'Medio', 'Medio', 'Médio', '中', '中', '중간', 'متوسط');
    if (value < 1.1875) return _text(context, 'Большой', 'Large', 'Groß', 'Grand', 'Grande', 'Grande', 'Grande', '大', '大', '크게', 'كبير');
    return _text(context, 'Очень большой', 'Very large', 'Sehr groß', 'Très grand', 'Muy grande', 'Molto grande', 'Muito grande', '极大', '極大', '매우 크게', 'كبير جدًا');
  }

  String _colorName(BuildContext context, int index) {
    const names = [
      ['Индиго', 'Indigo', 'Indigo', 'Indigo', 'Índigo', 'Indaco', 'Índigo', '靛蓝', 'インディゴ', '인디고', 'نيلي'],
      ['Бирюзовый', 'Teal', 'Türkis', 'Sarcelle', 'Verde azulado', 'Verde acqua', 'Verde-azulado', '蓝绿', 'ティール', '청록', 'أزرق مخضر'],
      ['Фиолетовый', 'Purple', 'Violett', 'Violet', 'Morado', 'Viola', 'Roxo', '紫色', '紫', '보라', 'بنفسجي'],
      ['Оранжевый', 'Orange', 'Orange', 'Orange', 'Naranja', 'Arancione', 'Laranja', '橙色', 'オレンジ', '주황', 'برتقالي'],
      ['Зелёный', 'Green', 'Grün', 'Vert', 'Verde', 'Verde', 'Verde', '绿色', '緑', '초록', 'أخضر'],
    ];
    final language = Localizations.localeOf(context).languageCode;
    final indexByLanguage = switch (language) {
      'ru' => 0,
      'de' => 2,
      'fr' => 3,
      'es' => 4,
      'it' => 5,
      'pt' => 6,
      'zh' => 7,
      'ja' => 8,
      'ko' => 9,
      'ar' => 10,
      _ => 1,
    };
    return names[index][indexByLanguage];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final info = ResponsiveInfo.of(context);
    final padding = EdgeInsets.all(info.pagePadding);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: padding,
        children: [
          _SettingsGroup(
            title: 'Интерфейс',
            children: [
              ListTile(
                leading: const Icon(Icons.devices_outlined),
                title: const Text('Адаптивный режим'),
                subtitle: Text(
                  info.isFoldable
                      ? 'Раскладушка: используется доступная область панели'
                      : info.isLargeTablet
                          ? 'Планшет / широкий экран'
                          : info.isTablet
                              ? 'Большой телефон / планшет'
                              : 'Телефон',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.view_agenda_outlined),
                title: const Text('Размер интерфейса'),
                subtitle: Text(_sizeName(context, uiScale)),
                onTap: () => _showScale(context, false),
              ),
              ListTile(
                leading: const Icon(Icons.text_fields_outlined),
                title: const Text('Размер текста'),
                subtitle: Text(_sizeName(context, fontScale)),
                onTap: () => _showScale(context, true),
              ),
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('Тема'),
                subtitle: Text(_themeName(context, theme)),
                onTap: () => _showTheme(context),
              ),
              ListTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: const Text('Цветовая схема'),
                subtitle: Text(_colorName(context, colorIndex)),
                onTap: () => _showColor(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SettingsGroup(
            title: 'Данные и каталоги',
            children: [
              ListTile(
                leading: const Icon(Icons.insights_outlined),
                title: const Text('Инструменты коллекционера'),
                subtitle: const Text('Прогресс, статистика, поиск, история, экспорт, сканер и версии каталогов.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CollectionToolsPage())),
              ),
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: const Text('Загрузки'),
                subtitle: const Text('Очередь загрузки каталогов'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DownloadsPage())),
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Структура каталогов'),
                subtitle: const Text('Централизованный каталог доступен только для чтения.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CatalogAdminPage())),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SettingsGroup(
            title: 'Обратная связь',
            children: [
              ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: const Text('Предложить изменение каталога'),
                subtitle: const Text('Пользователь не меняет структуру каталога напрямую.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FeedbackPage())),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SettingsGroup(
            title: l10n.settings,
            children: [
              ListTile(
                leading: const Icon(Icons.translate_rounded),
                title: Text(l10n.language),
                subtitle: Text(locale == null ? l10n.languageSystem : AppLocalizations(locale!).languageName),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLanguage(context),
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('О приложении'),
                subtitle: Text(l10n.catalogDescription),
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'Collection Catalog',
                  applicationVersion: '1.0.0',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showLanguage(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: Icon(locale == null ? Icons.radio_button_checked : Icons.radio_button_unchecked),
              title: Text(AppLocalizations.of(context).languageSystem),
              onTap: () => Navigator.pop(sheetContext, '__system__'),
            ),
            ...AppLocalizations.supportedLocales.map(
              (item) => ListTile(
                leading: Icon(locale?.languageCode == item.languageCode ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                title: Text(AppLocalizations(item).languageName),
                onTap: () => Navigator.pop(sheetContext, item.languageCode),
              ),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted || result == null) return;
    onLocaleChanged(result == '__system__' ? null : Locale(result));
  }

  Future<void> _showTheme(BuildContext context) async {
    final result = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values
              .map(
                (value) => ListTile(
                  title: Text(_themeName(context, value)),
                  selected: value == theme,
                  onTap: () => Navigator.pop(sheetContext, value),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
    if (result != null) onThemeChanged(result);
  }

  Future<void> _showColor(BuildContext context) async {
    const colors = <Color>[
      Colors.indigo,
      Colors.teal,
      Colors.deepPurple,
      Colors.orange,
      Colors.green,
    ];
    final result = await showModalBottomSheet<int>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < colors.length; index++)
              ListTile(
                leading: CircleAvatar(backgroundColor: colors[index]),
                title: Text(_colorName(context, index)),
                selected: index == colorIndex,
                onTap: () => Navigator.pop(sheetContext, index),
              ),
          ],
        ),
      ),
    );
    if (result != null) onColorChanged(result);
  }

  Future<void> _showScale(BuildContext context, bool font) async {
    final current = font ? fontScale : uiScale;
    final values = font
        ? const [0.75, 0.875, 1.0, 1.125, 1.25]
        : const [0.70, 0.85, 1.0, 1.15, 1.30];
    final result = await showModalBottomSheet<double>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: values
              .map(
                (value) => ListTile(
                  leading: Icon((value - current).abs() < 0.01 ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                  title: Text(_sizeName(context, value)),
                  subtitle: Text('${(value * 100).round()}%'),
                  onTap: () => Navigator.pop(sheetContext, value),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
    if (result == null) return;
    if (font) {
      onFontChanged(result);
    } else {
      onUiChanged(result);
    }
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}
