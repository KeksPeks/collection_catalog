import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/settings/ui_layout_settings.dart';
import '../data/favorites_store.dart';
import '../domain/entities/catalog_definition.dart';
import '../domain/entities/catalog_entry_definition.dart';

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
  late final Map<String, int> _sectionCounts = _buildSectionCounts();
  VoidCallback? _layoutListener;

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

  List<CatalogSectionDefinition> get _sections =>
      widget.sectionPath.isEmpty ? widget.catalog.sections : _currentSection?.children ?? const <CatalogSectionDefinition>[];

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
    _layoutListener = () {
      if (mounted) setState(() {});
    };
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
    if (mounted) {
      setState(() => _favoriteSections = keys.where((key) => key.startsWith('section:')).map((key) => key.substring('section:'.length)).toSet());
    }
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
    final title = _currentSection?.name ?? l10n.catalogName(widget.catalog.id);
    final entries = _sortedEntries();
    final showEntries = widget.sectionPath.isNotEmpty || widget.catalog.sections.isEmpty;
    final totalItems = _sections.length + (showEntries ? entries.length : 0);

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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: totalItems + (entries.isEmpty && showEntries ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _sections.length) {
            final section = _sections[index];
            return _SectionCard(
              section: section,
              count: _count(section),
              favorite: _favoriteSections.contains(section.id),
              onFavorite: () => _toggleSectionFavorite(section.id),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CatalogOnlinePage(
                    catalog: widget.catalog,
                    onDownload: widget.onDownload,
                    sectionPath: [...widget.sectionPath, section.id],
                  ),
                ),
              ),
            );
          }

          final entryIndex = index - _sections.length;
          if (entryIndex < entries.length) {
            return _CatalogEntryCard(entry: entries[entryIndex]);
          }

          return const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Записи не найдены', textAlign: TextAlign.center),
          );
        },
      ),
      bottomNavigationBar: widget.onDownload == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: () async {
                    await widget.onDownload!.call();
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
    final path = [...widget.sectionPath, section.id].join('/');
    return _sectionCounts[path] ?? 0;
  }
}

class _SectionCard extends StatelessWidget {
  final CatalogSectionDefinition section;
  final int count;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  const _SectionCard({
    required this.section,
    required this.count,
    required this.favorite,
    required this.onFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _CatalogVisual(label: section.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(section.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(section.children.isEmpty ? '$count записей' : '${section.children.length} подразделов', maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              IconButton(
                onPressed: onFavorite,
                tooltip: 'Избранное',
                icon: Icon(favorite ? Icons.star_rounded : Icons.star_border_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogEntryCard extends StatelessWidget {
  final CatalogEntryDefinition entry;

  const _CatalogEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CatalogVisual(label: entry.attributes['Страна'] ?? entry.primaryValue, imageUrl: entry.imageUrl, countryCode: entry.countryCode),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('${entry.primaryValue} · ${entry.subtitle}', maxLines: 2, overflow: TextOverflow.ellipsis),
                  if (entry.attributes.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: entry.attributes.entries.take(4).map((item) => Chip(label: Text('${item.key}: ${item.value}', maxLines: 1, overflow: TextOverflow.ellipsis))).toList(growable: false),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
    return SizedBox(
      width: 86,
      height: 86,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: flag != null
            ? ColoredBox(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Center(child: Text(flag, style: const TextStyle(fontSize: 42))),
              )
            : imageUrl != null && imageUrl!.trim().isNotEmpty
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _NoImage(),
                  )
                : const _NoImage(),
      ),
    );
  }
}

class _NoImage extends StatelessWidget {
  const _NoImage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Text(
          'NO IMAGES',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
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
  const flags = <String, String>{
    'Россия': '🇷🇺',
    'Германия': '🇩🇪',
    'Италия': '🇮🇹',
    'Франция': '🇫🇷',
    'Испания': '🇪🇸',
    'Португалия': '🇵🇹',
    'Великобритания': '🇬🇧',
    'США': '🇺🇸',
    'Соединенные Штаты': '🇺🇸',
    'Канада': '🇨🇦',
    'Япония': '🇯🇵',
    'Китай': '🇨🇳',
    'Южная Корея': '🇰🇷',
    'Корея': '🇰🇷',
    'Польша': '🇵🇱',
    'Чехия': '🇨🇿',
    'Швейцария': '🇨🇭',
    'Австрия': '🇦🇹',
    'Бельгия': '🇧🇪',
    'Нидерланды': '🇳🇱',
    'Швеция': '🇸🇪',
    'Норвегия': '🇳🇴',
    'Дания': '🇩🇰',
    'Финляндия': '🇫🇮',
    'Эстония': '🇪🇪',
    'Латвия': '🇱🇻',
    'Литва': '🇱🇹',
    'Украина': '🇺🇦',
    'Беларусь': '🇧🇾',
    'Бразилия': '🇧🇷',
    'Мексика': '🇲🇽',
    'Индия': '🇮🇳',
    'Австралия': '🇦🇺',
  };
  return flags[name.trim()];
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
