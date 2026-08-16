import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../feedback/presentation/feedback_page.dart';
import '../../../items/presentation/pages/item_detail_page.dart';
import '../../../items/presentation/pages/items_page.dart';
import '../../../items/presentation/providers/item_provider.dart';
import '../../../templates/data/catalog_template_registry.dart';
import '../../../fields/presentation/providers/field_provider.dart';
import '../../domain/entities/collection.dart';
import '../providers/collection_provider.dart';

/// Страница просмотра загруженной коллекции.
///
/// Структура каталога, поля и записи являются данными каталога и не могут
/// изменяться пользователем. Для предложений используется обратная связь.
class CollectionDetailPage extends ConsumerWidget {
  final String collectionId;
  final String collectionName;

  const CollectionDetailPage({super.key, required this.collectionId, required this.collectionName});

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
          error: (error, _) => ListView(children: [Padding(padding: const EdgeInsets.all(24), child: Text(error.toString()))]),
          data: (fields) {
            final stored = collectionAsync.valueOrNull;
            final collection = stored?.copyWith(fields: fields) ?? Collection(
              id: collectionId,
              name: collectionName,
              fields: fields,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            final storedTemplateId = stored?.templateId;
            final template = storedTemplateId == null ? null : CatalogTemplateRegistry.byId(storedTemplateId);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.lock_outline_rounded),
                    title: Text(collectionName, style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: itemsAsync.when(
                      loading: () => Text('Полей: ${fields.length} · Предметов: ...'),
                      error: (_, _) => Text('Полей: ${fields.length} · Ошибка предметов'),
                      data: (items) => Text('Полей: ${fields.length} · Предметов: ${items.length}'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Каталог доступен только для просмотра.', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        const Text('Если нужно добавить запись, исправить данные или расширить структуру, отправьте предложение через обратную связь.'),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FeedbackPage())),
                          icon: const Icon(Icons.feedback_outlined),
                          label: const Text('Предложить изменение'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ItemsPage(collection: collection)),
                  ),
                  icon: const Icon(Icons.view_list),
                  label: const Text('Открыть весь каталог'),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Предметы',
                  child: itemsAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (error, _) => Text(error.toString()),
                    data: (items) {
                      if (items.isEmpty) return const Text('Предметов пока нет');
                      return Column(
                        children: items.take(8).map((item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.inventory_2_outlined),
                          title: Text('Предмет ${item.id}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ItemDetailPage(itemId: item.id)),
                          ),
                        )).toList(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Поля каталога',
                  child: Column(
                    children: [
                      if (fields.isEmpty)
                        const Align(alignment: Alignment.centerLeft, child: Text('Поля отсутствуют'))
                      else
                        ...fields.map((field) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.label_outline),
                          title: Text(field.label),
                          subtitle: Text(field.type.name),
                        )),
                    ],
                  ),
                ),
                if (template != null) ...[
                  const SizedBox(height: 12),
                  Text('Источник: ${template.name}', style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Card(
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
