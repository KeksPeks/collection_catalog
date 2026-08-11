import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/catalog_template_registry.dart';
import '../../../collections/domain/entities/collection.dart';
import '../../../collections/presentation/providers/collection_provider.dart';
import '../../../collections/presentation/providers/collection_service_provider.dart';
import '../../../fields/domain/entities/field_definition.dart';

/// Экран готовых шаблонов каталогов.
class CatalogTemplatesPage extends ConsumerWidget {
  const CatalogTemplatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = CatalogTemplateRegistry.all;
    return Scaffold(
      appBar: AppBar(title: const Text('Шаблоны каталогов')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: templates.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final template = templates[index];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.category)),
              title: Text(template.name),
              subtitle: Text('${template.description}\n${template.fields.length} полей'),
              isThreeLine: true,
              trailing: const Icon(Icons.add_circle_outline),
              onTap: () => _create(context, ref, template),
            ),
          );
        },
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref, dynamic template) async {
    final controller = TextEditingController(text: template.name);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Новая коллекция'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()), child: const Text('Создать')),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty || !context.mounted) return;

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final collection = Collection(
      id: id,
      name: name,
      templateId: template.id,
      fields: (template.fields as List<FieldDefinition>).map((f) => f.copyWith(collectionId: id)).toList(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await ref.read(collectionServiceProvider).createCollection(collection);
    ref.invalidate(collectionsProvider);
    if (context.mounted) Navigator.pop(context, collection);
  }
}
