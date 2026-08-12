import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../fields/presentation/providers/field_provider.dart';
import '../../domain/entities/item_attachment.dart';
import '../../domain/entities/item_value.dart';
import '../providers/item_attachment_provider.dart';
import '../providers/item_provider.dart';
import '../providers/item_service_provider.dart';
import 'item_edit_page.dart';

/// Страница просмотра предмета коллекции.
class ItemDetailPage extends ConsumerWidget {
  final String itemId;

  const ItemDetailPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemProvider(itemId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Предмет'),
        actions: [
          itemAsync.when(
            data: (item) {
              if (item == null) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Изменить',
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ItemEditPage(item: item)),
                  );
                  ref.invalidate(itemProvider(item.id));
                  ref.invalidate(itemValuesProvider(item.id));
                  ref.invalidate(itemAttachmentsProvider(item.id));
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: itemAsync.when(
        data: (item) {
          if (item == null) return const Center(child: Text('Предмет не найден'));
          final valuesAsync = ref.watch(itemValuesProvider(item.id));
          final attachmentsAsync = ref.watch(itemAttachmentsProvider(item.id));
          final fieldsAsync = ref.watch(fieldsProvider(item.collectionId));

          return fieldsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text(error.toString())),
            data: (fields) {
              final labels = {for (final field in fields) field.id: field.label};
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Предмет', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 12),
                          Text('ID: ${item.id}'),
                          const SizedBox(height: 6),
                          Text('Коллекция: ${item.collectionId}'),
                          const SizedBox(height: 6),
                          Text('Раздел: ${item.sectionId ?? "Нет"}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Поля',
                    child: valuesAsync.when(
                      data: (values) {
                        if (values.isEmpty) return const Text('Нет заполненных полей');
                        return Column(children: values.map((value) => _ValueTile(value: value, label: labels[value.fieldId] ?? value.fieldId)).toList());
                      },
                      loading: () => const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
                      error: (error, _) => Text(error.toString()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AttachmentsCard(itemId: item.id, attachmentsAsync: attachmentsAsync),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
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
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ]),
        ),
      );
}

class _ValueTile extends StatelessWidget {
  final ItemValue value;
  final String label;
  const _ValueTile({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label),
        subtitle: Text(value.value),
      );
}

class _AttachmentsCard extends ConsumerWidget {
  final String itemId;
  final AsyncValue<List<ItemAttachment>> attachmentsAsync;
  const _AttachmentsCard({required this.itemId, required this.attachmentsAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) => _SectionCard(
        title: 'Вложения',
        child: attachmentsAsync.when(
          loading: () => const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
          error: (error, _) => Text(error.toString()),
          data: (attachments) => Column(
            children: [
              if (attachments.isEmpty)
                const Align(alignment: Alignment.centerLeft, child: Text('Вложений нет'))
              else
                ...attachments.map(
                  (attachment) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(_attachmentIcon(attachment.type)),
                    title: Text(attachment.path),
                    subtitle: Text(attachment.type),
                    trailing: IconButton(
                      tooltip: 'Удалить',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        await ref.read(itemServiceProvider).deleteAttachment(attachment.id);
                        ref.invalidate(itemAttachmentsProvider(itemId));
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => _addAttachment(context, ref),
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Добавить файл'),
                ),
              ),
            ],
          ),
        ),
      );

  Future<void> _addAttachment(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<_AttachmentInput>(context: context, builder: (_) => const _AttachmentDialog());
    if (result == null || result.path.isEmpty) return;
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await ref.read(itemServiceProvider).saveAttachment(ItemAttachment(id: id, itemId: itemId, path: result.path, type: result.type));
    ref.invalidate(itemAttachmentsProvider(itemId));
  }

  static IconData _attachmentIcon(String type) {
    switch (type) {
      case 'image': return Icons.image_outlined;
      case 'pdf': return Icons.picture_as_pdf_outlined;
      case 'video': return Icons.video_file_outlined;
      case 'archive': return Icons.archive_outlined;
      default: return Icons.insert_drive_file_outlined;
    }
  }
}

class _AttachmentInput {
  final String path;
  final String type;
  const _AttachmentInput({required this.path, required this.type});
}

class _AttachmentDialog extends StatefulWidget {
  const _AttachmentDialog();
  @override
  State<_AttachmentDialog> createState() => _AttachmentDialogState();
}

class _AttachmentDialogState extends State<_AttachmentDialog> {
  final TextEditingController _pathController = TextEditingController();
  String _type = 'file';

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Добавить вложение'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _pathController, decoration: const InputDecoration(labelText: 'Путь к файлу', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Тип', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'file', child: Text('Файл')),
                DropdownMenuItem(value: 'image', child: Text('Изображение')),
                DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                DropdownMenuItem(value: 'video', child: Text('Видео')),
                DropdownMenuItem(value: 'archive', child: Text('Архив')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _type = value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              final path = _pathController.text.trim();
              if (path.isEmpty) return;
              Navigator.pop(context, _AttachmentInput(path: path, type: _type));
            },
            child: const Text('Добавить'),
          ),
        ],
      );
}
