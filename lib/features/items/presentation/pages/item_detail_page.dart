import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../catalogs/data/favorites_store.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../fields/presentation/providers/field_provider.dart';
import '../../data/item_state_store.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/item_value.dart';
import '../providers/item_attachment_provider.dart';
import '../providers/item_provider.dart';
import 'catalog_item_instances_page.dart';

/// Карточка физического экземпляра. Каталожные данные доступны только для чтения.
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
    _load();
  }

  Future<void> _load() async {
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
      final next = state.copyWith(updatedAt: DateTime.now());
      await ItemStateStore.save(widget.itemId, next, title: item.id);
      if (!mounted) return;
      setState(() {
        _state = next;
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
    final ids =
        await FavoritesStore.toggleKey(FavoritesStore.itemKey(widget.itemId));
    if (!mounted) return;
    setState(
      () => _favorite = ids.contains(FavoritesStore.itemKey(widget.itemId)),
    );
  }

  Future<void> _openInstances(Item item) async {
    final catalogItemId = item.catalogItemId;
    if (catalogItemId == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CatalogItemInstancesPage(
          catalogItemId: catalogItemId,
          collectionId: item.collectionId,
          title: 'Экземпляры',
        ),
      ),
    );
    if (mounted) ref.invalidate(catalogItemInstancesProvider(catalogItemId));
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
          final values = ref.watch(itemValuesProvider(item.id));
          final attachments = ref.watch(itemAttachmentsProvider(item.id));
          final fields = ref.watch(fieldsProvider(item.collectionId));
          final instances = item.catalogItemId == null
              ? null
              : ref.watch(catalogItemInstancesProvider(item.catalogItemId!));

          return fields.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text(error.toString())),
            data: (fieldList) {
              final labels = <String, String>{
                for (final field in fieldList) field.id: field.label,
              };
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.inventory_2_outlined),
                      title: const Text('Физический экземпляр'),
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
                        subtitle: instances == null
                            ? null
                            : instances.when(
                                loading: () => const Text('Загрузка...'),
                                error: (error, _) => Text('Ошибка: $error'),
                                data: (items) =>
                                    Text('В коллекции: ${items.length}'),
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
                    onChanged: (next) => _save(item, next),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Поля каталога (только чтение)',
                    child: values.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (error, _) => Text(error.toString()),
                      data: (list) => list.isEmpty
                          ? const Text('Нет заполненных полей')
                          : Column(
                              children: list
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
                  _SectionCard(
                    title: 'Вложения',
                    child: attachments.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (error, _) => Text(error.toString()),
                      data: (list) => list.isEmpty
                          ? const Text('Вложений нет')
                          : Column(
                              children: list
                                  .map(
                                    (attachment) => ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(
                                        Icons.insert_drive_file_outlined,
                                      ),
                                      title: Text(attachment.path),
                                      subtitle: Text(attachment.type),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
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
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Личная заметка'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value != null) onChanged(state.copyWith(note: value));
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context).locale.languageCode;
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
                      child: Text(status.localizedTitle(locale)),
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
            DropdownButtonFormField<CollectionItemCondition?>(
              initialValue: state.conditionValue,
              decoration: const InputDecoration(
                labelText: 'Состояние',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<CollectionItemCondition?>(
                  value: null,
                  child: Text('Не указано'),
                ),
                ...CollectionItemCondition.values.map(
                  (value) => DropdownMenuItem<CollectionItemCondition?>(
                    value: value,
                    child: Text(value.localizedTitle(locale)),
                  ),
                ),
              ],
              onChanged: (value) =>
                  onChanged(state.copyWith(condition: value?.name ?? '')),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: '${state.quantity}',
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
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Цена покупки',
                prefixText: '€ ',
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (value) => onChanged(
                state.copyWith(
                  purchasePrice:
                      double.tryParse(value.replaceAll(',', '.')),
                ),
              ),
            ),
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
  Widget build(BuildContext context) => Card(
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
