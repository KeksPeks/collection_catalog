import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../data/favorites_store.dart';
import '../domain/entities/catalog_definition.dart';
import '../domain/entities/catalog_entry_definition.dart';

/// Универсальный экран готового каталога.
///
/// Весь каталог доступен для просмотра. Специальная сортировка появляется
/// только внутри выбранного подраздела, где она имеет смысл.
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
  String? _sortField;
  bool _descending = false;

  bool get _hasSections => widget.catalog.sections.isNotEmpty;
  bool get _insideSection => widget.sectionPath.isNotEmpty;
  bool get _isRussiaRegularCoins => widget.catalog.id == 'coins' &&
      widget.sectionPath.length == 3 &&
      widget.sectionPath[0] == 'countries' &&
      widget.sectionPath[1] == 'russia' &&
      widget.sectionPath[2] == 'regular';

  @override
  void initState() {
    super.initState();
    _loadFavorite();
    _sortField = _insideSection ? _defaultSortField(widget.sectionPath) : widget.catalog.primaryField;
  }

  Future<void> _loadFavorite() async {
    final favorite = await FavoritesStore.contains(widget.catalog.id);
    if (!mounted) return;
    setState(() => _favorite = favorite);
  }

  Future<void> _toggleFavorite() async {
    final ids = await FavoritesStore.toggle(widget.catalog.id);
    if (!mounted) return;
    setState(() => _favorite = ids.contains(widget.catalog.id));
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

  List<CatalogEntryDefinition> get _visibleEntries {
    final path = widget.sectionPath;
    if (path.isEmpty) return widget.catalog.entries;
    return widget.catalog.entries.where((entry) {
      if (entry.sectionPath.length < path.length) return false;
      for (var i = 0; i < path.length; i++) {
        if (entry.sectionPath[i] != path[i]) return false;
      }
      return true;
    }).toList();
  }

  List<CatalogSectionDefinition> get _visibleSections {
    if (widget.sectionPath.isEmpty) return widget.catalog.sections;
    return _currentSection?.children ?? const [];
  }

  String _defaultSortField(List<String> path) {
    if (widget.catalog.id == 'coins' &&
        path.length == 3 &&
        path[0] == 'countries' &&
        path[1] == 'russia' &&
        path[2] == 'regular') {
      return 'year';
    }
    return widget.catalog.primaryField;
  }

  List<String> _sortFields(AppLocalizations l10n) {
    if (_isRussiaRegularCoins) {
      return const ['year', 'series', 'rarity'];
    }
    return [widget.catalog.primaryField];
  }

  String _fieldLabel(String field) {
    switch (field) {
      case 'year': return 'Год';
      case 'series': return 'Серия';
      case 'rarity': return 'Редкость';
      case 'owned': return 'Наличие';
      case 'country': return 'Страна';
      case 'platform': return 'Платформа';
      default: return field;
    }
  }

  List<CatalogEntryDefinition> _sortedEntries(List<CatalogEntryDefinition> source) {
    final entries = [...source];
    final field = _sortField;
    if (field == null) return entries;

    entries.sort((a, b) {
      final av = a.attributes[field] ?? a.attributes[_fieldLabel(field)] ?? a.primaryValue;
      final bv = b.attributes[field] ?? b.attributes[_fieldLabel(field)] ?? b.primaryValue;
      final an = int.tryParse(av);
      final bn = int.tryParse(bv);
      final result = an != null && bn != null
          ? an.compareTo(bn)
          : av.toLowerCase().compareTo(bv.toLowerCase());
      return _descending ? -result : result;
    });
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final entries = _sortedEntries(_visibleEntries);
    final sections = _visibleSections;
    final sortFields = _sortFields(l10n);
    final title = _currentSection?.name ?? l10n.catalogName(widget.catalog.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            tooltip: _favorite ? l10n.removeFavorite : l10n.favorite,
            icon: Icon(_favorite ? Icons.star_rounded : Icons.star_border_rounded),
          ),
          if (_isRussiaRegularCoins)
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort_rounded),
              onSelected: (value) {
                if (value == 'reverse') {
                  setState(() => _descending = !_descending);
                } else {
                  setState(() => _sortField = value);
                }
              },
              itemBuilder: (_) => [
                ...sortFields.map((field) => PopupMenuItem(value: field, child: Text('По ${_fieldLabel(field).toLowerCase()}'))),
                const PopupMenuDivider(),
                PopupMenuItem(value: 'reverse', child: Text(_descending ? 'Прямой порядок' : 'Обратный порядок')),
              ],
            ),
          if (!_isRussiaRegularCoins && (_insideSection || !_hasSections))
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort_rounded),
              onSelected: (value) {
                if (value == 'reverse') {
                  setState(() => _descending = !_descending);
                } else {
                  setState(() => _sortField = value);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: widget.catalog.primaryField, child: Text('По ${_fieldLabel(widget.catalog.primaryField).toLowerCase()}')),
                const PopupMenuDivider(),
                PopupMenuItem(value: 'reverse', child: Text(_descending ? 'Прямой порядок' : 'Обратный порядок')),
              ],
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            sliver: SliverToBoxAdapter(child: _buildHeader(context, l10n, colors, title)),
          ),
          if (sections.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              sliver: SliverList.builder(
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  final section = sections[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.folder_outlined)),
                        title: Text(section.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(section.children.isEmpty ? '${_countForSection(section)} записей' : '${section.children.length} подразделов'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CatalogOnlinePage(
                              catalog: widget.catalog,
                              onDownload: widget.onDownload,
                              sectionPath: [...widget.sectionPath, section.id],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          if (_insideSection || !_hasSections)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              sliver: SliverToBoxAdapter(child: _buildPrimaryInfo(context, colors, entries.length)),
            ),
          if ((_insideSection || !_hasSections) && entries.isEmpty)
            SliverFillRemaining(hasScrollBody: false, child: Center(child: Text(l10n.noResults)))
          else if (_insideSection || !_hasSections)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _EntryCard(entry: entries[index]),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: widget.onDownload == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton.icon(
                  onPressed: () async {
                    await widget.onDownload!.call();
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: Text(l10n.download),
                ),
              ),
            ),
    );
  }

  int _countForSection(CatalogSectionDefinition section) {
    final path = [...widget.sectionPath, section.id];
    return widget.catalog.entries.where((entry) {
      if (entry.sectionPath.length < path.length) return false;
      for (var i = 0; i < path.length; i++) {
        if (entry.sectionPath[i] != path[i]) return false;
      }
      return true;
    }).length;
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n, ColorScheme colors, String title) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [colors.primaryContainer, colors.secondaryContainer]), borderRadius: BorderRadius.circular(26)),
      child: Row(
        children: [
          Container(width: 64, height: 64, decoration: BoxDecoration(color: colors.surface.withValues(alpha: 0.72), borderRadius: BorderRadius.circular(20)), child: Icon(_icon(widget.catalog.id), color: colors.primary, size: 34)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(_isRussiaRegularCoins ? 'Регулярный чекан России' : _insideSection ? 'Подкаталог ${l10n.catalogName(widget.catalog.id)}' : l10n.catalogDescriptionFor(widget.catalog.id)),
          ])),
        ],
      ),
    );
  }

  Widget _buildPrimaryInfo(BuildContext context, ColorScheme colors, int count) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.sort_rounded, color: colors.primary),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Сортировка', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 3),
              Text(_fieldLabel(_sortField ?? widget.catalog.primaryField), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            ])),
            Text('$count', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: colors.primary, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  IconData _icon(String id) {
    switch (id) {
      case 'lego': return Icons.extension_rounded;
      case 'coins': return Icons.monetization_on_outlined;
      case 'banknotes': return Icons.payments_outlined;
      case 'pokemon_tcg': return Icons.style_outlined;
      case 'games': return Icons.sports_esports_outlined;
      case 'discs': return Icons.album_outlined;
      case 'movies': return Icons.movie_outlined;
      case 'figurines': return Icons.toys_outlined;
      default: return Icons.inventory_2_outlined;
    }
  }
}

class _EntryCard extends StatelessWidget {
  final CatalogEntryDefinition entry;
  const _EntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: colors.surfaceContainerHighest, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.inventory_2_outlined)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(entry.primaryValue, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colors.primary, fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(entry.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(entry.subtitle, style: Theme.of(context).textTheme.bodySmall),
            ])),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
