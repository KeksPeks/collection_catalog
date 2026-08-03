import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../collections/domain/entities/collection.dart';

import 'item_detail_page.dart';
import 'item_editor_page.dart';

import '../providers/item_provider.dart';

/// Страница списка предметов коллекции.
class ItemsPage extends ConsumerWidget {
  final Collection collection;

  const ItemsPage({
    super.key,
    required this.collection,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final itemsAsync = ref.watch(
      itemsProvider(
        collection.id,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          collection.name,
        ),
      ),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Предметов пока нет',
              ),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (
              context,
              index,
            ) {
              final item = items[index];

              return ListTile(
                title: Text(
                  'Предмет ${index + 1}',
                ),
                subtitle: Text(
                  item.id,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ItemDetailPage(
                        itemId: item.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (
          error,
          stack,
        ) {
          return Center(
            child: Text(
              error.toString(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ItemEditorPage(
                collection: collection,
              ),
            ),
          );
        },
      ),
    );
  }
}