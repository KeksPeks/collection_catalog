import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/localization/app_localizations.dart';
import '../features/catalogs/presentation/favorites_page.dart';
import '../features/collections/presentation/pages/catalog_page.dart';
import '../features/collections/presentation/pages/collections_page.dart';
import '../features/collections/presentation/pages/collection_tools_page.dart';
import '../features/downloads/presentation/downloads_page.dart';
import '../features/feedback/presentation/feedback_page.dart';
import '../features/overview/presentation/overview_page.dart';
import '../features/settings/presentation/pages/version_history_page.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _themeKey = 'settings.themeMode';
  static const _colorKey = 'settings.colorIndex';
  static const _fontScaleKey = 'settings.fontScale';
  static const _localeKey = 'settings.locale';

  ThemeMode themeMode = ThemeMode.system;
  Locale? locale;
  int colorIndex = 0;
  double fontScale = 1.0;

  static const colors = [
    Colors.indigo,
    Colors.teal,
    Colors.deepPurple,
    Colors.orange,
    Colors.green,
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  double _validScale(double? value) {
    if (value == null || !value.isFinite) return 1.0;
    return value.clamp(0.70, 1.40).toDouble();
  }

  int _validColorIndex(int? value) {
    if (value == null || value < 0 || value >= colors.length) return 0;
    return value;
  }

  ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode value) {
    switch (value) {
      case ThemeMode.light: return 'light';
      case ThemeMode.dark: return 'dark';
      case ThemeMode.system: return 'system';
    }
  }

  Future<void> _loadSettings() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!mounted) return;
      final language = preferences.getString(_localeKey);
      setState(() {
        themeMode = _themeModeFromString(preferences.getString(_themeKey));
        colorIndex = _validColorIndex(preferences.getInt(_colorKey));
        fontScale = _validScale(preferences.getDouble(_fontScaleKey));
        locale = language == null || language.isEmpty ? null : Locale(language);
      });
    } catch (_) {
      // Локальные настройки не должны блокировать запуск приложения.
    }
  }

  Future<void> _saveSettings() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await Future.wait([
        preferences.setString(_themeKey, _themeModeToString(themeMode)),
        preferences.setInt(_colorKey, colorIndex),
        preferences.setDouble(_fontScaleKey, fontScale),
        if (locale == null)
          preferences.remove(_localeKey)
        else
          preferences.setString(_localeKey, locale!.languageCode),
      ]);
    } catch (_) {
      // Настройки не должны ломать приложение.
    }
  }

  void _changeTheme(ThemeMode value) {
    setState(() => themeMode = value);
    _saveSettings();
  }

  void _changeColor(int value) {
    setState(() => colorIndex = _validColorIndex(value));
    _saveSettings();
  }

  void _changeFontScale(double value) {
    setState(() => fontScale = _validScale(value));
    _saveSettings();
  }

  void _changeLocale(Locale? value) {
    setState(() => locale = value);
    _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    final seed = colors[colorIndex];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      onGenerateTitle: (context) => AppLocalizations.of(context).catalog,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: _buildTheme(seed, Brightness.light),
      darkTheme: _buildTheme(seed, Brightness.dark),
      themeMode: themeMode,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(textScaler: TextScaler.linear(fontScale)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: MainNavigation(
        themeMode: themeMode,
        colorIndex: colorIndex,
        fontScale: fontScale,
        locale: locale,
        onThemeChanged: _changeTheme,
        onColorChanged: _changeColor,
        onFontScaleChanged: _changeFontScale,
        onLocaleChanged: _changeLocale,
      ),
    );
  }

  ThemeData _buildTheme(Color seed, Brightness brightness) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
      useMaterial3: true,
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        minVerticalPadding: 8,
      ),
      cardTheme: const CardThemeData(margin: EdgeInsets.all(4)),
      inputDecorationTheme: const InputDecorationTheme(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final ThemeMode themeMode;
  final int colorIndex;
  final double fontScale;
  final Locale? locale;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<int> onColorChanged;
  final ValueChanged<double> onFontScaleChanged;
  final ValueChanged<Locale?> onLocaleChanged;

  const MainNavigation({
    super.key,
    required this.themeMode,
    required this.colorIndex,
    required this.fontScale,
    required this.locale,
    required this.onThemeChanged,
    required this.onColorChanged,
    required this.onFontScaleChanged,
    required this.onLocaleChanged,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destinations = [
      const _NavigationDestinationData(label: 'Обзор', icon: Icons.insights_outlined, selectedIcon: Icons.insights),
      _NavigationDestinationData(label: l10n.catalog, icon: Icons.menu_book_outlined, selectedIcon: Icons.menu_book),
      _NavigationDestinationData(label: l10n.favorites, icon: Icons.star_border_rounded, selectedIcon: Icons.star_rounded),
      _NavigationDestinationData(label: l10n.myCollections, icon: Icons.collections_bookmark_outlined, selectedIcon: Icons.collections_bookmark),
      const _NavigationDestinationData(label: 'Инструменты', icon: Icons.build_outlined, selectedIcon: Icons.build),
      _NavigationDestinationData(label: l10n.settings, icon: Icons.settings_outlined, selectedIcon: Icons.settings),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          const OverviewPage(),
          const CatalogPage(),
          const FavoritesPage(),
          const CollectionsPage(),
          const CollectionToolsPage(),
          _SettingsPage(
            themeMode: widget.themeMode,
            colorIndex: widget.colorIndex,
            fontScale: widget.fontScale,
            locale: widget.locale,
            onThemeChanged: widget.onThemeChanged,
            onColorChanged: widget.onColorChanged,
            onFontScaleChanged: widget.onFontScaleChanged,
            onLocaleChanged: widget.onLocaleChanged,
          ),
        ],
      ),
      bottomNavigationBar: _BottomNavigationBar(
        destinations: destinations,
        selectedIndex: currentIndex,
        onSelected: (index) => setState(() => currentIndex = index),
      ),
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
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      elevation: 3,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 76,
          child: Row(
            children: [
              for (var index = 0; index < destinations.length; index++)
                Expanded(
                  child: _BottomNavigationItem(
                    data: destinations[index],
                    selected: index == selectedIndex,
                    onTap: () => onSelected(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavigationItem extends StatelessWidget {
  final _NavigationDestinationData data;
  final bool selected;
  final VoidCallback onTap;
  const _BottomNavigationItem({required this.data, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: data.label,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: selected ? colors.secondaryContainer : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  selected ? data.selectedIcon : data.icon,
                  color: selected ? colors.onSecondaryContainer : colors.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(height: 3),
              Flexible(
                child: Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? colors.onSurface : colors.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  final ThemeMode themeMode;
  final int colorIndex;
  final double fontScale;
  final Locale? locale;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<int> onColorChanged;
  final ValueChanged<double> onFontScaleChanged;
  final ValueChanged<Locale?> onLocaleChanged;

  const _SettingsPage({
    required this.themeMode,
    required this.colorIndex,
    required this.fontScale,
    required this.locale,
    required this.onThemeChanged,
    required this.onColorChanged,
    required this.onFontScaleChanged,
    required this.onLocaleChanged,
  });

  String _text(BuildContext context, String ru, String en, String de, String fr, String es, String it, String pt, String zh, String ja, String ko, String ar) {
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

  String _sizeName(BuildContext context, double value) {
    if (value < 0.8125) return _text(context, 'Очень маленький', 'Very small', 'Sehr klein', 'Très petit', 'Muy pequeño', 'Molto piccolo', 'Muito pequeno', '极小', '極小', '매우 작게', 'صغير جدًا');
    if (value < 0.9375) return _text(context, 'Маленький', 'Small', 'Klein', 'Petit', 'Pequeño', 'Piccolo', 'Pequeno', '小', '小', '작게', 'صغير');
    if (value < 1.0625) return _text(context, 'Средний', 'Medium', 'Mittel', 'Moyen', 'Medio', 'Medio', 'Médio', '中', '中', '중간', 'متوسط');
    if (value < 1.1875) return _text(context, 'Большой', 'Large', 'Groß', 'Grand', 'Grande', 'Grande', 'Grande', '大', '大', '크게', 'كبير');
    return _text(context, 'Очень большой', 'Very large', 'Sehr groß', 'Très grand', 'Muy grande', 'Molto grande', 'Muito grande', '极大', '極大', '매우 크게', 'كبير جدًا');
  }

  String _themeName(BuildContext context, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system: return _text(context, 'Системная', 'System', 'System', 'Système', 'Sistema', 'Sistema', 'Sistema', '系统', 'システム', '시스템', 'النظام');
      case ThemeMode.light: return _text(context, 'Светлая', 'Light', 'Hell', 'Clair', 'Claro', 'Chiaro', 'Claro', '浅色', 'ライト', '라이트', 'فاتح');
      case ThemeMode.dark: return _text(context, 'Тёмная', 'Dark', 'Dunkel', 'Sombre', 'Oscuro', 'Scuro', 'Escuro', '深色', 'ダーク', '다크', 'داكن');
    }
  }

  String _colorName(BuildContext context, int index) {
    const names = [
      ['Индиго', 'Indigo', 'Indigo', 'Indigo', 'Índigo', 'Indaco', 'Índigo', '靛蓝', 'インディゴ', '인디고', 'نيلي'],
      ['Бирюзовый', 'Teal', 'Türkis', 'Sarcelle', 'Verde azulado', 'Verde acqua', 'Verde-azulado', '蓝绿', 'ティール', '청록', 'أزرق مخضر'],
      ['Фиолетовый', 'Purple', 'Violett', 'Violet', 'Morado', 'Viola', 'Roxo', '紫色', '紫', '보라', 'بنفسجي'],
      ['Оранжевый', 'Orange', 'Orange', 'Orange', 'Naranja', 'Arancione', 'Laranja', '橙色', 'オレンジ', '주황', 'برتقالي'],
      ['Зелёный', 'Green', 'Grün', 'Vert', 'Verde', 'Verde', 'Verde', '绿色', '緑', '초록', 'أخضر'],
    ];
    final lang = Localizations.localeOf(context).languageCode;
    final languageIndex = switch (lang) {
      'ru' => 0, 'de' => 2, 'fr' => 3, 'es' => 4, 'it' => 5,
      'pt' => 6, 'zh' => 7, 'ja' => 8, 'ko' => 9, 'ar' => 10, _ => 1,
    };
    return names[index][languageIndex];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final downloads = _text(context, 'Загрузки', 'Downloads', 'Downloads', 'Téléchargements', 'Descargas', 'Download', 'Transferências', '下载', 'ダウンロード', '다운로드', 'التنزيلات');
    final downloadDescription = _text(context, 'Очередь загрузки каталогов', 'Catalog download queue', 'Katalog-Warteschlange', 'File de téléchargement', 'Cola de descargas', 'Coda download cataloghi', 'Fila de transferências', '目录下载队列', 'カタログのダウンロード待ち', '카탈로그 다운로드 대기열', 'قائمة تنزيل الفهارس');
    final theme = _text(context, 'Тема', 'Theme', 'Thema', 'Thème', 'Tema', 'Tema', 'Tema', '主题', 'テーマ', '테마', 'السمة');
    final colors = _text(context, 'Цветовая схема', 'Color scheme', 'Farbschema', 'Couleurs', 'Esquema de color', 'Schema colori', 'Esquema de cores', '配色', '配色', '색상', 'نظام الألوان');
    final font = _text(context, 'Размер текста', 'Text size', 'Textgröße', 'Taille du texte', 'Tamaño del texto', 'Dimensione del testo', 'Tamanho do texto', '文字大小', '文字サイズ', '글자 크기', 'حجم النص');
    final feedback = _text(context, 'Обратная связь', 'Feedback', 'Feedback', 'Commentaires', 'Comentarios', 'Feedback', 'Feedback', '反馈', 'フィードバック', '피드백', 'ملاحظات');
    final feedbackDescription = _text(context, 'Предложения по изменению каталогов', 'Suggest catalog changes', 'Katalogänderungen vorschlagen', 'Proposer des changements', 'Sugerir cambios', 'Proponi modifiche', 'Sugerir alterações', '建议修改目录', 'カタログ変更を提案', '카탈로그 변경 제안', 'اقتراح تغييرات الفهرس');
    final about = _text(context, 'О приложении', 'About', 'Über', 'À propos', 'Acerca de', 'Informazioni', 'Sobre', '关于', 'アプリについて', '정보', 'حول التطبيق');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsGroup(
            title: l10n.settings,
            children: [
              ListTile(
                leading: const Icon(Icons.translate_rounded),
                title: Text(l10n.language),
                subtitle: Text(locale == null ? l10n.languageSystem : AppLocalizations(locale!).languageName),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLanguages(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SettingsGroup(
            title: l10n.catalog,
            children: [
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: Text(downloads),
                subtitle: Text(downloadDescription),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DownloadsPage())),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SettingsGroup(
            title: l10n.appearance,
            children: [
              ListTile(leading: const Icon(Icons.palette_outlined), title: Text(theme), subtitle: Text(_themeName(context, themeMode)), onTap: () => _showThemes(context)),
              ListTile(leading: const Icon(Icons.color_lens_outlined), title: Text(colors), subtitle: Text(_colorName(context, colorIndex)), onTap: () => _showColors(context)),
              ListTile(leading: const Icon(Icons.text_fields_outlined), title: Text(font), subtitle: Text(_sizeName(context, fontScale)), onTap: () => _showScale(context)),
            ],
          ),
          const SizedBox(height: 12),
          _SettingsGroup(
            title: l10n.settings,
            children: [
              ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: Text(feedback),
                subtitle: Text(feedbackDescription),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FeedbackPage())),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SettingsGroup(
            title: about,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(about),
                subtitle: Text(l10n.catalogDescription),
                onTap: () => _showAbout(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showAbout(BuildContext context) async {
    final versions = _text(context, 'Версии каталогов', 'Catalog versions', 'Katalogversionen', 'Versions des catalogues', 'Versiones de catálogos', 'Versioni dei cataloghi', 'Versões dos catálogos', '目录版本', 'カタログのバージョン', '카탈로그 버전', 'إصدارات الفهارس');
    final title = _text(context, 'О приложении', 'About', 'Über', 'À propos', 'Acerca de', 'Informazioni', 'Sobre', '关于', 'アプリについて', '정보', 'حول التطبيق');
    final description = _text(context, 'Collection Catalog — локальный каталог коллекций.', 'Collection Catalog — local collection catalog.', 'Collection Catalog — lokaler Sammlungskatalog.', 'Collection Catalog — catalogue local de collections.', 'Collection Catalog — catálogo local de colecciones.', 'Collection Catalog — catalogo locale delle collezioni.', 'Collection Catalog — catálogo local de coleções.', 'Collection Catalog — 本地收藏目录。', 'Collection Catalog — ローカルコレクションカタログ。', 'Collection Catalog — 로컬 컬렉션 카탈로그.', 'Collection Catalog — فهرس محلي للمجموعات.');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VersionHistoryPage()));
            },
            icon: const Icon(Icons.history),
            label: Text(versions),
          ),
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(MaterialLocalizations.of(context).closeButtonLabel)),
        ],
      ),
    );
  }

  Future<void> _showLanguages(BuildContext context) async {
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

  Future<void> _showThemes(BuildContext context) async {
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) => ListTile(title: Text(_themeName(context, mode)), selected: mode == themeMode, onTap: () => Navigator.pop(sheetContext, mode))).toList(),
        ),
      ),
    );
    if (selected != null) onThemeChanged(selected);
  }

  Future<void> _showColors(BuildContext context) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            _MyAppState.colors.length,
            (index) => ListTile(
              leading: CircleAvatar(backgroundColor: _MyAppState.colors[index]),
              title: Text(_colorName(context, index)),
              selected: index == colorIndex,
              onTap: () => Navigator.pop(sheetContext, index),
            ),
          ),
        ),
      ),
    );
    if (selected != null) onColorChanged(selected);
  }

  Future<void> _showScale(BuildContext context) async {
    final values = const [0.75, 0.875, 1.0, 1.125, 1.25];
    final selected = await showModalBottomSheet<double>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: values.map((value) => ListTile(
            leading: Icon((value - fontScale).abs() < 0.01 ? Icons.radio_button_checked : Icons.radio_button_unchecked),
            title: Text(_sizeName(context, value)),
            subtitle: Text('${(value * 100).round()}%'),
            onTap: () => Navigator.pop(sheetContext, value),
          )).toList(),
        ),
      ),
    );
    if (selected != null) onFontScaleChanged(selected);
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
              child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}
