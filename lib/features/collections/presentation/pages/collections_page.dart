import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/collection_provider.dart';
import '../providers/collection_service_provider.dart';
import 'collection_detail_page.dart';
import 'edit_collection_page.dart';
import '../../../templates/presentation/pages/catalog_templates_page.dart';

/// Главный экран управления коллекциями.
class CollectionsPage extends ConsumerStatefulWidget {
  const CollectionsPage({super.key});

  @override
  ConsumerState<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends ConsumerState<CollectionsPage> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(collectionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои коллекции'),
        actions: [
          IconButton(
            tooltip: 'Шаблоны каталогов',
            icon: const Icon(Icons.auto_awesome),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CatalogTemplatesPage()),
              );
              if (!mounted) return;
              ref.invalidate(collectionsProvider);
            },
          ),
        ],
      ),
      body: collections.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Ошибка: $error')),
        data: (items) {
          final filtered = items.where((item) {
            return item.name.toLowerCase().contains(_search.toLowerCase());
          }).toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(collectionsProvider);
              await ref.read(collectionsProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Поиск коллекции',
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
                if (filtered.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(Icons.collections_bookmark_outlined, size: 52),
                          const SizedBox(height: 12),
                          Text(
                            items.isEmpty ? 'Коллекций пока нет' : 'Ничего не найдено',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Создайте собственную коллекцию или используйте готовый шаблон.',
                            textAlign: TextAlign.center,
                          ),
                          if (items.isEmpty) ...[
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const CatalogTemplatesPage(),
                                  ),
                                );
                                if (!mounted) return;
                                ref.invalidate(collectionsProvider);
                              },
                              icon: const Icon(Icons.auto_awesome),
                              label: const Text('Выбрать шаблон'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                else
                  ...filtered.map(
                    (collection) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: const CircleAvatar(
                          child: Icon(Icons.collections_bookmark),
                        ),
                        title: Text(collection.name),
                        subtitle: Text(
                          collection.templateId == null
                              ? 'Пользовательская коллекция'
                              : 'Шаблон: ${collection.templateId}',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'open') {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CollectionDetailPage(
                                    collectionId: collection.id,
                                    collectionName: collection.name,
                                  ),
                                ),
                              );
                            } else if (value == 'edit') {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EditCollectionPage(collection: collection),
                                ),
                              );
                            } else if (value == 'delete') {
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
                              if (confirmed == true) {
                                await ref
                                    .read(collectionServiceProvider)
                                    .deleteCollection(collection.id);
                              }
                            }
                            if (!mounted) return;
                            ref.invalidate(collectionsProvider);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'open', child: Text('Открыть')),
                            PopupMenuItem(value: 'edit', child: Text('Изменить')),
                            PopupMenuItem(value: 'delete', child: Text('Удалить')),
                          ],
                        ),
                        onTap: () async {
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
                        },
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createCollection,
        icon: const Icon(Icons.add),
        label: const Text('Новая коллекция'),
      ),
    );
  }

  Future<void> _createCollection() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _CreateCollectionDialog(),
    );

    if (!mounted || name == null || name.isEmpty) return;

    await ref.read(collectionServiceProvider).createNewCollection(name);
    if (!mounted) return;
    ref.invalidate(collectionsProvider);
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

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    Navigator.pop(context, value);
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
          labelText: 'Название',
          hintText: 'Например: Мои монеты',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Создать'),
        ),
      ],
    );
  }
}
