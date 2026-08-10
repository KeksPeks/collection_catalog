import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../fields/presentation/pages/add_field_page.dart';
import '../../../fields/presentation/pages/edit_field_page.dart';
import '../../../fields/presentation/providers/field_provider.dart';
import '../../../fields/presentation/providers/field_service_provider.dart';
import '../../../items/presentation/pages/item_detail_page.dart';
import '../../../items/presentation/pages/item_editor_page.dart';
import '../../../items/presentation/providers/item_provider.dart';
import '../../domain/entities/collection.dart';
import '../providers/collection_provider.dart';

/// Страница просмотра коллекции, её полей и предметов.
class CollectionDetailPage extends ConsumerStatefulWidget {
  final String collectionId;
  final String collectionName;

  const CollectionDetailPage({
    super.key,
    required this.collectionId,
    required this.collectionName,
  });

  @override
  ConsumerState<CollectionDetailPage> createState() =>
      _CollectionDetailPageState();
}

class _CollectionDetailPageState extends ConsumerState<CollectionDetailPage> {
  Future<bool> _confirmDelete(String name) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить поле?'),
          content: Text(name),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _openNewItem(List<dynamic> fields) async {
    final storedCollection = await ref
        .read(collectionProvider(widget.collectionId).future);

    if (!mounted || storedCollection == null) {
      return;
    }

    final collection = storedCollection.copyWith(
      fields: fields.cast(),
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemEditorPage(collection: collection),
      ),
    );

    if (!mounted) {
      return;
    }

    ref.invalidate(itemsProvider(widget.collectionId));
  }

  @override
  Widget build(BuildContext context) {
    final fieldsAsync = ref.watch(fieldsProvider(widget.collectionId));
    final itemsAsync = ref.watch(itemsProvider(widget.collectionId));

    return Scaffold(
      appBar: AppBar(title: Text(widget.collectionName)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(fieldsProvider(widget.collectionId));
          ref.invalidate(itemsProvider(widget.collectionId));
        },
        child: fieldsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text(error.toString())),
          data: (fields) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.collectionName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Text('Количество полей: ${fields.length}'),
                        const SizedBox(height: 6),
                        Text('Коллекция: ${widget.collectionId}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Поля',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (fields.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text('Поля отсутствуют')),
                  )
                else
                  ...fields.map(
                    (field) => Card(
                      child: ListTile(
                        title: Text(field.label),
                        subtitle: Text(field.type.name),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditFieldPage(field: field),
                                ),
                              );

                              if (!mounted) return;
                              ref.invalidate(fieldsProvider(widget.collectionId));
                            }

                            if (value == 'delete') {
                              final confirm = await _confirmDelete(field.label);
                              if (!mounted) return;

                              if (confirm) {
                                final service = await ref.read(
                                  fieldServiceProvider.future,
                                );
                                await service.deleteField(field.id);

                                if (!mounted) return;
                                ref.invalidate(
                                  fieldsProvider(widget.collectionId),
                                );
                              }
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
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Предметы',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _openNewItem(fields),
                      icon: const Icon(Icons.add),
                      label: const Text('Добавить'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                itemsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => Text(error.toString()),
                  data: (items) {
                    if (items.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: Text('Предметов пока нет')),
                      );
                    }

                    return Column(
                      children: items.map((item) {
                        final valuesAsync = ref.watch(
                          itemValuesProvider(item.id),
                        );

                        return Card(
                          child: valuesAsync.when(
                            loading: () => ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.inventory_2_outlined),
                              ),
                              title: const Text('Загрузка...'),
                              subtitle: Text('ID: ${item.id}'),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ItemDetailPage(
                                      itemId: item.id,
                                    ),
                                  ),
                                );

                                if (!mounted) return;
                                ref.invalidate(itemValuesProvider(item.id));
                                ref.invalidate(
                                  itemsProvider(widget.collectionId),
                                );
                              },
                            ),
                            error: (error, stack) => ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.inventory_2_outlined),
                              ),
                              title: const Text('Предмет'),
                              subtitle: Text('ID: ${item.id}'),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ItemDetailPage(
                                      itemId: item.id,
                                    ),
                                  ),
                                );

                                if (!mounted) return;
                                ref.invalidate(itemValuesProvider(item.id));
                                ref.invalidate(
                                  itemsProvider(widget.collectionId),
                                );
                              },
                            ),
                            data: (values) {
                              final summary = values
                                  .map((value) => value.value.trim())
                                  .where((value) => value.isNotEmpty)
                                  .take(2)
                                  .join(' • ');

                              return ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.inventory_2_outlined),
                                ),
                                title: Text(
                                  summary.isEmpty ? 'Предмет' : summary,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  summary.isEmpty
                                      ? 'Нет заполненных значений • ID: ${item.id}'
                                      : 'ID: ${item.id}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ItemDetailPage(
                                        itemId: item.id,
                                      ),
                                    ),
                                  );

                                  if (!mounted) return;
                                  ref.invalidate(itemValuesProvider(item.id));
                                  ref.invalidate(
                                    itemsProvider(widget.collectionId),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddFieldPage(
                collectionId: widget.collectionId,
              ),
            ),
          );

          if (!mounted) return;
          ref.invalidate(fieldsProvider(widget.collectionId));
        },
      ),
    );
  }
}
