import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../collections/domain/entities/collection.dart';
import '../../../fields/presentation/providers/field_provider.dart';
import '../../domain/entities/item.dart';
import '../providers/item_provider.dart';
import '../providers/item_service_provider.dart';
import 'item_detail_page.dart';
import 'item_editor_page.dart';

/// Список предметов. Сортировка и фильтрация применяются только к текущему разделу.
class ItemsPage extends ConsumerStatefulWidget {
  final Collection collection;
  final String? sectionId;
  final String? sectionName;

  const ItemsPage({super.key, required this.collection, this.sectionId, this.sectionName});

  @override
  ConsumerState<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends ConsumerState<ItemsPage> {
  String search = '';
  String? sortField;
  bool descending = false;
  bool ownedOnly = false;
  bool gridView = false;

  void _refresh() {
    if (!mounted) return;
    ref.invalidate(itemsProvider(widget.collection.id));
    ref.invalidate(collectionItemValuesProvider(widget.collection.id));
  }

  String _value(Item item, Map<String, Map<String, String>> values, String? fieldId) => fieldId == null ? '' : values[item.id]?[fieldId] ?? '';

  bool _owned(Item item, Map<String, Map<String, String>> values) => _value(item, values, _ownedFieldId()).toLowerCase() == 'true';

  String? _ownedFieldId() {
    for (final field in widget.collection.fields) {
      if (field.id.endsWith('_owned') || field.id == 'owned') return field.id;
    }
    return null;
  }

  List<Item> _prepareItems(List<Item> source, Map<String, Map<String, String>> values) {
    final result = source.where((item) {
      if (widget.sectionId != null && item.sectionId != widget.sectionId) return false;
      if (ownedOnly && !_owned(item, values)) return false;
      if (search.trim().isEmpty) return true;
      final query = search.trim().toLowerCase();
      final itemValues = values[item.id]?.values ?? const <String>[];
      return itemValues.any((value) => value.toLowerCase().contains(query)) || item.id.toLowerCase().contains(query);
    }).toList();

    result.sort((a, b) {
      if (sortField == null) return a.sortOrder.compareTo(b.sortOrder);
      final av = _value(a, values, sortField).trim();
      final bv = _value(b, values, sortField).trim();
      final an = double.tryParse(av.replaceAll(',', '.'));
      final bn = double.tryParse(bv.replaceAll(',', '.'));
      final comparison = an != null && bn != null ? an.compareTo(bn) : av.toLowerCase().compareTo(bv.toLowerCase());
      return descending ? -comparison : comparison;
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsProvider(widget.collection.id));
    final fieldsAsync = ref.watch(fieldsProvider(widget.collection.id));
    final valuesAsync = ref.watch(collectionItemValuesProvider(widget.collection.id));
    final title = widget.sectionName == null ? widget.collection.name : '${widget.collection.name} · ${widget.sectionName}';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(tooltip: gridView ? 'Список' : 'Карточки', icon: Icon(gridView ? Icons.view_list : Icons.grid_view), onPressed: () => setState(() => gridView = !gridView)),
          PopupMenuButton<String>(
            icon: const Icon(Icons.tune),
            onSelected: (value) {
              if (value == 'reverse') setState(() => descending = !descending);
              else if (value == 'owned') setState(() => ownedOnly = !ownedOnly);
              else if (value == 'clear') setState(() { sortField = null; descending = false; ownedOnly = false; });
              else if (value.startsWith('sort:')) setState(() => sortField = value.substring(5));
            },
            itemBuilder: (_) {
              final fields = fieldsAsync.valueOrNull ?? widget.collection.fields;
              final ownedId = _ownedFieldId();
              return [
                const PopupMenuItem(enabled: false, child: Text('Сортировка')),
                ...fields.where((field) => field.id != ownedId).map((field) => PopupMenuItem(value: 'sort:${field.id}', child: Text(field.label))),
                if (ownedId != null) PopupMenuItem(value: 'owned', child: Text(ownedOnly ? 'Показать все' : 'Только имеющиеся')),
                const PopupMenuDivider(),
                PopupMenuItem(value: 'reverse', child: Text(descending ? 'Прямой порядок' : 'Обратный порядок')),
                const PopupMenuItem(value: 'clear', child: Text('Сбросить настройки')),
              ];
            },
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Ошибка: $error')),
        data: (items) => valuesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Ошибка значений: $error')),
          data: (values) {
            final fields = fieldsAsync.valueOrNull ?? widget.collection.fields;
            final prepared = _prepareItems(items, values);
            return RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                children: [
                  TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Поиск по предметам', border: OutlineInputBorder()), onChanged: (value) => setState(() => search = value)),
                  if (ownedOnly || sortField != null) Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Wrap(spacing: 8, children: [if (ownedOnly) const Chip(label: Text('Только имеющиеся')), if (sortField != null) Chip(label: Text('Сортировка: ${'${_fieldLabel(fields, sortField!)}'}'))])),
                  if (prepared.isEmpty)
                    const Card(child: Padding(padding: EdgeInsets.all(24), child: Column(children: [Icon(Icons.inventory_2_outlined, size: 48), SizedBox(height: 12), Text('Предметы не найдены'), SizedBox(height: 6), Text('Измените фильтр или поиск.', textAlign: TextAlign.center)])))
                  else if (gridView)
                    GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 360, mainAxisExtent: 120, crossAxisSpacing: 8, mainAxisSpacing: 8), itemCount: prepared.length, itemBuilder: (_, index) => _ItemCard(item: prepared[index], index: index, values: values, fields: fields, onOpen: () => _openItem(prepared[index]), onDelete: () => _deleteItem(prepared[index])))
                  else
                    ...prepared.asMap().entries.map((entry) => _ItemCard(item: entry.value, index: entry.key, values: values, fields: fields, onOpen: () => _openItem(entry.value), onDelete: () => _deleteItem(entry.value))),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: widget.sectionId == null ? FloatingActionButton.extended(icon: const Icon(Icons.add), label: const Text('Предмет'), onPressed: () async { await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ItemEditorPage(collection: widget.collection))); _refresh(); }) : null,
    );
  }

  String _fieldLabel(List<dynamic> fields, String id) { for (final field in fields) { if (field.id == id) return field.label; } return id; }

  Future<void> _openItem(Item item) async { await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ItemDetailPage(itemId: item.id))); _refresh(); }

  Future<void> _deleteItem(Item item) async {
    final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(title: const Text('Удалить предмет?'), content: const Text('Предмет и его значения будут удалены.'), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Отмена')), FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Удалить'))]));
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
  const _ItemCard({required this.item, required this.index, required this.values, required this.fields, required this.onOpen, required this.onDelete});
  @override
  Widget build(BuildContext context) {
    final itemValues = values[item.id] ?? const <String, String>{};
    final visible = fields.where((field) => (itemValues[field.id] ?? '').isNotEmpty).take(3).toList();
    return Card(margin: const EdgeInsets.symmetric(vertical: 4), child: ListTile(leading: CircleAvatar(child: Text('${index + 1}')), title: Text(visible.isEmpty ? 'Предмет ${index + 1}' : itemValues[visible.first.id]!, maxLines: 1, overflow: TextOverflow.ellipsis), subtitle: visible.length <= 1 ? Text(item.id) : Text(visible.skip(1).map((field) => '${field.label}: ${itemValues[field.id]}').join(' · '), maxLines: 2, overflow: TextOverflow.ellipsis), onTap: onOpen, trailing: PopupMenuButton<String>(onSelected: (value) { if (value == 'delete') onDelete(); }, itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Text('Удалить'))])));
  }
}
