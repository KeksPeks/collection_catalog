import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/settings/ui_layout_settings.dart';
import '../data/catalog_registry.dart';
import '../data/catalog_ui_localization.dart';
import '../data/favorites_store.dart';
import 'catalog_online_page.dart';
import '../../collections/presentation/providers/collection_provider.dart';
import '../../collections/presentation/providers/collection_section_service_provider.dart';
import '../../items/presentation/providers/item_service_provider.dart';
import '../../items/presentation/pages/item_detail_page.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});
  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  Set<String> _ids = <String>{};
  final Map<String, String> _labels = <String, String>{};
  VoidCallback? _listener;
  VoidCallback? _layoutListener;

  @override
  void initState() {
    super.initState();
    _listener = _load;
    _layoutListener = () { if (mounted) setState(() {}); };
    FavoritesStore.revision.addListener(_listener!);
    UiLayoutSettings.revision.addListener(_layoutListener!);
    _load();
  }

  @override
  void dispose() {
    final listener = _listener;
    if (listener != null) FavoritesStore.revision.removeListener(listener);
    final layoutListener = _layoutListener;
    if (layoutListener != null) UiLayoutSettings.revision.removeListener(layoutListener);
    super.dispose();
  }

  Future<void> _load() async {
    await UiLayoutSettings.ensureLoaded();
    final favorites = await FavoritesStore.loadKeys();
    final sectionIds = favorites.where((id) => id.startsWith('section:')).map((id) => id.substring(8)).toSet();
    final itemIds = favorites.where((id) => id.startsWith('item:')).map((id) => id.substring(5)).toSet();
    final labels = <String, String>{};
    if (sectionIds.isNotEmpty || itemIds.isNotEmpty) {
      final collections = ref.read(collectionsProvider).valueOrNull ?? const <dynamic>[];
      final itemService = ref.read(itemServiceProvider);
      final sectionService = await ref.read(collectionSectionServiceProvider.future);
      for (final collection in collections) {
        final sections = sectionIds.isEmpty ? const <dynamic>[] : await sectionService.getSections(collection.id);
        for (final section in sections) if (sectionIds.contains(section.id)) labels['section:${section.id}'] = '${collection.name} · ${section.name}';
        final items = itemIds.isEmpty ? const <dynamic>[] : await itemService.getItems(collection.id);
        for (final item in items) if (itemIds.contains(item.id)) labels['item:${item.id}'] = '${collection.name} · ${item.id}';
      }
    }
    if (!mounted) return;
    setState(() { _ids = favorites; _labels..clear()..addAll(labels); });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalogs = CatalogRegistry.all.where((catalog) => _ids.contains(FavoritesStore.catalogKey(catalog.id)) || _ids.contains(catalog.id)).toList(growable: false);
    final sections = _ids.where((id) => id.startsWith('section:')).toList(growable: false);
    final items = _ids.where((id) => id.startsWith('item:')).toList(growable: false);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.favorites), actions: [IconButton(tooltip: 'Обновить', onPressed: _load, icon: const Icon(Icons.refresh_rounded))]),
      body: _ids.isEmpty ? Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.star_border_rounded, size: 64, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 16), Text(l10n.noFavorites, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 8), Text(l10n.noFavoritesDescription, textAlign: TextAlign.center)]))) : ListView(padding: const EdgeInsets.all(16), children: [
        if (catalogs.isNotEmpty) ...[_Heading('Коллекции', Icons.collections_bookmark_outlined), for (final catalog in catalogs) _Tile(CatalogUiLocalization.catalogName(context, catalog.id), 'Каталог', Icons.inventory_2_outlined, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CatalogOnlinePage(catalog: catalog))), () => FavoritesStore.remove(catalog.id))],
        if (sections.isNotEmpty) ...[_Heading('Разделы', Icons.folder_outlined), for (final id in sections) _Tile(_labels[id] ?? id.substring(8), 'Раздел каталога', Icons.folder_outlined, () {}, () => FavoritesStore.removeKey(id))],
        if (items.isNotEmpty) ...[_Heading('Предметы', Icons.inventory_2_outlined), for (final id in items) _Tile(_labels[id] ?? id.substring(5), 'Предмет коллекции', Icons.inventory_2_outlined, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ItemDetailPage(itemId: id.substring(5)))), () => FavoritesStore.removeKey(id))],
      ]),
    );
  }
}

class _Heading extends StatelessWidget {
  final String title;
  final IconData icon;
  const _Heading(this.title, this.icon);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(top: 12, bottom: 8), child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon), const SizedBox(width: 8), Flexible(child: Text(title, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)))])));
}

class _Tile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  const _Tile(this.title, this.subtitle, this.icon, this.onTap, this.onRemove);
  @override
  Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 8), child: InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [CircleAvatar(child: Icon(icon)), const SizedBox(width: 10), Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis)])), IconButton(visualDensity: VisualDensity.compact, tooltip: 'Убрать из избранного', onPressed: onRemove, icon: const Icon(Icons.star_rounded))])));
}
