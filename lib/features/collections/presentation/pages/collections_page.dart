import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/collection_provider.dart';
import '../providers/collection_service_provider.dart';
import 'collection_detail_page.dart';
import 'edit_collection_page.dart';

/// Страница управления коллекциями.
class CollectionsPage extends ConsumerWidget {
  const CollectionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(collectionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Коллекции')),
      body: collections.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Коллекций пока нет'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(collectionsProvider);
              await ref.read(collectionsProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final collection = items[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.collections_bookmark),
                    title: Text(collection.name),
                    subtitle: Text('ID: ${collection.id}'),
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
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EditCollectionPage(
                                collection: collection,
                              ),
                            ),
                          );
                          if (!context.mounted) return;
                          ref.invalidate(collectionsProvider);
                          return;
                        }

                        if (value == 'delete') {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Удалить коллекцию?'),
                              content: Text(collection.name),
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

                          if (!context.mounted || confirmed != true) return;

                          await ref
                              .read(collectionServiceProvider)
                              .deleteCollection(collection.id);
                          if (!context.mounted) return;
                          ref.invalidate(collectionsProvider);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Изменить')),
                        PopupMenuItem(value: 'delete', child: Text('Удалить')),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final name = await showDialog<String>(
            context: context,
            builder: (_) => const _CreateCollectionDialog(),
          );

          if (!context.mounted || name == null || name.isEmpty) return;

          await ref.read(collectionServiceProvider).createNewCollection(name);
          if (!context.mounted) return;
          ref.invalidate(collectionsProvider);
        },
        icon: const Icon(Icons.add),
        label: const Text('Коллекция'),
      ),
    );
  }
}

class _CreateCollectionDialog extends StatefulWidget {
  const _CreateCollectionDialog();

  @override
  State<_CreateCollectionDialog> createState() => _CreateCollectionDialogState();
}

class _CreateCollectionDialogState extends State<_CreateCollectionDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Новая коллекция'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          hintText: 'Название',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Создать')),
      ],
    );
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(context, name);
  }
}
