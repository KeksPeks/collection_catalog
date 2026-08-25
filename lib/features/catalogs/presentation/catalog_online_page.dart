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
  bool _descending = false;
  VoidCallback? _layoutListener;
  late final Map<String, int> _sectionCounts = _buildSectionCounts();

  bool get _isSyntheticGroup => widget.sectionPath.isNotEmpty && widget.sectionPath.first == '__group__';
  bool get _regularCoins => widget.catalog.id == 'coins' && widget.sectionPath.join('/') == 'countries/russia/regular';

  CatalogSectionDefinition? get _currentSection {
    if (widget.sectionPath.isEmpty || _isSyntheticGroup) return null;
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
    if (_isSyntheticGroup) return const [];
    return widget.sectionPath.isEmpty ? widget.catalog.sections : _currentSection?.children ?? const <CatalogSectionDefinition>[];
  }

  List<_EntryGroup> get _groups {
    if (widget.catalog.entries.isEmpty || widget.catalog.sections.isNotEmpty || widget.sectionPath.isNotEmpty) return const [];
    final field = widget.catalog.primaryField;
    final groups = <String, List<CatalogEntryDefinition>>{};
    for (final entry in widget.catalog.entries) {
      final key = entry.attributes[field] ?? entry.primaryValue;
      groups.putIfAbsent(key.isEmpty ? 'Без категории' : key, () => <CatalogEntryDefinition>[]).add(entry);
    }
    return groups.entries.map((item) => _EntryGroup(name: item.key, entries: item.value)).toList(growable: false);
  }

  List<CatalogEntryDefinition> get _entries {
    if (widget.sectionPath.isEmpty) return widget.catalog.entries;
    if (_isSyntheticGroup) {
      final group = widget.sectionPath.length > 1 ? widget.sectionPath[1] : '';
      final field = widget.catalog.primaryField;
      return widget.catalog.entries.where((entry) => (entry.attributes[field] ?? entry.primaryValue) == group).toList(growable: false);
    }
    return widget.catalog.entries.where((entry) {
      if (entry.sectionPath.length < widget.sectionPath.length) return false;
      for (var index = 0; index < widget.sectionPath.length; index++) {
        if (entry.sectionPath[index] != widget.sectionPath[index]) return false;
      }
      return true;
    }).toList(growable: false);
  }

  Map<String, int> _buildSectionCounts() {
    final counts = <String, int>{};
    for (final entry in widget.catalog.entries) {
      for (var length = 1; length <= entry.sectionPath.length; length++) {
        final key = entry.sectionPath.take(length).join('/');
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }
    return counts;
  }

  @override
  void initState() {
    super.initState();
    if (_regularCoins) _sortField = 'year';
    _layoutListener = () { if (mounted) setState(() {}); };
    UiLayoutSettings.revision.addListener(_layoutListener!);
    UiLayoutSettings.ensureLoaded();
    _loadFavorites();
  }

  @override
  void dispose() {
    final listener = _layoutListener;
    if (listener != null) UiLayoutSettings.revision.removeListener(listener);
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final keys = await FavoritesStore.loadKeys();
    if (!mounted) return;
    setState(() {
      _favorite = keys.contains(FavoritesStore.catalogKey(widget.catalog.id));
      _favoriteSections = keys.where((key) => key.startsWith('section:')).map((key) => key.substring('section:'.length)).toSet();
    });
  }

  Future<void> _toggleCatalogFavorite() async {
    final keys = await FavoritesStore.toggle(widget.catalog.id);
    if (mounted) setState(() => _favorite = keys.contains(FavoritesStore.catalogKey(widget.catalog.id)));
  }

  Future<void> _toggleSectionFavorite(String id) async {
    final keys = await FavoritesStore.toggleKey(FavoritesStore.sectionKey(id));
    if (mounted) setState(() => _favoriteSections = keys.where((key) => key.startsWith('section:')).map((key) => key.substring('section:'.length)).toSet());
  }

  List<CatalogEntryDefinition> _sortedEntries() {
    final result = <CatalogEntryDefinition>[..._entries];
    if (!_regularCoins || _sortField == null) return result;
    result.sort((a, b) {
      final aValue = a.attributes[_sortField!] ?? a.primaryValue;
      final bValue = b.attributes[_sortField!] ?? b.primaryValue;
      final aNumber = double.tryParse(aValue.replaceAll(',', '.'));
      final bNumber = double.tryParse(bValue.replaceAll(',', '.'));
      final comparison = aNumber != null && bNumber != null ? aNumber.compareTo(bNumber) : aValue.toLowerCase().compareTo(bValue.toLowerCase());
      return _descending ? -comparison : comparison;
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = _isSyntheticGroup ? widget.sectionPath[1] : _currentSection?.name ?? l10n.catalogName(widget.catalog.id);
    final entries = _sortedEntries();
    final sections = _sections;
    final groups = _groups;
    final showEntries = widget.sectionPath.isNotEmpty && sections.isEmpty || (widget.sectionPath.isEmpty && widget.catalog.sections.isEmpty && groups.isEmpty);
    final empty = sections.isEmpty && groups.isEmpty && !showEntries;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(tooltip: l10n.favorites, onPressed: _toggleCatalogFavorite, icon: Icon(_favorite ? Icons.star_rounded : Icons.star_border_rounded)),
          if (_regularCoins)
            PopupMenuButton<String>(
              tooltip: 'Сортировка',
              onSelected: (value) => setState(() => value == 'reverse' ? _descending = !_descending : _sortField = value),
              itemBuilder: (context) => const [
                PopupMenuItem<String>(value: 'year', child: Text('По году')),
                PopupMenuItem<String>(value: 'series', child: Text('По серии')),
                PopupMenuItem<String>(value: 'rarity', child: Text('По редкости')),
                PopupMenuItem<String>(value: 'reverse', child: Text('Изменить порядок')),
              ],
            ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sections.length + groups.length + (showEntries ? entries.length : 0) + (empty ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < sections.length) {
            final section = sections[index];
            return _SectionCard(section: section, count: _count(section), favorite: _favoriteSections.contains(section.id), onFavorite: () => _toggleSectionFavorite(section.id), onTap: () => _pushPath([...widget.sectionPath, section.id]));
          }
          final groupIndex = index - sections.length;
          if (groupIndex < groups.length) {
            final group = groups[groupIndex];
            return _GroupCard(group: group, onTap: () => _pushPath(['__group__', group.name]));
          }
          final entryIndex = index - sections.length - groups.length;
          if (showEntries && entryIndex < entries.length) {
            final entry = entries[entryIndex];
            return _CatalogEntryCard(entry: entry, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CatalogEntryDetailPage(catalog: widget.catalog, entry: entry))));
          }
          return const Padding(padding: EdgeInsets.all(24), child: Text('Записи не найдены', textAlign: TextAlign.center));
        },
      ),
      bottomNavigationBar: widget.onDownload == null ? null : SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: FilledButton.icon(onPressed: () async { await widget.onDownload!.call(); if (mounted) Navigator.of(context).pop(); }, icon: const Icon(Icons.download_rounded), label: Text(l10n.download)))),
    );
  }

  void _pushPath(List<String> path) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CatalogOnlinePage(catalog: widget.catalog, onDownload: widget.onDownload, sectionPath: path)));
  int _count(CatalogSectionDefinition section) => _sectionCounts[[...widget.sectionPath, section.id].join('/')] ?? 0;
}

class _EntryGroup {
  final String name;
  final List<CatalogEntryDefinition> entries;
  const _EntryGroup({required this.name, required this.entries});
}

class _GroupCard extends StatelessWidget {
  final _EntryGroup group;
  final VoidCallback onTap;
  const _GroupCard({required this.group, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 10), clipBehavior: Clip.antiAlias, child: InkWell(onTap: onTap, child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), leading: const CircleAvatar(child: Icon(Icons.folder_outlined)), title: Text(group.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), subtitle: Text('${group.entries.length} записей'), trailing: const Icon(Icons.chevron_right_rounded))));
}

class _SectionCard extends StatelessWidget {
  final CatalogSectionDefinition section;
  final int count;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;
  const _SectionCard({required this.section, required this.count, required this.favorite, required this.onFavorite, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 10), clipBehavior: Clip.antiAlias, child: InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
    _CatalogVisual(label: section.name), const SizedBox(width: 12), Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(section.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(section.children.isEmpty ? '$count записей' : '${section.children.length} подразделов', maxLines: 1, overflow: TextOverflow.ellipsis)])),
    IconButton(onPressed: onFavorite, tooltip: 'Избранное', icon: Icon(favorite ? Icons.star_rounded : Icons.star_border_rounded)),
  ]))));
}

class _CatalogEntryCard extends StatelessWidget {
  final CatalogEntryDefinition entry;
  final VoidCallback onTap;
  const _CatalogEntryCard({required this.entry, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 12), clipBehavior: Clip.antiAlias, child: InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.all(12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _CatalogVisual(label: entry.attributes['Страна'] ?? entry.primaryValue, imageUrl: entry.imageUrl, countryCode: entry.countryCode), const SizedBox(width: 12), Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(entry.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text('${entry.primaryValue} · ${entry.subtitle}', maxLines: 2, overflow: TextOverflow.ellipsis)])), const Icon(Icons.chevron_right_rounded),
  ]))));
}

class _CatalogVisual extends StatelessWidget {
  final String label;
  final String? imageUrl;
  final String? countryCode;
  const _CatalogVisual({required this.label, this.imageUrl, this.countryCode});
  @override
  Widget build(BuildContext context) {
    final flag = countryCodeToFlag(countryCode) ?? countryNameToFlag(label);
    final theme = Theme.of(context);
    return SizedBox(width: 86, height: 86, child: ClipRRect(borderRadius: BorderRadius.circular(14), child: flag != null ? ColoredBox(color: theme.colorScheme.surfaceContainerHighest, child: Center(child: Text(flag, style: const TextStyle(fontSize: 42)))) : imageUrl != null && imageUrl!.trim().isNotEmpty ? Image.network(imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const _NoImage()) : const _NoImage()));
  }
}

class _NoImage extends StatelessWidget {
  const _NoImage();
  @override
  Widget build(BuildContext context) => ColoredBox(color: Theme.of(context).colorScheme.surfaceContainerHighest, child: Center(child: Text('NO IMAGES', textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800))));
}

String? countryCodeToFlag(String? code) {
  if (code == null || code.trim().length != 2) return null;
  final normalized = code.trim().toUpperCase();
  final first = normalized.codeUnitAt(0);
  final second = normalized.codeUnitAt(1);
  if (first < 65 || first > 90 || second < 65 || second > 90) return null;
  return String.fromCharCodes([0x1F1E6 + first - 65, 0x1F1E6 + second - 65]);
}

String? countryNameToFlag(String name) {
  const flags = <String, String>{'Россия':'🇷🇺','Германия':'🇩🇪','Италия':'🇮🇹','Франция':'🇫🇷','Испания':'🇪🇸','Португалия':'🇵🇹','Великобритания':'🇬🇧','США':'🇺🇸','Соединенные Штаты':'🇺🇸','Канада':'🇨🇦','Япония':'🇯🇵','Китай':'🇨🇳','Южная Корея':'🇰🇷','Корея':'🇰🇷','Польша':'🇵🇱','Чехия':'🇨🇿','Швейцария':'🇨🇭','Австрия':'🇦🇹','Бельгия':'🇧🇪','Нидерланды':'🇳🇱','Швеция':'🇸🇪','Норвегия':'🇳🇴','Дания':'🇩🇰','Финляндия':'🇫🇮','Эстония':'🇪🇪','Латвия':'🇱🇻','Литва':'🇱🇹','Украина':'🇺🇦','Беларусь':'🇧🇾','Бразилия':'🇧🇷','Мексика':'🇲🇽','Индия':'🇮🇳','Австралия':'🇦🇺'};
  return flags[name.trim()];
}

extension _FirstOrNull<T> on Iterable<T> { T? get firstOrNull => isEmpty ? null : first; }
