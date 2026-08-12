import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/catalogs/data/catalog_registry.dart';
import '../../../../features/catalogs/domain/entities/catalog_definition.dart';
import '../../../../features/catalogs/presentation/catalog_online_page.dart';
import '../../../../features/downloads/presentation/download_queue_provider.dart';
import '../../../items/presentation/providers/item_service_provider.dart';
import '../../domain/entities/collection.dart';
import '../../domain/entities/collection_section.dart';
import '../../domain/services/collection_section_service.dart';
import '../providers/collection_provider.dart';
import '../providers/collection_section_service_provider.dart';
import '../providers/collection_service_provider.dart';
import 'collection_detail_page.dart';

/// Главный экран готовых каталогов.
///
/// Готовый каталог существует независимо от локальной базы пользователя.
/// Его можно просматривать онлайн, а затем сохранить на устройство.
class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({super.key});

  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
  String _search = '';
  String _sort = 'name';
  bool _descending = false;

  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(collectionsProvider).valueOrNull ?? const <Collection>[];
    final catalogs = _filteredCatalogs();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Сортировка',
            onSelected: (value) {
              setState(() {
                if (value == 'reverse') {
                  _descending = !_descending;
                } else {
                  _sort = value;
                }
              });
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'name', child: Text('По названию')),
              const PopupMenuItem(value: 'type', child: Text('По типу')),
              PopupMenuItem(
                value: 'reverse',
                child: Text(
                  _descending ? 'Прямой порядок' : 'Обратный порядок',
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(collectionsProvider);
          try {
            await ref.read(collectionsProvider.future);
          } catch (_) {
            // Каталоги доступны и без локальной базы.
          }
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Поиск готового каталога',
                border: const OutlineInputBorder(),
                suffixIcon: _search.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _search = ''),
                      ),
              ),
              onChanged: (value) => setState(() => _search = value),
            ),
            const SizedBox(height: 16),
            if (catalogs.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('Каталог не найден')),
                ),
              )
            else
              ...catalogs.map(
                (catalog) => _buildCatalogCard(catalog, collections),
              ),
          ],
        ),
      ),
    );
  }

  List<CatalogDefinition> _filteredCatalogs() {
    final query = _search.trim().toLowerCase();
    final result = CatalogRegistry.all.where((catalog) {
      if (query.isEmpty) return true;
      return catalog.name.toLowerCase().contains(query) ||
          catalog.description.toLowerCase().contains(query);
    }).toList();

    result.sort((a, b) {
      final value = _sort == 'type'
          ? a.templateId.compareTo(b.templateId)
          : a.name.toLowerCase().compareTo(b.name.toLowerCase());
      return _descending ? -value : value;
    });

    return result;
  }

  Widget _buildCatalogCard(
    CatalogDefinition catalog,
    List<Collection> collections,
  ) {
    final localCollection = _findLocalCollection(catalog, collections);
    final ownedFuture = localCollection == null
        ? Future<int>.value(0)
        : ref.read(itemServiceProvider).getItems(localCollection.id).then(
              (items) => items.length,
            );

    final totalText = catalog.totalItems?.toString() ?? '—';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openOnline(catalog),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    child: Icon(_iconForCatalog(catalog.id)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          catalog.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(catalog.description),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: localCollection == null
                        ? 'Скачать каталог'
                        : 'Открыть мои данные',
                    onPressed: () => localCollection == null
                        ? _downloadCatalog(catalog)
                        : _openLocalCollection(localCollection),
                    icon: Icon(
                      localCollection == null
                          ? Icons.download_outlined
                          : Icons.download_done,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _CountTile(
                      icon: Icons.inventory_2_outlined,
                      label: 'Всего',
                      value: totalText,
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<int>(
                      future: ownedFuture,
                      builder: (context, snapshot) => _CountTile(
                        icon: Icons.collections_bookmark_outlined,
                        label: 'У меня',
                        value: '${snapshot.data ?? 0}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                localCollection == null
                    ? 'Онлайн-просмотр доступен без скачивания'
                    : 'Каталог сохранён на устройстве',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Collection? _findLocalCollection(
    CatalogDefinition catalog,
    List<Collection> collections,
  ) {
    for (final collection in collections) {
      if (collection.templateId == catalog.templateId) return collection;
    }
    return null;
  }

  Future<void> _openOnline(CatalogDefinition catalog) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CatalogOnlinePage(
          catalog: catalog,
          onDownload: () async {
            await _downloadCatalog(catalog);
            if (!mounted) return;
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Future<void> _openLocalCollection(Collection collection) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CollectionDetailPage(
          collectionId: collection.id,
          collectionName: collection.name,
        ),
      ),
    );
    if (!mounted) return;
    ref.invalidate(collectionsProvider);
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
      final collectionId =
          'catalog_${catalog.id}_${DateTime.now().microsecondsSinceEpoch}';
      final now = DateTime.now();
      final fields = catalog.template.fields
          .map(
            (field) => field.copyWith(
              id: '${collectionId}_${field.id}',
              collectionId: collectionId,
            ),
          )
          .toList(growable: false);

      final collection = Collection(
        id: collectionId,
        name: catalog.name,
        templateId: catalog.templateId,
        fields: fields,
        createdAt: now,
        updatedAt: now,
      );

      await ref.read(collectionServiceProvider).createCollection(collection);
      final sectionService =
          await ref.read(collectionSectionServiceProvider.future);
      await _createSections(
        sectionService,
        catalog.sections,
        collectionId,
        null,
      );

      ref.invalidate(collectionsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Каталог «${catalog.name}» сохранён на устройстве'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось скачать каталог: $error')),
      );
    } finally {
      ref.read(downloadQueueProvider.notifier).remove(catalog.id);
    }
  }

  Future<void> _createSections(
    CollectionSectionService service,
    List<CatalogSectionDefinition> definitions,
    String collectionId,
    String? parentId,
  ) async {
    for (var index = 0; index < definitions.length; index++) {
      final definition = definitions[index];
      final id = '${collectionId}_section_${definition.id}';
      final now = DateTime.now();
      await service.createSection(
        CollectionSection(
          id: id,
          collectionId: collectionId,
          parentId: parentId,
          name: definition.name,
          sortOrder: index,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await _createSections(
        service,
        definition.children,
        collectionId,
        id,
      );
    }
  }

  IconData _iconForCatalog(String id) {
    switch (id) {
      case 'coins':
        return Icons.monetization_on_outlined;
      case 'banknotes':
        return Icons.payments_outlined;
      case 'pokemon_tcg':
        return Icons.style_outlined;
      case 'discs':
        return Icons.album_outlined;
      case 'games':
        return Icons.sports_esports_outlined;
      case 'movies':
        return Icons.movie_outlined;
      case 'figurines':
        return Icons.toys_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }
}

class _CountTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CountTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
