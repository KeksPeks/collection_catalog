import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/settings/ui_layout_settings.dart';
import '../data/catalog_registry.dart';
import '../data/catalog_structure_defaults.dart';
import '../data/catalog_ui_localization.dart';
import '../data/favorites_store.dart';
import '../domain/entities/catalog_definition.dart';
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
    final stored = await FavoritesStore.loadKeys();
    final valid = <String>{};
    for (final key in stored) {
      if (key.startsWith('catalog:') || key.startsWith('section:') || key.startsWith('item:')) {
        valid.add(key);
      } else if (CatalogRegistry.byId(key) != null) {
        valid.add(FavoritesStore.catalogKey(key));
      }
    }
    final changed = valid.length != stored.length || !valid.containsAll(stored) || !stored.containsAll(valid);
    if (changed) await FavoritesStore.replaceAll(valid);

    final sectionIds = valid.where((id) => id.startsWith('section:')).map((id) => id.substring(8)).toSet();
    final itemIds = valid.where((id) => id.startsWith('item:')).map((id) => id.substring(5)).toSet();
    final labels = <String, String>{};
    if (sectionIds.isNotEmpty || itemIds.isNotEmpty) {
      final collections = ref.read(collectionsProvider).valueOrNull ?? const <dynamic>[];
      final itemService = ref.read(itemServiceProvider);
      final sectionService = await ref.read(collectionSectionServiceProvider.future);
      for (final collection in collections) {
        final sections = sectionIds.isEmpty ? const <dynamic>[] : await sectionService.getSections(collection.id);
        for (final section in sections) {
          if (sectionIds.contains(section.id)) labels['section:${section.id}'] = '${collection.name} · ${section.name}';
        }
        final items = itemIds.isEmpty ? const <dynamic>[] : await itemService.getItems(collection.id);
        for (final item in items) {
          if (itemIds.contains(item.id)) labels['item:${item.id}'] = '${collection.name} · ${item.id}';
        }
      }
    }
    if (!mounted) return;
    setState(() { _ids = valid; _labels..clear()..addAll(labels); });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalogs = CatalogRegistry.all.where((catalog) => _ids.contains(FavoritesStore.catalogKey(catalog.id))).toList(growable: false);
    final sections = _ids.where((id) => id.startsWith('section:') && _labels.containsKey(id)).toList(growable: false);
    final items = _ids.where((id) => id.startsWith('item:') && _labels.containsKey(id)).toList(growable: false);

    final countryCatalogs = catalogs.where((catalog) => catalog.id == 'coins').toList(growable: false);
    final regularCatalogs = catalogs.where((catalog) => catalog.id != 'coins').toList(growable: false);
    final countryTiles = <Widget>[];
    for (final catalog in countryCatalogs) {
      final normalized = CatalogStructureDefaults.apply(catalog);
      final root = normalized.sections.where((section) => section.id == 'countries').firstOrNull;
      if (root != null) {
        for (final country in root.children) {
          countryTiles.add(_Tile(
            country.name,
            'Нумизматика',
            Icons.flag_outlined,
            () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CatalogOnlinePage(catalog: normalized, sectionPath: [root.id, country.id]))),
            () => FavoritesStore.remove(catalog.id),
          ));
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.favorites), actions: [IconButton(tooltip: 'Обновить', onPressed: _load, icon: const Icon(Icons.refresh_rounded))]),
      body: _ids.isEmpty
          ? Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.star_border_rounded, size: 64, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 16), Text(l10n.noFavorites, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 8), Text(l10n.noFavoritesDescription, textAlign: TextAlign.center)])))
          : ListView(padding: const EdgeInsets.all(16), children: [
              if (countryTiles.isNotEmpty) ...[_Heading('Нумизматика', Icons.monetization_on_outlined), ...countryTiles],
              if (regularCatalogs.isNotEmpty) ...[_Heading('Коллекции', Icons.collections_bookmark_outlined), for (final catalog in regularCatalogs) _Tile(CatalogUiLocalization.catalogName(context, catalog.id), 'Каталог', Icons.inventory_2_outlined, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CatalogOnlinePage(catalog: CatalogStructureDefaults.apply(catalog)))), () => FavoritesStore.remove(catalog.id))],
              if (sections.isNotEmpty) ...[_Heading('Разделы', Icons.folder_outlined), for (final id in sections) _Tile(_labels[id]!, 'Раздел каталога', Icons.folder_outlined, () {}, () => FavoritesStore.removeKey(id))],
              if (items.isNotEmpty) ...[_Heading('Предметы', Icons.inventory_2_outlined), for (final id in items) _Tile(_labels[id]!, 'Предмет коллекции', Icons.inventory_2_outlined, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ItemDetailPage(itemId: id.substring(5)))), () => FavoritesStore.removeKey(id))],
            ]),
    );
  }
}

class _Heading extends StatelessWidget {
  final String title; final IconData icon;
  const _Heading(this.title, this.icon);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(top: 12, bottom: 8), child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon), const SizedBox(width: 8), Flexible(child: Text(title, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)))])));
}

class _Tile extends StatelessWidget {
  final String title, subtitle; final IconData icon; final VoidCallback onTap, onRemove;
  const _Tile(this.title, this.subtitle, this.icon, this.onTap, this.onRemove);
  @override
  Widget build(BuildContext context) {
    return Card(margin: const EdgeInsets.only(bottom: 8), child: LayoutBuilder(builder: (context, constraints) {
      final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800);
      final painter = TextPainter(text: TextSpan(text: title, style: titleStyle), maxLines: 1, textDirection: Directionality.of(context))..layout(maxWidth: double.infinity);
      final compact = painter.width > constraints.maxWidth - 130;
      return InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Row(children: [CircleAvatar(child: Icon(icon)), const SizedBox(width: 10), Expanded(child: compact ? const SizedBox.shrink() : Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: titleStyle), const SizedBox(height: 2), Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis)])), IconButton(visualDensity: VisualDensity.compact, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 40, minHeight: 40), tooltip: 'Убрать из избранного', onPressed: onRemove, icon: const Icon(Icons.star_rounded))])));
    }));
  }
}
