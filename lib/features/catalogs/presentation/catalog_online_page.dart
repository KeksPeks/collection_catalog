import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../data/catalog_version_store.dart';
import '../data/favorites_store.dart';
import '../domain/entities/catalog_definition.dart';
import '../domain/entities/catalog_entry_definition.dart';

/// Просмотр централизованного каталога. Пользователь может только смотреть,
/// скачивать и добавлять уровни каталога в избранное.
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
  bool _descending = false;

  bool get _insideSection => widget.sectionPath.isNotEmpty;
  bool get _isRussiaRegularCoins => widget.catalog.id == 'coins' && widget.sectionPath.length == 3 && widget.sectionPath[0] == 'countries' && widget.sectionPath[1] == 'russia' && widget.sectionPath[2] == 'regular';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    if (_isRussiaRegularCoins) _sortField = 'year';
  }

  Future<void> _loadFavorites() async {
    final favorite = await FavoritesStore.contains(widget.catalog.id);
    final all = await FavoritesStore.loadKeys();
    if (!mounted) return;
    setState(() {
      _favorite = favorite;
      _favoriteSections = all.where((key) => key.startsWith('section:')).map((key) => key.substring(8)).toSet();
    });
  }

  Future<void> _toggleCatalogFavorite() async {
    final ids = await FavoritesStore.toggle(widget.catalog.id);
    if (!mounted) return;
    setState(() => _favorite = ids.contains(FavoritesStore.catalogKey(widget.catalog.id)));
  }

  Future<void> _toggleSectionFavorite(String id) async {
    final key = FavoritesStore.sectionKey(id);
    final ids = await FavoritesStore.toggleKey(key);
    if (!mounted) return;
    setState(() => _favoriteSections = ids.where((item) => item.startsWith('section:')).map((item) => item.substring(8)).toSet());
  }

  CatalogSectionDefinition? get _currentSection {
    if (widget.sectionPath.isEmpty) return null;
    CatalogSectionDefinition? current;
    Iterable<CatalogSectionDefinition> candidates = widget.catalog.sections;
    for (final id in widget.sectionPath) {
      current = candidates.where((section) => section.id == id).firstOrNull;
      if (current == null) return null;
      candidates = current.children;
    }
    return current;
  }

  List<CatalogSectionDefinition> get _visibleSections => widget.sectionPath.isEmpty ? widget.catalog.sections : _currentSection?.children ?? const [];

  List<CatalogEntryDefinition> get _visibleEntries {
    if (widget.sectionPath.isEmpty) return widget.catalog.entries;
    return widget.catalog.entries.where((entry) => entry.sectionPath.length >= widget.sectionPath.length && List.generate(widget.sectionPath.length, (i) => entry.sectionPath[i] == widget.sectionPath[i]).every((value) => value)).toList();
  }

  List<String> _sortFields() => _isRussiaRegularCoins ? const ['year', 'series', 'rarity'] : const [];
  String _fieldLabel(String field) => switch (field) { 'year' => 'Год', 'series' => 'Серия', 'rarity' => 'Редкость', _ => field };

  List<CatalogEntryDefinition> _sortedEntries() {
    final entries = [..._visibleEntries];
    if (!_isRussiaRegularCoins || _sortField == null) return entries;
    entries.sort((a, b) {
      final av = a.attributes[_sortField!] ?? a.primaryValue;
      final bv = b.attributes[_sortField!] ?? b.primaryValue;
      final an = int.tryParse(av);
      final bn = int.tryParse(bv);
      final result = an != null && bn != null ? an.compareTo(bn) : av.toLowerCase().compareTo(bv.toLowerCase());
      return _descending ? -result : result;
    });
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = _currentSection?.name ?? l10n.catalogName(widget.catalog.id);
    final sections = _visibleSections;
    final entries = _sortedEntries();
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: [IconButton(onPressed: _toggleCatalogFavorite, icon: Icon(_favorite ? Icons.star_rounded : Icons.star_border_rounded)), if (_isRussiaRegularCoins) PopupMenuButton<String>(onSelected: (value) { if (value == 'reverse') { setState(() => _descending = !_descending); } else { setState(() => _sortField = value); } }, itemBuilder: (_) => [..._sortFields().map((field) => PopupMenuItem(value: field, child: Text('По ${_fieldLabel(field).toLowerCase()}'))), const PopupMenuDivider(), PopupMenuItem(value: 'reverse', child: Text(_descending ? 'Прямой порядок' : 'Обратный порядок'))])]),
      body: CustomScrollView(slivers: [
        SliverPadding(padding: const EdgeInsets.all(16), sliver: SliverToBoxAdapter(child: Card(child: ListTile(leading: const Icon(Icons.inventory_2_outlined), title: Text(title), subtitle: Text('Версия каталога: ${widget.catalog.version}'))))),
        if (sections.isNotEmpty) SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 16), sliver: SliverList.builder(itemCount: sections.length, itemBuilder: (context, index) { final section = sections[index]; final isFavorite = _favoriteSections.contains(section.id); return Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(leading: const CircleAvatar(child: Icon(Icons.folder_outlined)), title: Text(section.name), subtitle: Text(section.children.isEmpty ? '${_countForSection(section)} записей' : '${section.children.length} подразделов'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(onPressed: () => _toggleSectionFavorite(section.id), icon: Icon(isFavorite ? Icons.star_rounded : Icons.star_border_rounded)), const Icon(Icons.chevron_right)]), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CatalogOnlinePage(catalog: widget.catalog, onDownload: widget.onDownload, sectionPath: [...widget.sectionPath, section.id])))); })) ,
        if ((_insideSection || widget.catalog.sections.isEmpty) && entries.isNotEmpty) SliverPadding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), sliver: SliverList.builder(itemCount: entries.length, itemBuilder: (context, index) => Card(child: ListTile(leading: const Icon(Icons.inventory_2_outlined), title: Text(entries[index].title), subtitle: Text('${entries[index].primaryValue} · ${entries[index].subtitle}'))))),
        if ((_insideSection || widget.catalog.sections.isEmpty) && entries.isEmpty) const SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('Записи не найдены'))),
      ]),
      bottomNavigationBar: widget.onDownload == null ? null : SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: FilledButton.icon(onPressed: () async { await widget.onDownload!.call(); await CatalogVersionStore.markInstalled(widget.catalog.id, widget.catalog.version); if (!context.mounted) return; Navigator.of(context).pop(); }, icon: const Icon(Icons.download_rounded), label: Text(l10n.download)))),
    );
  }

  int _countForSection(CatalogSectionDefinition section) {
    final path = [...widget.sectionPath, section.id];
    return widget.catalog.entries.where((entry) => entry.sectionPath.length >= path.length && List.generate(path.length, (i) => entry.sectionPath[i] == path[i]).every((value) => value)).length;
  }
}

extension _FirstOrNull<T> on Iterable<T> { T? get firstOrNull => isEmpty ? null : first; }
