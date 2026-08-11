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

/// Страница управления коллекцией: поля и предметы.
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
    final fieldsAsync = ref.watch(fieldsProvider(collectionId));
    final itemsAsync = ref.watch(itemsProvider(collectionId));
    final collectionAsync = ref.watch(collectionProvider(collectionId));

    return Scaffold(
      appBar: AppBar(title: Text(collectionName)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(fieldsProvider(collectionId));
          ref.invalidate(itemsProvider(collectionId));
          ref.invalidate(collectionProvider(collectionId));
        },
        child: fieldsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(error.toString()),
              ),
            ],
          ),
          data: (fields) {
            final stored = collectionAsync.valueOrNull;
            final collection = stored?.copyWith(fields: fields) ??
                Collection(
                  id: collectionId,
                  name: collectionName,
                  fields: fields,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    title: Text(collectionName),
                    subtitle: itemsAsync.when(
                      loading: () => Text('Полей: ${fields.length} · Предметов: ...'),
                      error: (_, __) => Text('Полей: ${fields.length} · Ошибка предметов'),
                      data: (items) => Text('Полей: ${fields.length} · Предметов: ${items.length}'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Предметы',
                  child: itemsAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text(error.toString()),
                    data: (items) {
                      if (items.isEmpty) return const Text('Предметов пока нет');
                      return Column(
                        children: items.map((item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.inventory_2_outlined),
                          title: Text('Предмет ${item.id}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ItemDetailPage(itemId: item.id),
                              ),
                            );
                            if (!context.mounted) return;
                            ref.invalidate(itemsProvider(collectionId));
                          },
                        )).toList(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Поля',
                  child: Column(
                    children: [
                      if (fields.isEmpty)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Поля отсутствуют'),
                        )
                      else
                        ...fields.map((field) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(field.label),
                          subtitle: Text(field.type.name),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => EditFieldPage(field: field),
                                  ),
                                );
                                if (!context.mounted) return;
                                ref.invalidate(fieldsProvider(collectionId));
                              } else if (value == 'delete') {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    title: const Text('Удалить поле?'),
                                    content: Text(field.label),
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
                                final service = await ref.read(fieldServiceProvider.future);
                                await service.deleteField(field.id);
                                if (!context.mounted) return;
                                ref.invalidate(fieldsProvider(collectionId));
                                ref.invalidate(itemsProvider(collectionId));
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Изменить')),
                              PopupMenuItem(value: 'delete', child: Text('Удалить')),
                            ],
                          ),
                        )),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'item-$collectionId',
            icon: const Icon(Icons.add_box_outlined),
            label: const Text('Предмет'),
            onPressed: () async {
              final fields = ref.read(fieldsProvider(collectionId)).valueOrNull ?? [];
              final stored = ref.read(collectionProvider(collectionId)).valueOrNull;
              final collection = stored?.copyWith(fields: fields) ??
                  Collection(
                    id: collectionId,
                    name: collectionName,
                    fields: fields,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ItemEditorPage(collection: collection),
                ),
              );
              if (!context.mounted) return;
              ref.invalidate(itemsProvider(collectionId));
            },
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'field-$collectionId',
            icon: const Icon(Icons.add),
            label: const Text('Поле'),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddFieldPage(collectionId: collectionId),
                ),
              );
              if (!context.mounted) return;
              ref.invalidate(fieldsProvider(collectionId));
            },
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
