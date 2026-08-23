import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../catalogs/data/favorites_store.dart';
import '../../../fields/presentation/providers/field_provider.dart';
import '../../data/item_state_store.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/item_attachment.dart';
import '../../domain/entities/item_value.dart';
import '../providers/item_attachment_provider.dart';
import '../providers/item_provider.dart';
import 'catalog_item_instances_page.dart';

/// Карточка физического экземпляра.
///
/// Структура каталога и его поля только для чтения. Личные данные
/// принадлежат конкретному физическому экземпляру.
class ItemDetailPage extends ConsumerStatefulWidget {
  final String itemId;
  const ItemDetailPage({super.key, required this.itemId});

  @override
  ConsumerState<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends ConsumerState<ItemDetailPage> {
  ItemState _state = ItemState(updatedAt: DateTime.now());
  bool _favorite = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final state = await ItemStateStore.load(widget.itemId);
    final favorite =
        await FavoritesStore.containsKey(FavoritesStore.itemKey(widget.itemId));
    if (!mounted) return;
    setState(() {
      _state = state;
      _favorite = favorite;
    });
  }

  Future<void> _save(Item item, ItemState state) async {
    setState(() => _saving = true);
    try {
      final updated = state.copyWith(updatedAt: DateTime.now());
      await ItemStateStore.save(widget.itemId, updated, title: item.id);
      if (!mounted) return;
      setState(() {
        _state = updated;
        _saving = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сохранения: $error')),
      );
    }
  }

  Future<void> _toggleFavorite() async {
    final ids = await FavoritesStore.toggleKey(
      FavoritesStore.itemKey(widget.itemId),
    );
    if (!mounted) return;
    setState(() {
      _favorite = ids.contains(FavoritesStore.itemKey(widget.itemId));
    });
  }

  Future<void> _openInstances(Item item) async {
    if (item.catalogItemId == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CatalogItemInstancesPage(
          catalogItemId: item.catalogItemId!,
          collectionId: item.collectionId,
          title: 'Экземпляры',
        ),
      ),
    );
    if (!mounted) return;
    ref.invalidate(catalogItemInstancesProvider(item.catalogItemId!));
  }

  @override
  Widget build(BuildContext context) {
    final itemAsync = ref.watch(itemProvider(widget.itemId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Экземпляр'),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              _favorite ? Icons.star_rounded : Icons.star_border_rounded,
            ),
          ),
        ],
      ),
      body: itemAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (item) {
          if (item == null) {
            return const Center(child: Text('Экземпляр не найден'));
          }

          final valuesAsync = ref.watch(itemValuesProvider(item.id));
          final attachmentsAsync = ref.watch(itemAttachmentsProvider(item.id));
          final fieldsAsync = ref.watch(fieldsProvider(item.collectionId));
          final instancesAsync = item.catalogItemId == null
              ? null
              : ref.watch(catalogItemInstancesProvider(item.catalogItemId!));

          return fieldsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text(error.toString())),
            data: (fields) {
              final labels = {for (final field in fields) field.id: field.label};

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.inventory_2_outlined),
                      title: Text('Экземпляр'),
                      subtitle: Text(
                        'ID: ${item.id}\nКаталожная позиция: ${item.catalogItemId ?? 'не связана'}',
                      ),
                    ),
                  ),
                  if (item.catalogItemId != null) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.copy_all_outlined),
                        title: const Text('Экземпляры этой позиции'),
                        subtitle: instancesAsync == null
                            ? null
                            : instancesAsync.when(
                                loading: () => const Text('Загрузка...'),
                                error: (error, _) => Text('Ошибка: $error'),
                                data: (items) => Text(
                                  'В коллекции: ${items.length}',
                                ),
                              ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openInstances(item),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _PersonalStateCard(
                    state: _state,
                    saving: _saving,
                    onChanged: (value) => _save(item, value),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Поля каталога (только чтение)',
                    child: valuesAsync.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (error, _) => Text(error.toString()),
                      data: (values) => values.isEmpty
                          ? const Text('Нет заполненных полей')
                          : Column(
                              children: values
                                  .map(
                                    (value) => _ValueTile(
                                      value: value,
                                      label: labels[value.fieldId] ?? value.fieldId,
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _AttachmentsCard(attachmentsAsync: attachmentsAsync),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _PersonalStateCard extends StatelessWidget {
  final ItemState state;
  final bool saving;
  final ValueChanged<ItemState> onChanged;

  const _PersonalStateCard({
    required this.state,
    required this.saving,
    required this.onChanged,
  });

  Future<void> _editNote(BuildContext context) async {
    final controller = TextEditingController(text: state.note);
    final note = await showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Личная заметка'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, controller.text.trim()),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (note != null) onChanged(state.copyWith(note: note));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Моё состояние экземпляра',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                if (saving)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<CollectionItemStatus>(
              initialValue: state.status,
              decoration: const InputDecoration(
                labelText: 'Статус',
                border: OutlineInputBorder(),
              ),
              items: CollectionItemStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.title),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  onChanged(
                    state.copyWith(
                      status: value,
                      quantity: value == CollectionItemStatus.missing
                          ? 0
                          : (state.quantity == 0 ? 1 : state.quantity),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: state.quantity.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Количество',
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (value) => onChanged(
                      state.copyWith(
                        quantity: int.tryParse(value) ?? state.quantity,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    initialValue: state.condition,
                    decoration: const InputDecoration(
                      labelText: 'Состояние',
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (value) => onChanged(
                      state.copyWith(condition: value.trim()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    state.purchaseDate == null
                        ? 'Дата покупки не указана'
                        : 'Куплено: ${state.purchaseDate!.toLocal().toString().split(' ').first}',
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      initialDate: state.purchaseDate ?? DateTime.now(),
                    );
                    if (date != null) {
                      onChanged(state.copyWith(purchaseDate: date));
                    }
                  },
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: const Text('Дата'),
                ),
              ],
            ),
            TextFormField(
              initialValue: state.purchasePrice?.toString() ?? '',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Цена покупки',
                prefixText: '€ ',
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (value) => onChanged(
                state.copyWith(
                  purchasePrice: double.tryParse(value.replaceAll(',', '.')),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.note_alt_outlined),
              title: Text(
                state.note.isEmpty ? 'Добавить заметку' : state.note,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _editNote(context),
            ),
          ],
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
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _ValueTile extends StatelessWidget {
  final ItemValue value;
  final String label;

  const _ValueTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value.value),
    );
  }
}

class _AttachmentsCard extends StatelessWidget {
  final AsyncValue<List<ItemAttachment>> attachmentsAsync;

  const _AttachmentsCard({required this.attachmentsAsync});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Вложения',
      child: attachmentsAsync.when(
        loading: () => const CircularProgressIndicator(),
        error: (error, _) => Text(error.toString()),
        data: (items) => items.isEmpty
            ? const Text('Вложений нет')
            : Column(
                children: items
                    .map(
                      (item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(_icon(item.type)),
                        title: Text(item.path),
                        subtitle: Text(item.type),
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }

  static IconData _icon(String type) {
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
