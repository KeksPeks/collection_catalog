import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/collection_provider.dart';
import '../providers/collection_service_provider.dart';
import 'edit_collection_page.dart';

/// Страница списка коллекций.
class CollectionsPage extends ConsumerStatefulWidget {
  const CollectionsPage({
    super.key,
  });

  @override
  ConsumerState<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends ConsumerState<CollectionsPage> {
  void _refreshCollections() {
    if (!mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ref.invalidate(collectionsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(collectionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Коллекции'),
      ),
      body: collections.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text(error.toString()),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('Коллекций пока нет'),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final collection = items[index];

              return ListTile(
                title: Text(collection.name),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    final service = ref.read(collectionServiceProvider);

                    if (value == 'edit') {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditCollectionPage(
                            collection: collection,
                          ),
                        ),
                      );

                      if (!mounted) {
                        return;
                      }

                      _refreshCollections();
                      return;
                    }

                    if (value == 'delete') {
                      final dialogResult = await _showDeleteDialog(
                        collection.name,
                      );

                      if (!mounted || !dialogResult) {
                        return;
                      }

                      await service.deleteCollection(collection.id);

                      if (!mounted) {
                        return;
                      }

                      _refreshCollections();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Изменить'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Удалить'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await _showCreateDialog();

          if (!mounted || result == null || result.isEmpty) {
            return;
          }

          final service = ref.read(collectionServiceProvider);
          await service.createNewCollection(result);

          if (!mounted) {
            return;
          }

          _refreshCollections();
        },
      ),
    );
  }

  Future<String?> _showCreateDialog() async {
    String name = '';

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Новая коллекция'),
          content: TextField(
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'Название',
            ),
            onChanged: (value) {
              name = value;
            },
            onSubmitted: (value) {
              final valueName = value.trim();
              if (valueName.isNotEmpty) {
                Navigator.pop(dialogContext, valueName);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () {
                final valueName = name.trim();
                if (valueName.isEmpty) {
                  return;
                }

                Navigator.pop(dialogContext, valueName);
              },
              child: const Text('Создать'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showDeleteDialog(String name) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Удалить коллекцию?'),
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
        );
      },
    );

    return result ?? false;
  }
}
