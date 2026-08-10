import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../fields/domain/entities/field_definition.dart';
import '../../../fields/presentation/providers/field_provider.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/item_value.dart';
import '../providers/item_provider.dart';
import '../providers/item_service_provider.dart';

/// Страница редактирования предмета коллекции.
class ItemEditPage extends ConsumerStatefulWidget {
  final Item item;

  const ItemEditPage({
    super.key,
    required this.item,
  });

  @override
  ConsumerState<ItemEditPage> createState() => _ItemEditPageState();
}

class _ItemEditPageState extends ConsumerState<ItemEditPage> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _valueIds = {};
  bool _initialized = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeControllers(
    List<FieldDefinition> fields,
    List<ItemValue> values,
  ) {
    if (_initialized) {
      return;
    }

    final valuesByField = <String, ItemValue>{
      for (final value in values) value.fieldId: value,
    };

    for (final field in fields) {
      final existing = valuesByField[field.id];
      _controllers[field.id] = TextEditingController(
        text: existing?.value ?? '',
      );

      if (existing != null) {
        _valueIds[field.id] = existing.id;
      }
    }

    _initialized = true;
  }

  Future<void> _save(List<FieldDefinition> fields) async {
    final service = ref.read(itemServiceProvider);

    for (final field in fields) {
      final value = _controllers[field.id]?.text.trim() ?? '';
      final existingId = _valueIds[field.id];

      if (existingId != null) {
        await service.updateValue(
          ItemValue(
            id: existingId,
            itemId: widget.item.id,
            fieldId: field.id,
            value: value,
          ),
        );
      } else if (value.isNotEmpty) {
        final id = DateTime.now().microsecondsSinceEpoch.toString();

        await service.saveValue(
          ItemValue(
            id: id,
            itemId: widget.item.id,
            fieldId: field.id,
            value: value,
          ),
        );

        _valueIds[field.id] = id;
      }
    }

    ref.invalidate(itemProvider(widget.item.id));
    ref.invalidate(itemValuesProvider(widget.item.id));

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final fieldsAsync = ref.watch(
      fieldsProvider(widget.item.collectionId),
    );
    final valuesAsync = ref.watch(
      itemValuesProvider(widget.item.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Изменить предмет'),
      ),
      body: fieldsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text(error.toString()),
        ),
        data: (fields) {
          return valuesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Center(
              child: Text(error.toString()),
            ),
            data: (values) {
              _initializeControllers(fields, values);

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (fields.isEmpty)
                    const Text('У коллекции нет полей')
                  else
                    ...fields.map(
                      (field) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextField(
                          controller: _controllers[field.id],
                          decoration: InputDecoration(
                            labelText: field.label,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => _save(fields),
                    child: const Text('Сохранить'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
