import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../fields/presentation/providers/field_provider.dart';
import '../../../items/presentation/pages/catalog_item_detail_page.dart';
import '../../../items/presentation/pages/item_detail_page.dart';
import '../../../items/presentation/pages/items_page.dart';
import '../../../items/presentation/providers/item_provider.dart';
import '../../domain/entities/collection.dart';
import '../providers/collection_provider.dart';

/// Просмотр загруженного централизованного каталога.
/// Пользователь не изменяет структуру, поля или состав каталога.
class CollectionDetailPage extends ConsumerWidget {
  final String collectionId;
  final String collectionName;

  const CollectionDetailPage({
    super.key,
    required this.collectionId,
    required this.collectionName,
  });

  Collection _fallbackCollection() {
    final now = DateTime.now();
    return Collection(
      id: collectionId,
      name: collectionName,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fieldsAsync = ref.watch(fieldsProvider(collectionId));
    final itemsAsync = ref.watch(itemsProvider(collectionId));
    final collectionAsync = ref.watch(collectionProvider(collectionId));
    final collection = collectionAsync.valueOrNull ?? _fallbackCollection();

    return Scaffold(
      appBar: AppBar(title: Text(collectionName)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(fieldsProvider(collectionId));
          ref.invalidate(itemsProvider(collectionId));
          ref.invalidate(collectionProvider(collectionId));
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(collectionName),
                subtitle: collectionAsync.when(
                  data: (value) => Text(
                    'Централизованный каталог · ${value?.templateId ?? 'каталог'}',
                  ),
                  loading: () => const Text('Загрузка...'),
                  error: (_, __) => const Text('Каталог'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ItemsPage(collection: collection),
                  ),
                );
              },
              icon: const Icon(Icons.view_list_rounded),
              label: const Text('Открыть каталог предметов'),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Статистика',
              child: itemsAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (error, _) => Text(error.toString()),
                data: (items) => fieldsAsync.when(
                  loading: () => Text('Физических экземпляров: ${items.length}'),
                  error: (_, __) =>
                      Text('Физических экземпляров: ${items.length}'),
                  data: (fields) => Text(
                    'Физических экземпляров: ${items.length} · Полей: ${fields.length}',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Предметы',
              child: itemsAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (error, _) => Text(error.toString()),
                data: (items) {
                  if (items.isEmpty) {
                    return const Text('Предметов нет');
                  }

                  final visibleItems = items.take(20).toList(growable: false);
                  return Column(
                    children: visibleItems.map((item) {
                      final catalogItemId = item.catalogItemId;
                      final linked = catalogItemId != null;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          linked
                              ? Icons.copy_all_outlined
                              : Icons.inventory_2_outlined,
                        ),
                        title: Text(
                          linked
                              ? 'Каталожная позиция $catalogItemId'
                              : item.id,
                        ),
                        subtitle: Text(
                          linked
                              ? 'Физический экземпляр: ${item.id}'
                              : 'Физический экземпляр',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          if (catalogItemId != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CatalogItemDetailPage(
                                  catalogItemId: catalogItemId,
                                  collectionId: item.collectionId,
                                  title: 'Каталожная позиция $catalogItemId',
                                ),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ItemDetailPage(itemId: item.id),
                              ),
                            );
                          }
                        },
                      );
                    }).toList(growable: false),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Поля каталога',
              child: fieldsAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (error, _) => Text(error.toString()),
                data: (fields) {
                  if (fields.isEmpty) {
                    return const Text('Поля отсутствуют');
                  }

                  return Column(
                    children: fields.map((field) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.label_outline),
                        title: Text(field.label),
                        subtitle: Text(field.type.name),
                        trailing: const Icon(Icons.lock_outline),
                      );
                    }).toList(growable: false),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
