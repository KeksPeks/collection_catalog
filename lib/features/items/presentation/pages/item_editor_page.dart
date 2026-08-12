import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../collections/domain/entities/collection.dart';
import '../../../fields/presentation/components/field_component_registry.dart';
import '../../domain/entities/item_value.dart';
import '../../domain/services/item_creator.dart';
import '../providers/item_provider.dart';
import '../providers/item_service_provider.dart';

/// Страница создания нового предмета коллекции.
class ItemEditorPage extends ConsumerStatefulWidget {
  final Collection collection;

  const ItemEditorPage({
    super.key,
    required this.collection,
  });

  @override
  ConsumerState<ItemEditorPage> createState() => _ItemEditorPageState();
}

class _ItemEditorPageState extends ConsumerState<ItemEditorPage> {
  final Map<String, String> values = {};
  final FieldComponentRegistry _componentRegistry =
      const FieldComponentRegistry();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новый предмет'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.collection.fields.isEmpty)
            const Text('У коллекции нет полей')
          else
            ...widget.collection.fields.map(
              (field) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _componentRegistry.component(field.type).build(
                  definition: field,
                  value: values[field.id],
                  onChanged: (value) {
                    setState(() {
                      values[field.id] = value;
                    });
                  },
                ),
              ),
            ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _save,
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final creator = ItemCreator();
    final item = creator.create(
      collectionId: widget.collection.id,
    );
    final service = ref.read(itemServiceProvider);

    await service.saveItem(item);

    for (final entry in values.entries) {
      final value = entry.value.trim();

      if (value.isEmpty) {
        continue;
      }

      await service.saveValue(
        ItemValue(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          itemId: item.id,
          fieldId: entry.key,
          value: value,
        ),
      );
    }

    ref.invalidate(itemsProvider(widget.collection.id));

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }
}
