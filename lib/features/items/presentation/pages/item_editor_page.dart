import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../collections/domain/entities/collection.dart';
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
  ConsumerState<ItemEditorPage> createState() =>
      _ItemEditorPageState();
}

class _ItemEditorPageState extends ConsumerState<ItemEditorPage> {
  /// Введённые пользователем значения полей.
  final Map<String, String> values = {};

  bool _saving = false;

  Future<void> _save() async {
    if (_saving) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final creator = ItemCreator();
      final item = creator.create(
        collectionId: widget.collection.id,
      );

      final service = ref.read(
        itemServiceProvider,
      );

      await service.saveItem(item);

      for (final entry in values.entries) {
        final value = entry.value.trim();

        if (value.isEmpty) {
          continue;
        }

        final itemValue = ItemValue(
          id: '${item.id}_${entry.key}',
          itemId: item.id,
          fieldId: entry.key,
          value: value,
        );

        await service.saveValue(itemValue);
      }

      ref.invalidate(
        itemsProvider(
          widget.collection.id,
        ),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Новый предмет',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.collection.fields.isEmpty)
            const Text(
              'У коллекции нет полей',
            )
          else
            ...widget.collection.fields.map(
              (field) {
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: field.label,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      values[field.id] = value;
                    },
                  ),
                );
              },
            ),
          const SizedBox(
            height: 20,
          ),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(),
                  )
                : const Text(
                    'Сохранить',
                  ),
          ),
        ],
      ),
    );
  }
}
