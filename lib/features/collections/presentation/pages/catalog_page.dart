import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../catalogs/data/catalog_registry.dart';
import '../../../catalogs/domain/entities/catalog_category_definition.dart';
import '../../../catalogs/domain/entities/catalog_definition.dart';
import '../../../catalogs/presentation/catalog_category_page.dart';
import '../../../catalogs/presentation/catalog_online_page.dart';
import '../../../downloads/presentation/download_queue_provider.dart';
import '../../domain/entities/collection.dart';
import '../../domain/entities/collection_section.dart';
import '../../domain/services/collection_section_service.dart';
import '../providers/collection_provider.dart';
import '../providers/collection_section_service_provider.dart';
import '../providers/collection_service_provider.dart';
import 'collection_detail_page.dart';

class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({super.key});

  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
  static const _favoritesKey = 'catalog.favoriteIds';
  static const _layoutKey = 'catalog.categoryLayout';
  String _search = '';
  Set<String> _favorites = <String>{};
  bool _grid = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _favorites = preferences.getStringList(_favoritesKey)?.toSet() ?? <String>{};
      _grid = preferences.getBool(_layoutKey) ?? false;
    });
  }

  Future<void> _setLayout(bool grid) async {
    setState(() => _grid = grid);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_layoutKey, grid);
  }

  Future<void> _toggleFavorite(String catalogId) async {
    final next = {..._favorites};
    if (!next.add(catalogId)) next.remove(catalogId);
    setState(() => _favorites = next);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_favoritesKey, next.toList()..sort());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = _filteredCategories(l10n);
    final favoriteCatalogs = CatalogRegistry.all.where((catalog) => _favorites.contains(catalog.id)).toList();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadPreferences,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              title: Text(l10n.catalog, style: const TextStyle(fontWeight: FontWeight.w800)),
              actions: [
                IconButton(
                  tooltip: l10n.search,
                  icon: const Icon(Icons.search_rounded),
                  onPressed: () => _showSearch(context),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHero(context, l10n, colors),
                  const SizedBox(height: 18),
                  _buildSearch(context, l10n),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _SectionTitle(title: l10n.favorites, icon: Icons.star_rounded)),
                      if (favoriteCatalogs.isNotEmpty) ...[
                        IconButton(onPressed: () => _setLayout(false), icon: const Icon(Icons.view_list_rounded)),
                        IconButton(onPressed: () => _setLayout(true), icon: const Icon(Icons.grid_view_rounded)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (favoriteCatalogs.isEmpty)
                    _buildNoFavorites(context, l10n)
                  else
                    _buildFavorites(context, favoriteCatalogs, l10n),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Expanded(child: _SectionTitle(title: l10n.categories, icon: Icons.category_outlined)),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: false, icon: Icon(Icons.view_list_rounded)),
                          ButtonSegment(value: true, icon: Icon(Icons.grid_view_rounded)),
                        ],
                        selected: {_grid},
                        showSelectedIcon: false,
                        onSelectionChanged: (value) => _setLayout(value.first),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (categories.isEmpty)
                    _buildEmpty(context, l10n)
                  else
                    _buildCategories(context, categories, l10n),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, AppLocalizations l10n, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [colors.primaryContainer, colors.secondaryContainer]),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.catalog, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(l10n.catalogDescription, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45)),
                const SizedBox(height: 14),
                Text(l10n.chooseCategory, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: colors.primary, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Icon(Icons.collections_bookmark_rounded, size: 76, color: colors.primary.withValues(alpha: 0.22)),
        ],
      ),
    );
  }

  Widget _buildSearch(BuildContext context, AppLocalizations l10n) {
    return TextField(
      onChanged: (value) => setState(() => _search = value),
      decoration: InputDecoration(
        labelText: l10n.search,
        hintText: l10n.searchHint,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _search.isEmpty ? null : IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () => setState(() => _search = '')),
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildCategories(BuildContext context, List<CatalogCategoryDefinition> categories, AppLocalizations l10n) {
    if (!_grid) {
      return Column(
        children: categories.map((category) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CategoryListTile(
              category: category,
              title: l10n.categoryName(category.id),
              subtitle: '${category.catalogIds.length} ${l10n.chooseCatalog.toLowerCase()}',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CatalogCategoryPage(categoryId: category.id, onDownload: _downloadCatalog))),
            ),
          );
        }).toList(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1000 ? 4 : constraints.maxWidth >= 650 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 230,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return _CategoryCard(
              category: category,
              title: l10n.categoryName(category.id),
              subtitle: '${category.catalogIds.length} ${l10n.chooseCatalog.toLowerCase()}',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CatalogCategoryPage(categoryId: category.id, onDownload: _downloadCatalog))),
            );
          },
        );
      },
    );
  }

  Widget _buildFavorites(BuildContext context, List<CatalogDefinition> catalogs, AppLocalizations l10n) {
    return SizedBox(
      height: 156,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: catalogs.length,
        separatorBuilder: (_, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final catalog = catalogs[index];
          return _FavoriteCard(
            catalog: catalog,
            title: l10n.catalogName(catalog.id),
            onTap: () => _openCatalog(catalog),
            onToggle: () => _toggleFavorite(catalog.id),
          );
        },
      ),
    );
  }

  Widget _buildNoFavorites(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const Icon(Icons.star_border_rounded),
          const SizedBox(width: 12),
          Expanded(child: Text('${l10n.noFavorites}. ${l10n.noFavoritesDescription}')),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(22)),
      child: Center(child: Text(l10n.noResults, textAlign: TextAlign.center)),
    );
  }

  List<CatalogCategoryDefinition> _filteredCategories(AppLocalizations l10n) {
    final query = _search.trim().toLowerCase();
    if (query.isEmpty) return CatalogRegistry.categories;
    return CatalogRegistry.categories.where((category) {
      final title = l10n.categoryName(category.id).toLowerCase();
      return title.contains(query) || category.catalogIds.any((id) => l10n.catalogName(id).toLowerCase().contains(query));
    }).toList();
  }

  Future<void> _showSearch(BuildContext context) async {
    final controller = TextEditingController(text: _search);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context).search),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: AppLocalizations.of(context).searchHint),
          onChanged: (value) => setState(() => _search = value),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(AppLocalizations.of(context).back))],
      ),
    );
    controller.dispose();
  }

  Future<void> _openCatalog(CatalogDefinition catalog) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => CatalogOnlinePage(catalog: catalog, onDownload: () => _downloadCatalog(catalog))));
  }

  Future<void> _downloadCatalog(CatalogDefinition catalog) async {
    final localCollections = ref.read(collectionsProvider).valueOrNull;
    if (localCollections != null) {
      for (final collection in localCollections) {
        if (collection.templateId == catalog.templateId) {
          await _openLocalCollection(collection);
          return;
        }
      }
    }

    ref.read(downloadQueueProvider.notifier).add(catalog.id, catalog.name);
    try {
      final collectionId = 'catalog_${catalog.id}_${DateTime.now().microsecondsSinceEpoch}';
      final now = DateTime.now();
      final fields = catalog.template.fields.map((field) => field.copyWith(id: '${collectionId}_${field.id}', collectionId: collectionId)).toList(growable: false);
      final collection = Collection(id: collectionId, name: catalog.name, templateId: catalog.templateId, fields: fields, createdAt: now, updatedAt: now);
      await ref.read(collectionServiceProvider).createCollection(collection);
      final sectionService = await ref.read(collectionSectionServiceProvider.future);
      await _createSections(sectionService, catalog.sections, collectionId, null);
      ref.invalidate(collectionsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context).downloaded}: ${AppLocalizations.of(context).catalogName(catalog.id)}')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      ref.read(downloadQueueProvider.notifier).remove(catalog.id);
    }
  }

  Future<void> _openLocalCollection(Collection collection) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => CollectionDetailPage(collectionId: collection.id, collectionName: collection.name)));
    if (mounted) ref.invalidate(collectionsProvider);
  }

  Future<void> _createSections(CollectionSectionService service, List<dynamic> definitions, String collectionId, String? parentId) async {
    for (var index = 0; index < definitions.length; index++) {
      final definition = definitions[index] as CatalogSectionDefinition;
      final id = '${collectionId}_section_${definition.id}';
      final now = DateTime.now();
      await service.createSection(CollectionSection(id: id, collectionId: collectionId, parentId: parentId, name: definition.name, sortOrder: index, createdAt: now, updatedAt: now));
      await _createSections(service, definition.children, collectionId, id);
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) => Row(children: [Icon(icon, size: 21), const SizedBox(width: 8), Expanded(child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)))]);
}

class _CategoryListTile extends StatelessWidget {
  final CatalogCategoryDefinition category;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _CategoryListTile({required this.category, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(width: 52, height: 52, decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(15)), child: Icon(_icon(category.id), color: colors.primary)),
          title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      ),
    );
  }
  IconData _icon(String id) {
    switch (id) {
      case 'constructors': return Icons.extension_rounded;
      case 'coins': return Icons.monetization_on_outlined;
      case 'banknotes': return Icons.payments_outlined;
      case 'cards': return Icons.style_outlined;
      case 'games': return Icons.sports_esports_outlined;
      case 'discs': return Icons.album_outlined;
      case 'movies': return Icons.movie_outlined;
      case 'figurines': return Icons.toys_outlined;
      default: return Icons.category_outlined;
    }
  }
}

class _CategoryCard extends StatelessWidget {
  final CatalogCategoryDefinition category;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _CategoryCard({required this.category, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(15)), child: Icon(_icon(category.id), color: colors.primary)),
            const Spacer(),
            Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
          ]),
        ),
      ),
    );
  }
  IconData _icon(String id) {
    switch (id) {
      case 'constructors': return Icons.extension_rounded;
      case 'coins': return Icons.monetization_on_outlined;
      case 'banknotes': return Icons.payments_outlined;
      case 'cards': return Icons.style_outlined;
      case 'games': return Icons.sports_esports_outlined;
      case 'discs': return Icons.album_outlined;
      case 'movies': return Icons.movie_outlined;
      case 'figurines': return Icons.toys_outlined;
      default: return Icons.category_outlined;
    }
  }
}

class _FavoriteCard extends StatelessWidget {
  final CatalogDefinition catalog;
  final String title;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  const _FavoriteCard({required this.catalog, required this.title, required this.onTap, required this.onToggle});
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: 250,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              CircleAvatar(backgroundColor: colors.primaryContainer, child: Icon(Icons.inventory_2_outlined, color: colors.primary)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 5), Text(catalog.entries.length.toString())])),
              IconButton(onPressed: onToggle, icon: const Icon(Icons.star_rounded), tooltip: AppLocalizations.of(context).removeFavorite),
            ]),
          ),
        ),
      ),
    );
  }
}
