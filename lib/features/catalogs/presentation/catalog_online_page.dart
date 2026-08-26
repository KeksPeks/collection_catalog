import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/settings/ui_layout_settings.dart';
import '../data/favorites_store.dart';
import '../domain/entities/catalog_definition.dart';
import '../domain/entities/catalog_entry_definition.dart';
import 'catalog_entry_detail_page.dart';

/// Страница каталога с локальной многоуровневой навигацией.
///
/// Группировка строится непосредственно из данных каталога, поэтому один и
/// тот же механизм работает для монет, LEGO, карточек, игр и других наборов.
class CatalogOnlinePage extends StatefulWidget {
  final CatalogDefinition catalog;
  final Future<void> Function()? onDownload;
  final List<String> sectionPath;

  const CatalogOnlinePage({super.key, required this.catalog, this.onDownload, this.sectionPath = const []});

  @override
  State<CatalogOnlinePage> createState() => _CatalogOnlinePageState();
}

class _CatalogOnlinePageState extends State<CatalogOnlinePage> {
  static const _dynamicPrefix = '__dynamic__';
  bool _favorite = false;
  Set<String> _favoriteSections = <String>{};
  String? _sortField;
  bool _descending = false;
  VoidCallback? _layoutListener;

  List<List<String>> get _groupingPresets {
    final id = widget.catalog.id;
    if (id == 'coins') {
      return const [
        ['country', 'year'],
        ['country'],
        ['denomination'],
        [],
      ];
    }
    if (id == 'lego') {
      return const [
        ['series', 'year'],
        ['year'],
        ['series'],
        [],
      ];
    }
    final hasYear = widget.catalog.entries.any((entry) => _value(entry, 'year').isNotEmpty);
    final primary = widget.catalog.primaryField;
    final result = <List<String>>[];
    if (primary.isNotEmpty && hasYear) result.add([primary, 'year']);
    if (primary.isNotEmpty) result.add([primary]);
    if (hasYear) result.add(['year']);
    result.add(const []);
    return result;
  }

  List<String> get _groupingFields {
    if (widget.sectionPath.isEmpty || widget.sectionPath.first != _dynamicPrefix) return _groupingPresets.first;
    final values = widget.sectionPath.skip(1).toList();
    final depth = values.length ~/ 2;
    return depth >= _groupingPresets.first.length ? const [] : _groupingPresets.first;
  }

  bool get _isDynamic => _groupingFields.isNotEmpty;

  List<(String, String)> get _selectedFilters {
    if (!_isDynamic || widget.sectionPath.length < 3) return const [];
    final result = <(String, String)>[];
    final values = widget.sectionPath.skip(1).toList();
    for (var i = 0; i + 1 < values.length; i += 2) {
      result.add((values[i], values[i + 1]));
    }
    return result;
  }

  String get _title {
    if (_isDynamic && _selectedFilters.isNotEmpty) return _selectedFilters.last.$2;
    return AppLocalizations.of(context).catalogName(widget.catalog.id);
  }

  String _value(CatalogEntryDefinition entry, String field) {
    const aliases = <String, List<String>>{
      'country': ['Страна', 'country', 'Country'],
      'year': ['Год', 'year', 'Year'],
      'denomination': ['Номинал', 'denomination', 'Denomination'],
      'series': ['Серия', 'series', 'Series'],
      'rarity': ['Редкость', 'rarity', 'Rarity'],
      'platform': ['Платформа', 'platform', 'Platform'],
      'title': ['Название', 'title', 'Title'],
    };
    final keys = aliases[field] ?? [field];
    for (final key in keys) {
      final value = entry.attributes[key];
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    if (field == widget.catalog.primaryField) return entry.primaryValue;
    return '';
  }

  List<CatalogEntryDefinition> get _entries {
    if (!_isDynamic) return widget.catalog.entries;
    return widget.catalog.entries.where((entry) {
      for (final filter in _selectedFilters) {
        if (_value(entry, filter.$1) != filter.$2) return false;
      }
      return true;
    }).toList(growable: false);
  }

  List<_EntryGroup> get _groups {
    if (!_isDynamic) return const [];
    final depth = _selectedFilters.length;
    if (depth >= _groupingFields.length) return const [];
    final field = _groupingFields[depth];
    final groups = <String, List<CatalogEntryDefinition>>{};
    for (final entry in _entries) {
      final value = _value(entry, field);
      if (value.isEmpty) continue;
      groups.putIfAbsent(value, () => <CatalogEntryDefinition>[]).add(entry);
    }
    final result = groups.entries.map((item) => _EntryGroup(name: item.key, entries: item.value, field: field)).toList(growable: false);
    result.sort((a, b) => _compareValues(a.name, b.name, field));
    return result;
  }

  List<CatalogEntryDefinition> _sortedEntries() {
    final result = <CatalogEntryDefinition>[..._entries];
    if (_sortField == null) return result;
    result.sort((a, b) {
      final comparison = _compareValues(_value(a, _sortField!), _value(b, _sortField!), _sortField!);
      return _descending ? -comparison : comparison;
    });
    return result;
  }

  int _compareValues(String a, String b, String field) {
    final aNumber = double.tryParse(a.replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.\-]'), ''));
    final bNumber = double.tryParse(b.replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.\-]'), ''));
    if (aNumber != null && bNumber != null) return aNumber.compareTo(bNumber);
    return a.toLowerCase().compareTo(b.toLowerCase());
  }

  List<String> get _sortFields {
    const preferred = ['year', 'denomination', 'series', 'rarity', 'platform', 'title'];
    return preferred.where((field) => widget.catalog.entries.any((entry) => _value(entry, field).isNotEmpty)).toList(growable: false);
  }

  String _fieldName(String field) {
    const names = <String, String>{'country': 'Страна', 'year': 'Год', 'denomination': 'Номинал', 'series': 'Серия', 'rarity': 'Редкость', 'platform': 'Платформа', 'title': 'Название'};
    return names[field] ?? field;
  }

  String _groupingName(List<String> fields) {
    if (fields.isEmpty) return 'Показать все';
    return fields.map(_fieldName).join(' → ');
  }

  @override
  void initState() {
    super.initState();
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

  void _selectGrouping(List<String> fields) {
    final target = fields.isEmpty ? const <String>[] : fields;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => CatalogOnlinePage(catalog: widget.catalog, onDownload: widget.onDownload, sectionPath: target.isEmpty ? const [] : [_dynamicPrefix, ...target.map((field) => '__field__$field')])));
  }

  void _pushGroup(_EntryGroup group) {
    final path = <String>[_dynamicPrefix];
    for (final filter in _selectedFilters) {
      path..add(filter.$1)..add(filter.$2);
    }
    path..add(group.field)..add(group.name);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => CatalogOnlinePage(catalog: widget.catalog, onDownload: widget.onDownload, sectionPath: path)));
  }

  List<(String, String)> _filtersFromPath() {
    if (widget.sectionPath.isEmpty || widget.sectionPath.first != _dynamicPrefix) return const [];
    final raw = widget.sectionPath.skip(1).toList();
    final fields = _groupingPresets.first;
    final filters = <(String, String)>[];
    for (var i = 0; i + 1 < raw.length; i += 2) {
      if (raw[i].startsWith('__field__')) continue;
      if (fields.contains(raw[i])) filters.add((raw[i], raw[i + 1]));
    }
    return filters;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filters = _filtersFromPath();
    final activeFields = widget.sectionPath.isNotEmpty && widget.sectionPath.first == _dynamicPrefix ? _groupingFields : const <String>[];
    final depth = filters.length;
    final groups = _groups;
    final entries = _sortedEntries();
    final showEntries = activeFields.isEmpty || depth >= activeFields.length || groups.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(_title, maxLines: 2, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(tooltip: l10n.favorites, onPressed: _toggleCatalogFavorite, icon: Icon(_favorite ? Icons.star_rounded : Icons.star_border_rounded)),
          if (_groupingPresets.length > 1)
            PopupMenuButton<int>(
              tooltip: 'Группировка',
              onSelected: (index) => _selectGrouping(_groupingPresets[index]),
              itemBuilder: (_) => [
                for (var i = 0; i < _groupingPresets.length; i++) PopupMenuItem<int>(value: i, child: Text(_groupingName(_groupingPresets[i]))),
              ],
            ),
          if (_sortFields.isNotEmpty)
            PopupMenuButton<String>(
              tooltip: 'Сортировка',
              onSelected: (value) => setState(() => value == '__reverse__' ? _descending = !_descending : _sortField = value),
              itemBuilder: (_) => [
                for (final field in _sortFields) PopupMenuItem<String>(value: field, child: Text('По ${_fieldName(field).toLowerCase()}')),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(value: '__reverse__', child: Text('Изменить порядок')),
              ],
            ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: (showEntries ? entries.length : groups.length) + (showEntries && entries.isEmpty ? 1 : 0),
        itemBuilder: (context, index) {
          if (!showEntries) {
            final group = groups[index];
            final key = 'dynamic:${widget.catalog.id}:${group.field}:${group.name}';
            return _GroupCard(group: group, favorite: _favoriteSections.contains(key), onFavorite: () => _toggleSectionFavorite(key), onTap: () => _pushGroup(group));
          }
          if (entries.isEmpty) return const Padding(padding: EdgeInsets.all(24), child: Text('Записи не найдены', textAlign: TextAlign.center));
          final entry = entries[index];
          return _CatalogEntryCard(entry: entry, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CatalogEntryDetailPage(catalog: widget.catalog, entry: entry))));
        },
      ),
      bottomNavigationBar: widget.onDownload == null ? null : SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: FilledButton.icon(onPressed: () async { await widget.onDownload!.call(); if (mounted) Navigator.of(context).pop(); }, icon: const Icon(Icons.download_rounded), label: Text(l10n.download)))),
    );
  }
}

class _EntryGroup {
  final String name;
  final List<CatalogEntryDefinition> entries;
  final String field;
  const _EntryGroup({required this.name, required this.entries, required this.field});
}

class _GroupCard extends StatelessWidget {
  final _EntryGroup group;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;
  const _GroupCard({required this.group, required this.favorite, required this.onFavorite, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 10), clipBehavior: Clip.antiAlias, child: InkWell(onTap: onTap, child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), leading: const CircleAvatar(child: Icon(Icons.folder_outlined)), title: Text(group.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), subtitle: Text('${group.entries.length} записей'), trailing: IconButton(onPressed: onFavorite, tooltip: 'Избранное', icon: Icon(favorite ? Icons.star_rounded : Icons.star_border_rounded)))));
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
