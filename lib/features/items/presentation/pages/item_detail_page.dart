import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../fields/presentation/providers/field_provider.dart';
import '../../domain/entities/item_attachment.dart';
import '../../domain/entities/item_value.dart';
import '../providers/item_attachment_provider.dart';
import '../providers/item_provider.dart';

/// Страница просмотра предмета коллекции.
///
/// Данные каталога и вложения доступны только для просмотра. Пользователь
/// не может редактировать запись, добавлять или удалять файлы каталога.
class ItemDetailPage extends ConsumerWidget {
  final String itemId;

  const ItemDetailPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemProvider(itemId));

    return Scaffold(
      appBar: AppBar(title: const Text('Предмет')),
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
                        return Column(
                          children: values
                              .map((value) => _ValueTile(value: value, label: labels[value.fieldId] ?? value.fieldId))
                              .toList(),
                        );
                      },
                      loading: () => const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
                      error: (error, _) => Text(error.toString()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AttachmentsCard(attachmentsAsync: attachmentsAsync),
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

class _AttachmentsCard extends StatelessWidget {
  final AsyncValue<List<ItemAttachment>> attachmentsAsync;

  const _AttachmentsCard({required this.attachmentsAsync});

  @override
  Widget build(BuildContext context) => _SectionCard(
        title: 'Вложения',
        child: attachmentsAsync.when(
          loading: () => const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
          error: (error, _) => Text(error.toString()),
          data: (attachments) {
            if (attachments.isEmpty) return const Align(alignment: Alignment.centerLeft, child: Text('Вложений нет'));
            return Column(
              children: attachments
                  .map(
                    (attachment) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(_attachmentIcon(attachment.type)),
                      title: Text(attachment.path),
                      subtitle: Text(attachment.type),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      );

  static IconData _attachmentIcon(String type) {
    switch (type) {
      case 'image':
        return Icons.image_outlined;
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'video':
        return Icons.video_file_outlined;
      case 'archive':
        return Icons.archive_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }
}
