import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/catalog_template_registry.dart';
import '../../domain/entities/template.dart';
import '../../../collections/domain/entities/collection.dart';
import '../../../collections/presentation/providers/collection_provider.dart';
import '../../../collections/presentation/providers/collection_service_provider.dart';
import '../../../fields/domain/entities/field_definition.dart';
import '../../../fields/presentation/providers/field_service_provider.dart';

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
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final template = templates[index];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.category)),
              title: Text(template.name),
              subtitle: Text(
                '${template.description}\n${template.fields.length} полей',
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.add_circle_outline),
              onTap: () => _create(context, ref, template),
            ),
          );
        },
      ),
    );
  }

  Future<void> _create(
    BuildContext context,
    WidgetRef ref,
    Template template,
  ) async {
    final controller = TextEditingController(text: template.name);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Новая коллекция'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Название'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              controller.text.trim(),
            ),
            child: const Text('Создать'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (name == null || name.isEmpty || !context.mounted) return;

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final fields = <FieldDefinition>[
      for (final field in template.fields)
        field.copyWith(
          id: '${id}_${field.id}',
          collectionId: id,
        ),
    ];
    final now = DateTime.now();
    final collection = Collection(
      id: id,
      name: name,
      templateId: template.id,
      fields: fields,
      createdAt: now,
      updatedAt: now,
    );

    try {
      final collectionService = ref.read(collectionServiceProvider);
      final fieldService = await ref.read(fieldServiceProvider.future);
      await collectionService.createCollection(collection);
      for (final field in fields) {
        await fieldService.addField(field);
      }
      ref.invalidate(collectionsProvider);
      if (!context.mounted) return;
      Navigator.pop(context, collection);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось создать каталог: $error')),
      );
    }
  }
}
