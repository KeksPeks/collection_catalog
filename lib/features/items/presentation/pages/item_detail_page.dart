import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../fields/presentation/providers/field_provider.dart';
import '../../domain/entities/item_attachment.dart';
import '../../domain/entities/item_value.dart';
import '../providers/item_attachment_provider.dart';
import '../providers/item_provider.dart';
import '../providers/item_service_provider.dart';

/// Страница просмотра и редактирования предмета коллекции.
class ItemDetailPage extends ConsumerStatefulWidget {
  final String itemId;

  const ItemDetailPage({
    super.key,
    required this.itemId,
  });

  @override
  ConsumerState<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends ConsumerState<ItemDetailPage> {
  final Map<String, TextEditingController> _controllers = {};
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _loadValues(List<dynamic> fields, List<ItemValue> values) {
    final valueMap = {
      for (final value in values) value.fieldId: value.value,
    };

    for (final field in fields) {
      final controller = _controllers.putIfAbsent(
        field.id,
        () => TextEditingController(),
      );

      if (controller.text.isEmpty && valueMap.containsKey(field.id)) {
        controller.text = valueMap[field.id]!;
      }
    }
  }

  Future<void> _save(String itemId, List<dynamic> fields) async {
    if (_saving) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final service = ref.read(itemServiceProvider);
      final existingValues = await service.getValues(itemId);
      final existingByField = {
        for (final value in existingValues) value.fieldId: value,
      };

      for (final field in fields) {
        final text = _controllers[field.id]?.text.trim() ?? '';
        final existing = existingByField[field.id];

        if (text.isEmpty) {
          if (existing != null) {
            await service.deleteValue(existing.id);
          }
          continue;
        }

        if (existing == null) {
          await service.saveValue(
            ItemValue(
              id: '${itemId}_${field.id}',
              itemId: itemId,
              fieldId: field.id,
              value: text,
            ),
          );
        } else {
          await service.updateValue(
            existing.copyWith(value: text),
          );
        }
      }

      ref.invalidate(itemValuesProvider(itemId));

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Изменения сохранены'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _addAttachment(String itemId) async {
    final pathController = TextEditingController();
    String type = 'file';

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Добавить вложение'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: pathController,
                    decoration: const InputDecoration(
                      labelText: 'Путь к файлу',
                      hintText: 'Например: C:\\Images\\coin.jpg',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: type,
                    decoration: const InputDecoration(
                      labelText: 'Тип',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'image', child: Text('Изображение')),
                      DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                      DropdownMenuItem(value: 'video', child: Text('Видео')),
                      DropdownMenuItem(value: 'archive', child: Text('Архив')),
                      DropdownMenuItem(value: 'file', child: Text('Файл')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          type = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Отмена'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Добавить'),
                ),
              ],
            );
          },
        );
      },
    );

    final path = pathController.text.trim();
    pathController.dispose();

    if (result != true || path.isEmpty || !mounted) {
      return;
    }

    final service = ref.read(itemServiceProvider);
    await service.saveAttachment(
      ItemAttachment(
        id: '${itemId}_${DateTime.now().microsecondsSinceEpoch}',
        itemId: itemId,
        path: path,
        type: type,
      ),
    );

    ref.invalidate(itemAttachmentsProvider(itemId));
  }

  Future<void> _deleteAttachment(ItemAttachment attachment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Удалить вложение?'),
          content: Text(attachment.path),
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
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await ref.read(itemServiceProvider).deleteAttachment(attachment.id);
    ref.invalidate(itemAttachmentsProvider(attachment.itemId));
  }

  Future<void> _deleteItem(String itemId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Удалить предмет?'),
          content: const Text(
            'Предмет, его значения полей и вложения будут удалены.',
          ),
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
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await ref.read(itemServiceProvider).deleteItem(itemId);

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemAsync = ref.watch(itemProvider(widget.itemId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Предмет'),
        actions: [
          IconButton(
            tooltip: 'Удалить предмет',
            onPressed: () => _deleteItem(widget.itemId),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: itemAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (item) {
          if (item == null) {
            return const Center(child: Text('Предмет не найден'));
          }

          final valuesAsync = ref.watch(itemValuesProvider(item.id));
          final fieldsAsync = ref.watch(fieldsProvider(item.collectionId));
          final attachmentsAsync = ref.watch(itemAttachmentsProvider(item.id));

          return fieldsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text(error.toString())),
            data: (fields) => valuesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text(error.toString())),
              data: (values) {
                _loadValues(fields, values);

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('ID: ${item.id}'),
                    const SizedBox(height: 8),
                    Text('Коллекция: ${item.collectionId}'),
                    const Divider(height: 32),
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
                    FilledButton(
                      onPressed: _saving ? null : () => _save(item.id, fields),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(),
                            )
                          : const Text('Сохранить'),
                    ),
                    const Divider(height: 32),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Вложения',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Добавить вложение',
                          onPressed: () => _addAttachment(item.id),
                          icon: const Icon(Icons.attach_file),
                        ),
                      ],
                    ),
                    attachmentsAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, stack) => Text(error.toString()),
                      data: (attachments) {
                        if (attachments.isEmpty) {
                          return const Text('Вложений нет');
                        }

                        return Column(
                          children: attachments
                              .map(
                                (attachment) => ListTile(
                                  leading: const Icon(Icons.insert_drive_file),
                                  title: Text(attachment.path),
                                  subtitle: Text(attachment.type),
                                  trailing: IconButton(
                                    tooltip: 'Удалить',
                                    onPressed: () =>
                                        _deleteAttachment(attachment),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
