import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../collections/domain/entities/collection.dart';
import '../../../collections/presentation/pages/collection_detail_page.dart';
import '../../../collections/presentation/providers/collection_provider.dart';
import '../../../collections/presentation/providers/collection_service_provider.dart';
import '../../../fields/domain/entities/field_definition.dart';
import '../../../fields/presentation/providers/field_service_provider.dart';
import '../../domain/entities/template.dart';
import '../../domain/services/built_in_template_registry.dart';

/// Панель управления каталогами и готовыми шаблонами.
class CatalogAdminPage extends ConsumerWidget {
  const CatalogAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(collectionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Администратор каталогов')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Готовые шаблоны', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Создаёт настоящий каталог с полями. После создания он сразу появляется в основном каталоге.'),
          const SizedBox(height: 12),
          ...BuiltInTemplateRegistry.templates.map((template) => Card(
                child: ListTile(
                  leading: const Icon(Icons.auto_awesome),
                  title: Text(template.name),
                  subtitle: Text(template.description),
                  trailing: const Icon(Icons.add_circle_outline),
                  onTap: () => _create(context, ref, template),
                ),
              )),
          const SizedBox(height: 24),
          Text('Существующие каталоги', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          collections.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text(error.toString()),
            data: (items) => items.isEmpty
                ? const Card(child: ListTile(title: Text('Каталогов пока нет')))
                : Column(
                    children: items.map((collection) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.collections_bookmark),
                        title: Text(collection.name),
                        subtitle: Text(collection.templateId ?? 'Пользовательский каталог'),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => CollectionDetailPage(
                            collectionId: collection.id,
                            collectionName: collection.name,
                          ),
                        )),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Удалить',
                          onPressed: () => _delete(context, ref, collection),
                        ),
                      ),
                    )).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref, Template template) async {
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _CreateCatalogDialog(template: template),
    );
    if (!context.mounted || name == null || name.trim().isEmpty) return;

    final now = DateTime.now();
    final collection = Collection(
      id: '${template.id}_${now.microsecondsSinceEpoch}',
      name: name.trim(),
      templateId: template.id,
      createdAt: now,
      updatedAt: now,
    );
    await ref.read(collectionServiceProvider).createCollection(collection);
    final fieldService = await ref.read(fieldServiceProvider.future);
    for (final field in template.fields) {
      await fieldService.addField(FieldDefinition(
        id: '${collection.id}_${field.id}',
        collectionId: collection.id,
        label: field.label,
        type: field.type,
      ));
    }
    ref.invalidate(collectionsProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Каталог «${collection.name}» создан')));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Collection collection) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить каталог?'),
        content: Text(collection.name),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Удалить')),
        ],
      ),
    );
    if (!context.mounted || ok != true) return;
    await ref.read(collectionServiceProvider).deleteCollection(collection.id);
    ref.invalidate(collectionsProvider);
  }
}

class _CreateCatalogDialog extends StatefulWidget {
  final Template template;
  const _CreateCatalogDialog({required this.template});

  @override
  State<_CreateCatalogDialog> createState() => _CreateCatalogDialogState();
}

class _CreateCatalogDialogState extends State<_CreateCatalogDialog> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.template.name);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Создать каталог «${widget.template.name}»'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Название каталога'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
        FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Создать')),
      ],
    );
  }
}
