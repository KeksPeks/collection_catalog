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
  static const _dynamic = '__dynamic__';
  static const _config = '__config__';
  static const _all = '__all__';
  bool _favorite = false;
  Set<String> _favoriteSections = <String>{};
  String? _sortField;
  bool _descending = false;
  VoidCallback? _layoutListener;

  List<List<String>> get _groupingPresets {
    if (widget.catalog.id == 'coins') return const [['country', 'year'], ['country'], ['denomination'], []];
    if (widget.catalog.id == 'lego') return const [['series', 'year'], ['year'], ['series'], []];
    final hasYear = widget.catalog.entries.any((e) => _value(e, 'year').isNotEmpty);
    final primary = widget.catalog.primaryField;
    final result = <List<String>>[];
    if (primary.isNotEmpty && hasYear) result.add([primary, 'year']);
    if (primary.isNotEmpty) result.add([primary]);
    if (hasYear) result.add(['year']);
    result.add(const []);
    return result;
  }

  List<String> get _groupingFields {
    if (widget.sectionPath.length >= 3 && widget.sectionPath[0] == _dynamic && widget.sectionPath[1] == _config) {
      if (widget.sectionPath[2] == _all) return const [];
      var end = 2;
      while (end < widget.sectionPath.length && widget.sectionPath[end] != '__filters__') end++;
      return widget.sectionPath.sublist(2, end);
    }
    return _groupingPresets.first;
  }

  List<(String, String)> get _filters {
    if (widget.sectionPath.length < 3 || widget.sectionPath[0] != _dynamic) return const [];
    final marker = widget.sectionPath.indexOf('__filters__');
    if (marker < 0) return const [];
    final raw = widget.sectionPath.sublist(marker + 1);
    final result = <(String, String)>[];
    for (var i = 0; i + 1 < raw.length; i += 2) result.add((raw[i], raw[i + 1]));
    return result;
  }

  bool get _isDynamic => widget.catalog.entries.isNotEmpty && _groupingFields.isNotEmpty;

  String _value(CatalogEntryDefinition entry, String field) {
    const aliases = <String, List<String>>{
      'country': ['Страна', 'country', 'Country'], 'year': ['Год', 'year', 'Year'],
      'denomination': ['Номинал', 'denomination', 'Denomination'], 'series': ['Серия', 'series', 'Series'],
      'rarity': ['Редкость', 'rarity', 'Rarity'], 'platform': ['Платформа', 'platform', 'Platform'],
      'title': ['Название', 'title', 'Title'],
    };
    for (final key in aliases[field] ?? [field]) {
      final value = entry.attributes[key];
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return field == widget.catalog.primaryField ? entry.primaryValue : '';
  }

  List<CatalogEntryDefinition> get _entries {
    if (!_isDynamic) return widget.catalog.entries;
    return widget.catalog.entries.where((entry) => _filters.every((filter) => _value(entry, filter.$1) == filter.$2)).toList(growable: false);
  }

  List<_EntryGroup> get _groups {
    if (!_isDynamic) return const [];
    final depth = _filters.length;
    if (depth >= _groupingFields.length) return const [];
    final field = _groupingFields[depth];
    final map = <String, List<CatalogEntryDefinition>>{};
    for (final entry in _entries) {
      final value = _value(entry, field);
      if (value.isNotEmpty) map.putIfAbsent(value, () => <CatalogEntryDefinition>[]).add(entry);
    }
    final groups = map.entries.map((e) => _EntryGroup(name: e.key, entries: e.value, field: field)).toList(growable: false);
    groups.sort((a, b) => _compare(a.name, b.name));
    return groups;
  }

  List<CatalogEntryDefinition> _sortedEntries() {
    final result = [..._entries];
    if (_sortField == null) return result;
    result.sort((a, b) {
      final value = _compare(_value(a, _sortField!), _value(b, _sortField!));
      return _descending ? -value : value;
    });
    return result;
  }

  int _compare(String a, String b) {
    final aa = double.tryParse(a.replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.\-]'), ''));
    final bb = double.tryParse(b.replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.\-]'), ''));
    return aa != null && bb != null ? aa.compareTo(bb) : a.toLowerCase().compareTo(b.toLowerCase());
  }

  List<String> get _sortFields {
    const fields = ['year', 'denomination', 'series', 'rarity', 'platform', 'title'];
    return fields.where((field) => widget.catalog.entries.any((e) => _value(e, field).isNotEmpty)).toList(growable: false);
  }

  String _fieldName(String field) => const {'country':'Страна','year':'Год','denomination':'Номинал','series':'Серия','rarity':'Редкость','platform':'Платформа','title':'Название'}[field] ?? field;
  String _groupingName(List<String> fields) => fields.isEmpty ? 'Показать все' : fields.map(_fieldName).join(' → ');
  String get _title => _filters.isEmpty ? AppLocalizations.of(context).catalogName(widget.catalog.id) : _filters.last.$2;

  List<String> _pathForGrouping(List<String> fields) => fields.isEmpty ? <String>[_dynamic, _config, _all] : <String>[_dynamic, _config, ...fields, '__filters__'];

  void _selectGrouping(List<String> fields) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => CatalogOnlinePage(catalog: widget.catalog, onDownload: widget.onDownload, sectionPath: _pathForGrouping(fields)));
  }

  void _pushGroup(_EntryGroup group) {
    final path = <String>[_dynamic, _config, ..._groupingFields, '__filters__'];
    for (final filter in _filters) { path..add(filter.$1)..add(filter.$2); }
    path..add(group.field)..add(group.name);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => CatalogOnlinePage(catalog: widget.catalog, onDownload: widget.onDownload, sectionPath: path)));
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
    if (_layoutListener != null) UiLayoutSettings.revision.removeListener(_layoutListener!);
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final keys = await FavoritesStore.loadKeys();
    if (!mounted) return;
    setState(() {
      _favorite = keys.contains(FavoritesStore.catalogKey(widget.catalog.id));
      _favoriteSections = keys.where((k) => k.startsWith('section:')).map((k) => k.substring('section:'.length)).toSet();
    });
  }

  Future<void> _toggleCatalogFavorite() async {
    final keys = await FavoritesStore.toggle(widget.catalog.id);
    if (mounted) setState(() => _favorite = keys.contains(FavoritesStore.catalogKey(widget.catalog.id)));
  }

  Future<void> _toggleSectionFavorite(String id) async {
    final keys = await FavoritesStore.toggleKey(FavoritesStore.sectionKey(id));
    if (mounted) setState(() => _favoriteSections = keys.where((k) => k.startsWith('section:')).map((k) => k.substring('section:'.length)).toSet());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groups = _groups;
    final entries = _sortedEntries();
    final showGroups = _isDynamic && _filters.length < _groupingFields.length && groups.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: Text(_title, maxLines: 2, overflow: TextOverflow.ellipsis), actions: [
        IconButton(tooltip: l10n.favorites, onPressed: _toggleCatalogFavorite, icon: Icon(_favorite ? Icons.star_rounded : Icons.star_border_rounded)),
        if (_groupingPresets.length > 1) PopupMenuButton<int>(tooltip: 'Группировка', onSelected: (i) => _selectGrouping(_groupingPresets[i]), itemBuilder: (_) => [for (var i = 0; i < _groupingPresets.length; i++) PopupMenuItem(value: i, child: Text(_groupingName(_groupingPresets[i])))]),
        if (_sortFields.isNotEmpty) PopupMenuButton<String>(tooltip: 'Сортировка', onSelected: (value) => setState(() => value == '__reverse__' ? _descending = !_descending : _sortField = value), itemBuilder: (_) => [for (final field in _sortFields) PopupMenuItem(value: field, child: Text('По ${_fieldName(field).toLowerCase()}')), const PopupMenuDivider(), const PopupMenuItem(value: '__reverse__', child: Text('Изменить порядок'))]),
      ]),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: showGroups ? groups.length : (entries.isEmpty ? 1 : entries.length),
        itemBuilder: (context, index) {
          if (showGroups) {
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
  final first = normalized.codeUnitAt(0), second = normalized.codeUnitAt(1);
  if (first < 65 || first > 90 || second < 65 || second > 90) return null;
  return String.fromCharCodes([0x1F1E6 + first - 65, 0x1F1E6 + second - 65]);
}

String? countryNameToFlag(String name) {
  const flags = <String, String>{'Россия':'🇷🇺','Германия':'🇩🇪','Италия':'🇮🇹','Франция':'🇫🇷','Испания':'🇪🇸','Португалия':'🇵🇹','Великобритания':'🇬🇧','США':'🇺🇸','Соединенные Штаты':'🇺🇸','Канада':'🇨🇦','Япония':'🇯🇵','Китай':'🇨🇳','Южная Корея':'🇰🇷','Корея':'🇰🇷','Польша':'🇵🇱','Чехия':'🇨🇿','Швейцария':'🇨🇭','Австрия':'🇦🇹','Бельгия':'🇧🇪','Нидерланды':'🇳🇱','Швеция':'🇸🇪','Норвегия':'🇳🇴','Дания':'🇩🇰','Финляндия':'🇫🇮','Эстония':'🇪🇪','Латвия':'🇱🇻','Литва':'🇱🇹','Украина':'🇺🇦','Беларусь':'🇧🇾','Бразилия':'🇧🇷','Мексика':'🇲🇽','Индия':'🇮🇳','Австралия':'🇦🇺'};
  return flags[name.trim()];
}
