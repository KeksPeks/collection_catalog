import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../data/catalog_registry.dart';
import '../data/favorites_store.dart';
import '../domain/entities/catalog_definition.dart';
import 'catalog_online_page.dart';
import '../../collections/presentation/providers/collection_provider.dart';
import '../../collections/presentation/providers/collection_section_provider.dart';
import '../../items/presentation/providers/item_service_provider.dart';
import '../../items/presentation/pages/item_detail_page.dart';

/// Избранное на любом уровне: каталог, раздел и предмет.
class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});
  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  Set<String> _favoriteIds = <String>{};
  final Map<String, String> _labels = {};
  VoidCallback? _listener;

  @override
  void initState() {
    super.initState();
    _listener = _load;
    FavoritesStore.revision.addListener(_listener!);
    _load();
  }

  @override
  void dispose() {
    if (_listener != null) FavoritesStore.revision.removeListener(_listener!);
    super.dispose();
  }

  Future<void> _load() async {
    final ids = await FavoritesStore.loadKeys();
    final collections = ref.read(collectionsProvider).valueOrNull ?? const [];
    final itemService = ref.read(itemServiceProvider);
    final labels = <String, String>{};
    for (final collection in collections) {
      final sections = await ref.read(collectionSectionServiceProvider.future).then((service) => service.getSections(collection.id));
      for (final section in sections) {
        labels[FavoritesStore.sectionKey(section.id)] = '${collection.name} · ${section.name}';
      }
      final items = await itemService.getItems(collection.id);
      for (final item in items) {
        labels[FavoritesStore.itemKey(item.id)] = '${collection.name} · ${item.id}';
      }
    }
    if (!mounted) return;
    setState(() {
      _favoriteIds = ids;
      _labels
        ..clear()
        ..addAll(labels);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalogFavorites = CatalogRegistry.all.where((catalog) => _favoriteIds.contains(FavoritesStore.catalogKey(catalog.id))).toList(growable: false);
    final sectionFavorites = _favoriteIds.where((id) => id.startsWith('section:')).toList(growable: false);
    final itemFavorites = _favoriteIds.where((id) => id.startsWith('item:')).toList(growable: false);

    if (_favoriteIds.isEmpty) return Scaffold(appBar: AppBar(title: Text(l10n.favorites)), body: _EmptyFavorites(l10n: l10n));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.favorites), actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded))]),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 32), children: [
        if (catalogFavorites.isNotEmpty) ...[
          const _Heading(title: 'Коллекции', icon: Icons.collections_bookmark_outlined),
          ...catalogFavorites.map((catalog) => _FavoriteTile(title: l10n.catalogName(catalog.id), subtitle: 'Каталог · версия ${catalog.version}', icon: _icon(catalog.id), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CatalogOnlinePage(catalog: catalog))), onRemove: () => FavoritesStore.remove(catalog.id))),
        ],
        if (sectionFavorites.isNotEmpty) ...[
          const SizedBox(height: 12),
          const _Heading(title: 'Разделы', icon: Icons.folder_outlined),
          ...sectionFavorites.map((key) => _FavoriteTile(title: _labels[key] ?? key.substring(8), subtitle: 'Раздел каталога', icon: Icons.folder_outlined, onTap: () {}, onRemove: () => FavoritesStore.removeKey(key))),
        ],
        if (itemFavorites.isNotEmpty) ...[
          const SizedBox(height: 12),
          const _Heading(title: 'Предметы', icon: Icons.inventory_2_outlined),
          ...itemFavorites.map((key) => _FavoriteTile(title: _labels[key] ?? key.substring(5), subtitle: 'Предмет коллекции', icon: Icons.inventory_2_outlined, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ItemDetailPage(itemId: key.substring(5)))), onRemove: () => FavoritesStore.removeKey(key))),
        ],
      ]),
    );
  }

  IconData _icon(String id) { switch (id) { case 'lego': return Icons.extension_rounded; case 'coins': return Icons.monetization_on_outlined; case 'banknotes': return Icons.payments_outlined; case 'pokemon_tcg': return Icons.style_outlined; case 'games': return Icons.sports_esports_outlined; default: return Icons.inventory_2_outlined; } }
}

class _Heading extends StatelessWidget { final String title; final IconData icon; const _Heading({required this.title, required this.icon}); @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Icon(icon), const SizedBox(width: 8), Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))])); }
class _FavoriteTile extends StatelessWidget { final String title; final String subtitle; final IconData icon; final VoidCallback onTap; final VoidCallback onRemove; const _FavoriteTile({required this.title, required this.subtitle, required this.icon, required this.onTap, required this.onRemove}); @override Widget build(BuildContext context) => Card(child: ListTile(leading: CircleAvatar(child: Icon(icon)), title: Text(title), subtitle: Text(subtitle), onTap: onTap, trailing: IconButton(icon: const Icon(Icons.star_rounded), onPressed: onRemove))); }
class _EmptyFavorites extends StatelessWidget { final AppLocalizations l10n; const _EmptyFavorites({required this.l10n}); @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 88, height: 88, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(28)), child: Icon(Icons.star_border_rounded, size: 48, color: Theme.of(context).colorScheme.primary)), const SizedBox(height: 20), Text(l10n.noFavorites, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 8), Text(l10n.noFavoritesDescription, textAlign: TextAlign.center)]))); }
