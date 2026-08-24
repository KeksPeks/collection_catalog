import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/localization/app_localizations.dart';
import '../core/utils/responsive.dart';
import '../features/catalogs/presentation/favorites_page.dart';
import '../features/collections/presentation/pages/catalog_page.dart';
import '../features/collections/presentation/pages/collections_page.dart';
import '../features/downloads/presentation/downloads_page.dart';
import '../features/feedback/presentation/feedback_page.dart';
import '../features/templates/presentation/pages/catalog_admin_page.dart';

class ResponsiveCollectionApp extends StatefulWidget {
  const ResponsiveCollectionApp({super.key});

  @override
  State<ResponsiveCollectionApp> createState() => _ResponsiveCollectionAppState();
}

class _ResponsiveCollectionAppState extends State<ResponsiveCollectionApp> {
  static const _themeKey = 'settings.themeMode';
  static const _colorKey = 'settings.colorIndex';
  static const _fontKey = 'settings.fontScale';
  static const _uiKey = 'settings.uiScale';
  static const _localeKey = 'settings.locale';
  static const colors = [Colors.indigo, Colors.teal, Colors.deepPurple, Colors.orange, Colors.green];

  ThemeMode _theme = ThemeMode.system;
  Locale? _locale;
  int _color = 0;
  double _fontScale = 1;
  double _uiScale = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  double _scale(double? value) => value == null || !value.isFinite ? 1 : value.clamp(.70, 1.40).toDouble();

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      final theme = p.getString(_themeKey);
      _theme = theme == 'light' ? ThemeMode.light : theme == 'dark' ? ThemeMode.dark : ThemeMode.system;
      final color = p.getInt(_colorKey) ?? 0;
      _color = color >= 0 && color < colors.length ? color : 0;
      _fontScale = _scale(p.getDouble(_fontKey));
      _uiScale = _scale(p.getDouble(_uiKey));
      final language = p.getString(_localeKey);
      _locale = language == null || language.isEmpty ? null : Locale(language);
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await Future.wait([
      p.setString(_themeKey, _theme.name),
      p.setInt(_colorKey, _color),
      p.setDouble(_fontKey, _fontScale),
      p.setDouble(_uiKey, _uiScale),
      if (_locale == null) p.remove(_localeKey) else p.setString(_localeKey, _locale!.languageCode),
    ]);
  }

  void _setTheme(ThemeMode value) { setState(() => _theme = value); _save(); }
  void _setColor(int value) { setState(() => _color = value); _save(); }
  void _setFont(double value) { setState(() => _fontScale = value); _save(); }
  void _setUi(double value) { setState(() => _uiScale = value); _save(); }
  void _setLocale(Locale? value) { setState(() => _locale = value); _save(); }

  ThemeData _themeData(Brightness brightness) {
    final density = (_uiScale - 1) * 4;
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: colors[_color], brightness: brightness),
      useMaterial3: true,
      visualDensity: VisualDensity(horizontal: density, vertical: density),
      listTileTheme: ListTileThemeData(contentPadding: EdgeInsets.symmetric(horizontal: 16 * _uiScale, vertical: 2 * _uiScale), minVerticalPadding: 8 * _uiScale),
      cardTheme: CardThemeData(margin: EdgeInsets.all(4 * _uiScale)),
      inputDecorationTheme: InputDecorationTheme(contentPadding: EdgeInsets.symmetric(horizontal: 16 * _uiScale, vertical: 14 * _uiScale)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      onGenerateTitle: (context) => AppLocalizations.of(context).catalog,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      theme: _themeData(Brightness.light),
      darkTheme: _themeData(Brightness.dark),
      themeMode: _theme,
      builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(_fontScale)), child: child ?? const SizedBox.shrink()),
      home: _ResponsiveShell(
        theme: _theme,
        colorIndex: _color,
        fontScale: _fontScale,
        uiScale: _uiScale,
        locale: _locale,
        onThemeChanged: _setTheme,
        onColorChanged: _setColor,
        onFontChanged: _setFont,
        onUiChanged: _setUi,
        onLocaleChanged: _setLocale,
      ),
    );
  }
}

class _ResponsiveShell extends StatefulWidget {
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

  const _ResponsiveShell({required this.theme, required this.colorIndex, required this.fontScale, required this.uiScale, required this.locale, required this.onThemeChanged, required this.onColorChanged, required this.onFontChanged, required this.onUiChanged, required this.onLocaleChanged});

  @override
  State<_ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<_ResponsiveShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final info = ResponsiveInfo.of(context);
    final pages = [
      const CatalogPage(),
      const FavoritesPage(),
      const CollectionsPage(),
      _ResponsiveSettings(theme: widget.theme, colorIndex: widget.colorIndex, fontScale: widget.fontScale, uiScale: widget.uiScale, locale: widget.locale, onThemeChanged: widget.onThemeChanged, onColorChanged: widget.onColorChanged, onFontChanged: widget.onFontChanged, onUiChanged: widget.onUiChanged, onLocaleChanged: widget.onLocaleChanged),
    ];
    final items = [
      (Icons.menu_book_outlined, Icons.menu_book, l10n.catalog),
      (Icons.star_border_rounded, Icons.star_rounded, l10n.favorites),
      (Icons.collections_bookmark_outlined, Icons.collections_bookmark, l10n.myCollections),
      (Icons.settings_outlined, Icons.settings, l10n.settings),
    ];

    if (info.useRail) {
      return Scaffold(
        body: Row(children: [
          NavigationRail(selectedIndex: index, onDestinationSelected: (value) => setState(() => index = value), labelType: NavigationRailLabelType.all, groupAlignment: -.85, destinations: [for (final item in items) NavigationRailDestination(icon: Icon(item.$1), selectedIcon: Icon(item.$2), label: Text(item.$3))]),
          const VerticalDivider(width: 1),
          Expanded(child: IndexedStack(index: index, children: pages)),
        ]),
      );
    }

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(selectedIndex: index, onDestinationSelected: (value) => setState(() => index = value), destinations: [for (final item in items) NavigationDestination(icon: Icon(item.$1), selectedIcon: Icon(item.$2), label: item.$3)]),
    );
  }
}

class _ResponsiveSettings extends StatelessWidget {
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

  const _ResponsiveSettings({required this.theme, required this.colorIndex, required this.fontScale, required this.uiScale, required this.locale, required this.onThemeChanged, required this.onColorChanged, required this.onFontChanged, required this.onUiChanged, required this.onLocaleChanged});

  String _text(BuildContext context, String ru, String en, String de, String fr, String es, String it, String pt, String zh, String ja, String ko, String ar) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'ru': return ru; case 'de': return de; case 'fr': return fr; case 'es': return es; case 'it': return it; case 'pt': return pt; case 'zh': return zh; case 'ja': return ja; case 'ko': return ko; case 'ar': return ar; default: return en;
    }
  }

  String _size(BuildContext context, double value) {
    if (value < .8125) return _text(context, 'Очень маленький', 'Very small', 'Sehr klein', 'Très petit', 'Muy pequeño', 'Molto piccolo', 'Muito pequeno', '极小', '極小', '매우 작게', 'صغير جدًا');
    if (value < .9375) return _text(context, 'Маленький', 'Small', 'Klein', 'Petit', 'Pequeño', 'Piccolo', 'Pequeno', '小', '小', '작게', 'صغير');
    if (value < 1.0625) return _text(context, 'Средний', 'Medium', 'Mittel', 'Moyen', 'Medio', 'Medio', 'Médio', '中', '中', '중간', 'متوسط');
    if (value < 1.1875) return _text(context, 'Большой', 'Large', 'Groß', 'Grand', 'Grande', 'Grande', 'Grande', '大', '大', '크게', 'كبير');
    return _text(context, 'Очень большой', 'Very large', 'Sehr groß', 'Très grand', 'Muy grande', 'Molto grande', 'Muito grande', '极大', '極大', '매우 크게', 'كبير جدًا');
  }

  String _themeName(BuildContext context, ThemeMode value) => switch (value) {
    ThemeMode.system => _text(context, 'Системная', 'System', 'System', 'Système', 'Sistema', 'Sistema', 'Sistema', '系统', 'システム', '시스템', 'النظام'),
    ThemeMode.light => _text(context, 'Светлая', 'Light', 'Hell', 'Clair', 'Claro', 'Chiaro', 'Claro', '浅色', 'ライト', '라이트', 'فاتح'),
    ThemeMode.dark => _text(context, 'Тёмная', 'Dark', 'Dunkel', 'Sombre', 'Oscuro', 'Scuro', 'Escuro', '深色', 'ダーク', '다크', 'داكن'),
  };

  String _colorName(BuildContext context, int index) {
    const names = [
      ['Индиго', 'Indigo', 'Indigo', 'Indigo', 'Índigo', 'Indaco', 'Índigo', '靛蓝', 'インディゴ', '인디고', 'نيلي'],
      ['Бирюзовый', 'Teal', 'Türkis', 'Sarcelle', 'Verde azulado', 'Verde acqua', 'Verde-azulado', '蓝绿', 'ティール', '청록', 'أزرق مخضر'],
      ['Фиолетовый', 'Purple', 'Violett', 'Violet', 'Morado', 'Viola', 'Roxo', '紫色', '紫', '보라', 'بنفسجي'],
      ['Оранжевый', 'Orange', 'Orange', 'Orange', 'Naranja', 'Arancione', 'Laranja', '橙色', 'オレンジ', '주황', 'برتقالي'],
      ['Зелёный', 'Green', 'Grün', 'Vert', 'Verde', 'Verde', 'Verde', '绿色', '緑', '초록', 'أخضر'],
    ];
    final lang = Localizations.localeOf(context).languageCode;
    final i = switch (lang) { 'ru' => 0, 'de' => 2, 'fr' => 3, 'es' => 4, 'it' => 5, 'pt' => 6, 'zh' => 7, 'ja' => 8, 'ko' => 9, 'ar' => 10, _ => 1 };
    return names[index][i];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final info = ResponsiveInfo.of(context);
    final downloads = _text(context, 'Загрузки', 'Downloads', 'Downloads', 'Téléchargements', 'Descargas', 'Download', 'Transferências', '下载', 'ダウンロード', '다운로드', 'التنزيلات');
    final downloadDescription = _text(context, 'Очередь загрузки каталогов', 'Catalog download queue', 'Katalog-Warteschlange', 'File de téléchargement', 'Cola de descargas', 'Coda download cataloghi', 'Fila de transferências', '目录下载队列', 'カタログのダウンロード待ち', '카탈로그 다운로드 대기열', 'قائمة تنزيل الفهارس');
    final themeLabel = _text(context, 'Тема', 'Theme', 'Thema', 'Thème', 'Tema', 'Tema', 'Tema', '主题', 'テーマ', '테마', 'السمة');
    final colorLabel = _text(context, 'Цветовая схема', 'Color scheme', 'Farbschema', 'Couleurs', 'Esquema de color', 'Schema colori', 'Esquema de cores', '配色', '配色', '색상', 'نظام الألوان');
    final fontLabel = _text(context, 'Размер шрифта', 'Font size', 'Schriftgröße', 'Taille du texte', 'Tamaño de fuente', 'Dimensione carattere', 'Tamanho da fonte', '字体大小', 'フォントサイズ', '글자 크기', 'حجم الخط');
    final uiLabel = _text(context, 'Размер интерфейса', 'Interface size', 'Oberflächengröße', 'Taille de l’interface', 'Tamaño de interfaz', 'Dimensione interfaccia', 'Tamanho da interface', '界面大小', 'インターフェースサイズ', '인터페이스 크기', 'حجم الواجهة');
    final feedback = _text(context, 'Обратная связь', 'Feedback', 'Feedback', 'Commentaires', 'Comentarios', 'Feedback', 'Feedback', '反馈', 'フィードバック', '피드백', 'ملاحظات');
    final feedbackDescription = _text(context, 'Предложения по изменению каталогов', 'Suggest catalog changes', 'Katalogänderungen vorschlagen', 'Proposer des changements', 'Sugerir cambios', 'Proponi modifiche', 'Sugerir alterações', '建议修改目录', 'カタログ変更を提案', '카탈로그 변경 제안', 'اقتراح تغييرات الفهرس');
    final about = _text(context, 'О приложении', 'About', 'Über', 'À propos', 'Acerca de', 'Informazioni', 'Sobre', '关于', 'アプリについて', '정보', 'حول التطبيق');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ResponsiveContent(
        child: ListView(shrinkWrap: true, children: [
          Card(child: ListTile(leading: const Icon(Icons.translate_rounded), title: Text(l10n.language), subtitle: Text(locale == null ? l10n.languageSystem : AppLocalizations(locale!).languageName), trailing: const Icon(Icons.chevron_right), onTap: () => _languages(context))),
          SizedBox(height: info.spacing(10)),
          Card(child: ListTile(leading: const Icon(Icons.admin_panel_settings_outlined), title: Text(l10n.chooseCatalog), subtitle: Text(l10n.catalogDescription), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CatalogAdminPage())))),
          Card(child: ListTile(leading: const Icon(Icons.download_outlined), title: Text(downloads), subtitle: Text(downloadDescription), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DownloadsPage())))),
          SizedBox(height: info.spacing(10)),
          Card(child: ListTile(leading: const Icon(Icons.palette_outlined), title: Text(themeLabel), subtitle: Text(_themeName(context, theme)), onTap: () => _themes(context))),
          Card(child: ListTile(leading: const Icon(Icons.color_lens_outlined), title: Text(colorLabel), subtitle: Text(_colorName(context, colorIndex)), onTap: () => _colors(context))),
          Card(child: ListTile(leading: const Icon(Icons.text_fields_outlined), title: Text(fontLabel), subtitle: Text(_size(context, fontScale)), onTap: () => _scaleSheet(context, true))),
          Card(child: ListTile(leading: const Icon(Icons.view_agenda_outlined), title: Text(uiLabel), subtitle: Text(_size(context, uiScale)), onTap: () => _scaleSheet(context, false))),
          SizedBox(height: info.spacing(10)),
          Card(child: ListTile(leading: const Icon(Icons.feedback_outlined), title: Text(feedback), subtitle: Text(feedbackDescription), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FeedbackPage())))),
          Card(child: ListTile(leading: const Icon(Icons.help_outline), title: Text(about), subtitle: Text(l10n.catalogDescription), onTap: () => showAboutDialog(context: context, applicationName: 'Collection Catalog', applicationVersion: '1.0.0'))),
        ]),
      ),
    );
  }

  Future<void> _languages(BuildContext context) async {
    final result = await showModalBottomSheet<String>(context: context, builder: (sheet) => SafeArea(child: ListView(shrinkWrap: true, children: [
      ListTile(leading: Icon(locale == null ? Icons.radio_button_checked : Icons.radio_button_unchecked), title: Text(AppLocalizations.of(context).languageSystem), onTap: () => Navigator.pop(sheet, '__system__')),
      ...AppLocalizations.supportedLocales.map((item) => ListTile(leading: Icon(locale?.languageCode == item.languageCode ? Icons.radio_button_checked : Icons.radio_button_unchecked), title: Text(AppLocalizations(item).languageName), onTap: () => Navigator.pop(sheet, item.languageCode))),
    ])));
    if (!context.mounted || result == null) return;
    onLocaleChanged(result == '__system__' ? null : Locale(result));
  }

  Future<void> _themes(BuildContext context) async {
    final value = await showModalBottomSheet<ThemeMode>(context: context, builder: (sheet) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: ThemeMode.values.map((item) => ListTile(title: Text(_themeName(context, item)), selected: item == theme, onTap: () => Navigator.pop(sheet, item))).toList())));
    if (value != null) onThemeChanged(value);
  }

  Future<void> _colors(BuildContext context) async {
    final value = await showModalBottomSheet<int>(context: context, builder: (sheet) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: List.generate(5, (i) => ListTile(leading: CircleAvatar(backgroundColor: _ResponsiveCollectionAppState.colors[i]), title: Text(_colorName(context, i)), selected: i == colorIndex, onTap: () => Navigator.pop(sheet, i))))));
    if (value != null) onColorChanged(value);
  }

  Future<void> _scaleSheet(BuildContext context, bool font) async {
    final current = font ? fontScale : uiScale;
    final values = font ? const [.75, .875, 1.0, 1.125, 1.25] : const [.70, .85, 1.0, 1.15, 1.30];
    final value = await showModalBottomSheet<double>(context: context, builder: (sheet) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: values.map((item) => ListTile(leading: Icon((item - current).abs() < .01 ? Icons.radio_button_checked : Icons.radio_button_unchecked), title: Text(_size(context, item)), subtitle: Text('${(item * 100).round()}%'), onTap: () => Navigator.pop(sheet, item))).toList())));
    if (value == null) return;
    if (font) onFontChanged(value); else onUiChanged(value);
  }
}
