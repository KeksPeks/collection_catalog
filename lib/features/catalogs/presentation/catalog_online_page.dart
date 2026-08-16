import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/localization/app_localizations.dart';
import '../domain/entities/catalog_definition.dart';
import '../domain/entities/catalog_entry_definition.dart';

class CatalogOnlinePage extends StatefulWidget {
  final CatalogDefinition catalog;
  final Future<void> Function()? onDownload;

  const CatalogOnlinePage({super.key, required this.catalog, this.onDownload});

  @override
  State<CatalogOnlinePage> createState() => _CatalogOnlinePageState();
}

class _CatalogOnlinePageState extends State<CatalogOnlinePage> {
  static const _favoritesKey = 'catalog.favoriteIds';
  bool _favorite = false;
  bool _descending = false;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _favorite = preferences.getStringList(_favoritesKey)?.contains(widget.catalog.id) ?? false);
  }

  Future<void> _toggleFavorite() async {
    final preferences = await SharedPreferences.getInstance();
    final ids = preferences.getStringList(_favoritesKey)?.toSet() ?? <String>{};
    if (_favorite) {
      ids.remove(widget.catalog.id);
    } else {
      ids.add(widget.catalog.id);
    }
    await preferences.setStringList(_favoritesKey, ids.toList()..sort());
    if (mounted) setState(() => _favorite = !_favorite);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalog = widget.catalog;
    final entries = [...catalog.entries]..sort((a, b) {
      final result = a.primaryValue.toLowerCase().compareTo(b.primaryValue.toLowerCase());
      return _descending ? -result : result;
    });
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.catalogName(catalog.id)),
        actions: [
          IconButton(onPressed: _toggleFavorite, tooltip: _favorite ? l10n.removeFavorite : l10n.favorite, icon: Icon(_favorite ? Icons.star_rounded : Icons.star_border_rounded)),
          PopupMenuButton<bool>(
            icon: const Icon(Icons.sort_rounded),
            onSelected: (value) => setState(() => _descending = value),
            itemBuilder: (_) => [
              PopupMenuItem(value: false, child: Text(l10n.byPrimary)),
              PopupMenuItem(value: true, child: Text(l10n.reverse)),
            ],
          ),
        ],
      ),
      body: CustomScrollView(slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          sliver: SliverToBoxAdapter(child: _buildHeader(context, l10n, colors)),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          sliver: SliverToBoxAdapter(child: _buildPrimaryInfo(context, l10n, colors)),
        ),
        if (entries.isEmpty)
          SliverFillRemaining(hasScrollBody: false, child: Center(child: Text(l10n.noResults)))
        else
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
      ]),
      bottomNavigationBar: widget.onDownload == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton.icon(
                  onPressed: () async {
                    await widget.onDownload!.call();
                    if (mounted) Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: Text(l10n.download),
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [colors.primaryContainer, colors.secondaryContainer]), borderRadius: BorderRadius.circular(26)),
      child: Row(children: [
        Container(width: 64, height: 64, decoration: BoxDecoration(color: colors.surface.withValues(alpha: 0.72), borderRadius: BorderRadius.circular(20)), child: Icon(_icon(widget.catalog.id), color: colors.primary, size: 34)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.catalogName(widget.catalog.id), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(l10n.catalogDescriptionFor(widget.catalog.id)),
        ])),
      ]),
    );
  }

  Widget _buildPrimaryInfo(BuildContext context, AppLocalizations l10n, ColorScheme colors) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Icon(Icons.sort_by_alpha_rounded, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.primaryAttribute, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 3),
            Text(_fieldLabel(widget.catalog.primaryField), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(l10n.automaticSorting, style: Theme.of(context).textTheme.bodySmall),
          ])),
          Text('${widget.catalog.entries.length}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: colors.primary, fontWeight: FontWeight.w900)),
        ]),
      ),
    );
  }

  String _fieldLabel(String field) {
    switch (field) {
      case 'series': return 'Серия';
      case 'country': return 'Страна';
      case 'platform': return 'Платформа';
      case 'year': return 'Год';
      default: return field;
    }
  }

  IconData _icon(String id) {
    switch (id) {
      case 'coins': return Icons.monetization_on_outlined;
      case 'banknotes': return Icons.payments_outlined;
      case 'pokemon_tcg': return Icons.style_outlined;
      case 'games': return Icons.sports_esports_outlined;
      case 'discs': return Icons.album_outlined;
      case 'movies': return Icons.movie_outlined;
      case 'figurines': return Icons.toys_outlined;
      default: return Icons.extension_rounded;
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
        child: Row(children: [
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
        ]),
      ),
    );
  }
}
