import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../collections/domain/entities/collection.dart';
import '../../../fields/presentation/providers/field_provider.dart';
import '../../domain/entities/item.dart';
import '../providers/item_provider.dart';
import '../providers/item_service_provider.dart';
import 'item_detail_page.dart';
import 'item_editor_page.dart';

/// Полноценный список предметов коллекции.
///
/// Поддерживает поиск, сортировку, группировку и два режима отображения.
class ItemsPage extends ConsumerStatefulWidget {
  final Collection collection;

  const ItemsPage({
    super.key,
    required this.collection,
  });

  @override
  ConsumerState<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends ConsumerState<ItemsPage> {
  String search = '';
  String? sortField;
  String? groupField;
  bool descending = false;
  bool gridView = false;

  void _refresh() {
    if (!mounted) return;
    ref.invalidate(itemsProvider(widget.collection.id));
    ref.invalidate(collectionItemValuesProvider(widget.collection.id));
  }

  String _value(
    Item item,
    Map<String, Map<String, String>> values,
    String? fieldId,
  ) {
    if (fieldId == null) return '';
    return values[item.id]?[fieldId] ?? '';
  }

  List<Item> _prepareItems(
    List<Item> source,
    Map<String, Map<String, String>> values,
  ) {
    final result = source.where((item) {
      if (search.trim().isEmpty) return true;
      final query = search.trim().toLowerCase();
      final itemValues = values[item.id]?.values ?? const <String>[];
      return itemValues.any((value) => value.toLowerCase().contains(query)) ||
          item.id.toLowerCase().contains(query);
    }).toList();

    result.sort((a, b) {
      if (sortField == null) {
        return a.sortOrder.compareTo(b.sortOrder);
      }

      final av = _value(a, values, sortField).trim();
      final bv = _value(b, values, sortField).trim();
      final an = double.tryParse(av.replaceAll(',', '.'));
      final bn = double.tryParse(bv.replaceAll(',', '.'));
      final comparison = an != null && bn != null
          ? an.compareTo(bn)
          : av.toLowerCase().compareTo(bv.toLowerCase());
      return descending ? -comparison : comparison;
    });

    return result;
  }

  Map<String, List<Item>> _groupItems(
    List<Item> items,
    Map<String, Map<String, String>> values,
  ) {
    if (groupField == null) return {'': items};

    final groups = <String, List<Item>>{};
    for (final item in items) {
      final key = _value(item, values, groupField).trim();
      final normalized = key.isEmpty ? 'Без значения' : key;
      groups.putIfAbsent(normalized, () => []).add(item);
    }

    final sortedKeys = groups.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return {
      for (final key in sortedKeys) key: groups[key]!,
    };
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsProvider(widget.collection.id));
    final fieldsAsync = ref.watch(fieldsProvider(widget.collection.id));
    final valuesAsync = ref.watch(
      collectionItemValuesProvider(widget.collection.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collection.name),
        actions: [
          IconButton(
            tooltip: gridView ? 'Список' : 'Карточки',
            icon: Icon(gridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => gridView = !gridView),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.tune),
            onSelected: (value) {
              if (value == 'reverse') {
                setState(() => descending = !descending);
              } else if (value == 'clear') {
                setState(() {
                  sortField = null;
                  groupField = null;
                  descending = false;
                });
              } else if (value.startsWith('sort:')) {
                setState(() => sortField = value.substring(5));
              } else if (value.startsWith('group:')) {
                setState(() => groupField = value.substring(6));
              }
            },
            itemBuilder: (_) {
              final fields = fieldsAsync.valueOrNull ?? [];
              return [
                const PopupMenuItem(
                  enabled: false,
                  child: Text('Сортировка'),
                ),
                ...fields.map(
                  (field) => PopupMenuItem(
                    value: 'sort:${field.id}',
                    child: Text(field.label),
                  ),
                ),
                const PopupMenuItem(
                  enabled: false,
                  child: Text('Группировка'),
                ),
                ...fields.map(
                  (field) => PopupMenuItem(
                    value: 'group:${field.id}',
                    child: Text(field.label),
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'reverse',
                  child: Text(descending ? 'Прямой порядок' : 'Обратный порядок'),
                ),
                const PopupMenuItem(
                  value: 'clear',
                  child: Text('Сбросить настройки'),
                ),
              ];
            },
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Ошибка: $error')),
        data: (items) {
          return valuesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Ошибка значений: $error')),
            data: (values) {
              final prepared = _prepareItems(items, values);
              final groups = _groupItems(prepared, values);
              final fields = fieldsAsync.valueOrNull ?? [];

              return RefreshIndicator(
                onRefresh: () async => _refresh(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Поиск по предметам',
                        suffixIcon: search.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => setState(() => search = ''),
                              ),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) => setState(() => search = value),
                    ),
                    const SizedBox(height: 10),
                    if (sortField != null || groupField != null)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (sortField != null)
                            Chip(
                              label: Text(
                                'Сортировка: ${_fieldLabel(fields, sortField!)}',
                              ),
                            ),
                          if (groupField != null)
                            Chip(
                              label: Text(
                                'Группировка: ${_fieldLabel(fields, groupField!)}',
                              ),
                            ),
                        ],
                      ),
                    if (prepared.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 48),
                              SizedBox(height: 12),
                              Text('Предметы не найдены'),
                              SizedBox(height: 6),
                              Text(
                                'Измените запрос поиска или добавьте новый предмет.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...groups.entries.expand(
                        (entry) => [
                          if (groupField != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 4,
                                top: 12,
                                bottom: 6,
                              ),
                              child: Text(
                                entry.key,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          if (gridView)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 360,
                                mainAxisExtent: 120,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: entry.value.length,
                              itemBuilder: (_, index) => _ItemCard(
                                item: entry.value[index],
                                index: index,
                                values: values,
                                fields: fields,
                                onOpen: () => _openItem(entry.value[index]),
                                onDelete: () => _deleteItem(entry.value[index]),
                              ),
                            )
                          else
                            ...entry.value.asMap().entries.map(
                              (entry) => _ItemCard(
                                item: entry.value,
                                index: entry.key,
                                values: values,
                                fields: fields,
                                onOpen: () => _openItem(entry.value),
                                onDelete: () => _deleteItem(entry.value),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Предмет'),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ItemEditorPage(collection: widget.collection),
            ),
          );
          _refresh();
        },
      ),
    );
  }

  String _fieldLabel(List<dynamic> fields, String id) {
    for (final field in fields) {
      if (field.id == id) return field.label;
    }
    return id;
  }

  Future<void> _openItem(Item item) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ItemDetailPage(itemId: item.id)),
    );
    _refresh();
  }

  Future<void> _deleteItem(Item item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить предмет?'),
        content: const Text('Предмет и его значения будут удалены.'),
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
      ),
    );
    if (!mounted || confirmed != true) return;
    await ref.read(itemServiceProvider).deleteItem(item.id);
    _refresh();
  }
}

class _ItemCard extends StatelessWidget {
  final Item item;
  final int index;
  final Map<String, Map<String, String>> values;
  final List<dynamic> fields;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _ItemCard({
    required this.item,
    required this.index,
    required this.values,
    required this.fields,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final itemValues = values[item.id] ?? const <String, String>{};
    final visible = fields.where((field) {
      final value = itemValues[field.id];
      return value != null && value.isNotEmpty;
    }).take(3).toList();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(child: Text('${index + 1}')),
        title: Text(
          visible.isEmpty
              ? 'Предмет ${index + 1}'
              : itemValues[visible.first.id]!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: visible.length <= 1
            ? Text(item.id)
            : Text(
                visible.skip(1).map((field) {
                  return '${field.label}: ${itemValues[field.id]}';
                }).join(' · '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
        onTap: onOpen,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'delete', child: Text('Удалить')),
          ],
        ),
      ),
    );
  }
}
