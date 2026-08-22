import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../data/catalog_version_store.dart';
import '../data/favorites_store.dart';
import '../domain/entities/catalog_definition.dart';
import '../domain/entities/catalog_entry_definition.dart';
import '../domain/entities/catalog_section_definition.dart';

class CatalogOnlinePage extends StatefulWidget {
  final CatalogDefinition catalog;
  final Future<void> Function()? onDownload;
  final List<String> sectionPath;

  const CatalogOnlinePage({
    super.key,
    required this.catalog,
    this.onDownload,
    this.sectionPath = const [],
  });

  @override
  State<CatalogOnlinePage> createState() => _CatalogOnlinePageState();
}

class _CatalogOnlinePageState extends State<CatalogOnlinePage> {
  bool _favorite = false;
  Set<String> _favoriteSections = <String>{};
  String? _sortField;
  bool _descending = false;

  bool get _regularCoins =>
      widget.catalog.id == 'coins' &&
      widget.sectionPath.length == 3 &&
      widget.sectionPath[0] == 'countries' &&
      widget.sectionPath[1] == 'russia' &&
      widget.sectionPath[2] == 'regular';

  CatalogSectionDefinition? get _currentSection {
    if (widget.sectionPath.isEmpty) return null;
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
    if (widget.sectionPath.isEmpty) return widget.catalog.sections;
    return _currentSection?.children ?? const <CatalogSectionDefinition>[];
  }

  List<CatalogEntryDefinition> get _entries {
    if (widget.sectionPath.isEmpty) return widget.catalog.entries;
    return widget.catalog.entries.where((entry) {
      if (entry.sectionPath.length < widget.sectionPath.length) return false;
      for (var index = 0; index < widget.sectionPath.length; index++) {
        if (entry.sectionPath[index] != widget.sectionPath[index]) return false;
      }
      return true;
    }).toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    if (_regularCoins) _sortField = 'year';
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final keys = await FavoritesStore.loadKeys();
    final catalogFavorite = keys.contains(FavoritesStore.catalogKey(widget.catalog.id));
    final sectionFavorites = keys.where((key) => key.startsWith('section:')).map((key) => key.substring('section:'.length)).toSet();
    if (!mounted) return;
    setState(() {
      _favorite = catalogFavorite;
      _favoriteSections = sectionFavorites;
    });
  }

  Future<void> _toggleCatalogFavorite() async {
    final keys = await FavoritesStore.toggle(widget.catalog.id);
    if (!mounted) return;
    setState(() => _favorite = keys.contains(FavoritesStore.catalogKey(widget.catalog.id)));
  }

  Future<void> _toggleSectionFavorite(String id) async {
    final keys = await FavoritesStore.toggleKey(FavoritesStore.sectionKey(id));
    if (!mounted) return;
    setState(() {
      _favoriteSections = keys.where((key) => key.startsWith('section:')).map((key) => key.substring('section:'.length)).toSet();
    });
  }

  List<CatalogEntryDefinition> _sortedEntries() {
    final result = <CatalogEntryDefinition>[..._entries];
    if (!_regularCoins || _sortField == null) return result;
    result.sort((a, b) {
      final aValue = a.attributes[_sortField!] ?? a.primaryValue;
      final bValue = b.attributes[_sortField!] ?? b.primaryValue;
      final aNumber = double.tryParse(aValue.replaceAll(',', '.'));
      final bNumber = double.tryParse(bValue.replaceAll(',', '.'));
      final comparison = aNumber != null && bNumber != null
          ? aNumber.compareTo(bNumber)
          : aValue.toLowerCase().compareTo(bValue.toLowerCase());
      return _descending ? -comparison : comparison;
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = _currentSection?.name ?? l10n.catalogName(widget.catalog.id);
    final entries = _sortedEntries();
    final showEntries = widget.sectionPath.isNotEmpty || widget.catalog.sections.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: l10n.favorites,
            onPressed: _toggleCatalogFavorite,
            icon: Icon(_favorite ? Icons.star_rounded : Icons.star_border_rounded),
          ),
          if (_regularCoins)
            PopupMenuButton<String>(
              tooltip: 'Сортировка',
              onSelected: (value) {
                if (value == 'reverse') {
                  setState(() => _descending = !_descending);
                } else {
                  setState(() => _sortField = value);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(value: 'year', child: Text('По году')),
                PopupMenuItem<String>(value: 'series', child: Text('По серии')),
                PopupMenuItem<String>(value: 'rarity', child: Text('По редкости')),
                PopupMenuItem<String>(value: 'reverse', child: Text('Изменить порядок')),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final section in _sections)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.folder_outlined)),
                title: Text(section.name),
                subtitle: Text(section.children.isEmpty ? '${_count(section)} записей' : '${section.children.length} подразделов'),
                trailing: IconButton(
                  onPressed: () => _toggleSectionFavorite(section.id),
                  icon: Icon(_favoriteSections.contains(section.id) ? Icons.star_rounded : Icons.star_border_rounded),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CatalogOnlinePage(
                        catalog: widget.catalog,
                        onDownload: widget.onDownload,
                        sectionPath: [...widget.sectionPath, section.id],
                      ),
                    ),
                  );
                },
              ),
            ),
          if (showEntries) ...[
            const SizedBox(height: 8),
            for (final entry in entries)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(entry.title),
                  subtitle: Text('${entry.primaryValue} · ${entry.subtitle}'),
                ),
              ),
            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Записи не найдены', textAlign: TextAlign.center),
              ),
          ],
        ],
      ),
      bottomNavigationBar: widget.onDownload == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: () async {
                    await widget.onDownload!.call();
                    await CatalogVersionStore.markInstalled(widget.catalog.id, widget.catalog.version);
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: Text(l10n.download),
                ),
              ),
            ),
    );
  }

  int _count(CatalogSectionDefinition section) {
    final path = [...widget.sectionPath, section.id];
    return widget.catalog.entries.where((entry) {
      if (entry.sectionPath.length < path.length) return false;
      for (var index = 0; index < path.length; index++) {
        if (entry.sectionPath[index] != path[index]) return false;
      }
      return true;
    }).length;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
