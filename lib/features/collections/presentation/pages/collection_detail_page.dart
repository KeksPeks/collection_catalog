import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../fields/presentation/providers/field_provider.dart';
import '../../../items/presentation/pages/items_page.dart';
import '../../../items/presentation/providers/item_provider.dart';
import '../../domain/entities/collection.dart';
import '../providers/collection_provider.dart';

class CollectionDetailPage extends ConsumerWidget {
  final String collectionId;
  final String collectionName;

  const CollectionDetailPage({
    super.key,
    required this.collectionId,
    required this.collectionName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collection = ref.watch(collectionProvider(collectionId));
    final fields = ref.watch(fieldsProvider(collectionId));
    final items = ref.watch(itemsProvider(collectionId));

    return Scaffold(
      appBar: AppBar(title: Text(collectionName)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(collectionProvider(collectionId));
          ref.invalidate(fieldsProvider(collectionId));
          ref.invalidate(itemsProvider(collectionId));
          await Future<void>.delayed(Duration.zero);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(collectionName),
                subtitle: const Text(
                  'Централизованный каталог · пользователь меняет только личное состояние',
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                final current = collection.valueOrNull ??
                    Collection(
                      id: collectionId,
                      name: collectionName,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ItemsPage(collection: current),
                  ),
                );
              },
              icon: const Icon(Icons.view_list_rounded),
              label: const Text('Открыть каталог'),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.insights_outlined),
                title: const Text('Статистика'),
                subtitle: items.when(
                  data: (itemList) => fields.when(
                    data: (fieldList) => Text(
                      'Предметов: ${itemList.length} · Полей: ${fieldList.length}',
                    ),
                    loading: () => Text('Предметов: ${itemList.length}'),
                    error: (error, stack) => Text('Предметов: ${itemList.length}'),
                  ),
                  loading: () => const Text('Загрузка...'),
                  error: (error, stack) => Text(error.toString()),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ExpansionTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: const Text('Предметы'),
                children: [
                  ...items.when(
                    data: (list) => list
                        .take(10)
                        .map(
                          (item) => ListTile(
                            title: Text(item.id),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              final current = collection.valueOrNull ??
                                  Collection(
                                    id: collectionId,
                                    name: collectionName,
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                  );
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ItemsPage(
                                    collection: current,
                                    sectionId: item.sectionId,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                        .toList(growable: false),
                    loading: () => const <Widget>[
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    ],
                    error: (error, stack) => <Widget>[
                      ListTile(title: Text(error.toString())),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ExpansionTile(
                leading: const Icon(Icons.label_outline),
                title: const Text('Поля каталога'),
                children: [
                  ...fields.when(
                    data: (list) => list
                        .map(
                          (field) => ListTile(
                            title: Text(field.label),
                            subtitle: Text(field.type.name),
                            trailing: const Icon(Icons.lock_outline),
                          ),
                        )
                        .toList(growable: false),
                    loading: () => const <Widget>[
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    ],
                    error: (error, stack) => <Widget>[
                      ListTile(title: Text(error.toString())),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
