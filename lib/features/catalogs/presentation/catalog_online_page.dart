import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/settings/ui_layout_settings.dart';
import '../data/favorites_store.dart';
import '../domain/entities/catalog_definition.dart';
import '../domain/entities/catalog_entry_definition.dart';
import 'catalog_entry_detail_page.dart';

class CatalogOnlinePage extends StatefulWidget {
  final CatalogDefinition catalog;
  final Future<void> Function()? onDownload;
  final List<String> sectionPath;

  const CatalogOnlinePage({super.key, required this.catalog, this.onDownload, this.sectionPath = const []});

  @override
  State<CatalogOnlinePage> createState() => _CatalogOnlinePageState();
}

class _CatalogOnlinePageState extends State<CatalogOnlinePage> {
  bool _favorite = false;
  Set<String> _favoriteSections = <String>{};
  String? _sortField;
  final bool _descending = false;
  String _coinGroupField = 'denomination';
  VoidCallback? _layoutListener;
  late final Map<String, int> _sectionCounts = _buildSectionCounts();

  bool get _isSyntheticGroup => widget.sectionPath.isNotEmpty && widget.sectionPath.first == '__group__';
  bool get _isCoinGroup => widget.sectionPath.isNotEmpty && widget.sectionPath.first == '__coin_group__';
  bool get _regularCoins => widget.catalog.id == 'coins' && widget.sectionPath.join('/') == 'countries/russia/regular';

  CatalogSectionDefinition? get _currentSection {
    if (widget.sectionPath.isEmpty || _isSyntheticGroup || _isCoinGroup) return null;
    Iterable<CatalogSectionDefinition> sections = widget.catalog.sections;
    CatalogSectionDefinition? current;
    for (final id in widget.sectionPath) {
      current = sections.where((section) => section.id == id).firstOrNull;
      if (current == null) return null;
      sections = current.children;
    }
    return current;
  }

  List<CatalogSectionDefinition> get _sections {
    if (_isSyntheticGroup || _isCoinGroup) return const [];
    final source = widget.sectionPath.isEmpty ? widget.catalog.sections : (_currentSection?.children ?? const <CatalogSectionDefinition>[]);
    // Для нумизматики техническая папка «Страны» не является уровнем каталога.
    // На первом экране сразу показываем её содержимое.
    if (widget.catalog.id == 'coins' && widget.sectionPath.isEmpty) {
      final countries = source.where((section) => section.id == 'countries').firstOrNull;
      if (countries != null && countries.children.isNotEmpty) return countries.children;
    }
    return source.toList();
  }

  @override
  void initState() {
    super.initState();
    _favorite = FavoritesStore.isFavorite(widget.catalog.id);
    _favoriteSections = FavoritesStore.sectionsFor(widget.catalog.id);
    _layoutListener = () {
      if (mounted) setState(() {});
    };
    UiLayoutSettings.revision.addListener(_layoutListener!);
  }

  @override
  void dispose() {
    if (_layoutListener != null) UiLayoutSettings.revision.removeListener(_layoutListener!);
    super.dispose();
  }

  Map<String, int> _buildSectionCounts() => <String, int>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.catalog.name)),
      body: const SizedBox.shrink(),
    );
  }
}
