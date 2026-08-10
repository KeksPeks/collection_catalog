import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../collections/domain/entities/collection.dart';
import '../providers/item_provider.dart';
import '../providers/item_service_provider.dart';
import 'item_detail_page.dart';
import 'item_editor_page.dart';

/// Страница списка предметов коллекции.
class ItemsPage extends ConsumerStatefulWidget {
  final Collection collection;

  const ItemsPage({
    super.key,
    required this.collection,
  });

  @override
  ConsumerState<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends ConsumerState<ItemsPage> {
  void _refresh() {
    if (!mounted) {
      return;
    }

    ref.invalidate(itemsProvider(widget.collection.id));
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(
      itemsProvider(widget.collection.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collection.name),
      ),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('Предметов пока нет'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text('Предмет ${index + 1}'),
                    subtitle: Text(item.id),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ItemDetailPage(
                            itemId: item.id,
                          ),
                        ),
                      );

                      _refresh();
                    },
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value != 'delete') {
                          return;
                        }

                        final confirmed = await _confirmDelete(
                          context,
                          'Предмет ${index + 1}',
                        );

                        if (!mounted || !confirmed) {
                          return;
                        }

                        await ref
                            .read(itemServiceProvider)
                            .deleteItem(item.id);

                        _refresh();
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Удалить'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text(error.toString()),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ItemEditorPage(
                collection: widget.collection,
              ),
            ),
          );

          _refresh();
        },
      ),
    );
  }

  Future<bool> _confirmDelete(
    BuildContext context,
    String name,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить предмет?'),
        content: Text(name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
