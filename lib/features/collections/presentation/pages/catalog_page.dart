import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/collection_provider.dart';
import 'collection_detail_page.dart';

/// Главный каталог созданных пользователем коллекций.
class CatalogPage extends ConsumerWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Каталог')),
      body: collectionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (collections) {
          if (collections.isEmpty) {
            return const Center(
              child: Text(
                'Каталог пуст. Создайте коллекцию во вкладке «Коллекция».',
                textAlign: TextAlign.center,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(collectionsProvider);
              await ref.read(collectionsProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: collections.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final collection = collections[index];

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.collections_bookmark),
                    ),
                    title: Text(collection.name),
                    subtitle: Text(
                      collection.templateId == null
                          ? 'Пользовательская коллекция'
                          : 'Шаблон: ${collection.templateId}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CollectionDetailPage(
                            collectionId: collection.id,
                            collectionName: collection.name,
                          ),
                        ),
                      );
                      if (!context.mounted) return;
                      ref.invalidate(collectionsProvider);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
