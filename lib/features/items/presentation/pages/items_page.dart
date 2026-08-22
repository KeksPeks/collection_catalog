import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../collections/domain/entities/collection.dart';
import '../../../collections/domain/entities/collection_section.dart';
import '../../../collections/presentation/providers/collection_section_provider.dart';
import '../../../fields/presentation/providers/field_provider.dart';
import '../../data/item_state_store.dart';
import '../../domain/entities/item.dart';
import '../providers/item_provider.dart';
import 'item_detail_page.dart';

/// Просмотр загруженного каталога. Структура каталога и записи только для
/// чтения; пользователь меняет исключительно личное состояние предметов.
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
  CollectionItemStatus? statusFilter;
  final Map<String, String> valueFilters = {};

  void _refresh() {
    if (!mounted) return;
    ref.invalidate(itemsProvider(widget.collection.id));
    ref.invalidate(collectionItemValuesProvider(widget.collection.id));
    ref.invalidate(collectionSectionsProvider(widget.collection.id));
    setState(() {});
  }

  List<CollectionSection> _childrenOf(List<CollectionSection> sections) {
    return sections.where((section) => section.parentId == widget.sectionId).toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  String _value(Item item, Map<String, Map<String, String>> values, String fieldId) => values[item.id]?[fieldId] ?? '';

  List<dynamic> _filterFields(List<dynamic> fields, Map<String, Map<String, String>> values, List<Item> items) {
    return fields.where((field) {
      final distinct = items.map((item) => _value(item, values, field.id).trim()).where((value) => value.isNotEmpty).toSet();
      return field.id.toString().isNotEmpty && field.label.toString().isNotEmpty && distinct.length > 1;
    }).toList();
  }

  List<Item> _prepare(List<Item> source, Map<String, Map<String, String>> values, Map<String, ItemState> states) {
    final query = search.trim().toLowerCase();
    final result = source.where((item) {
      final state = states[item.id] ?? ItemState(updatedAt: DateTime.now());
      if (statusFilter != null && state.status != statusFilter) return false;
      for (final filter in valueFilters.entries) {
        if (_value(item, values, filter.key) != filter.value) return false;
      }
      if (query.isEmpty) return true;
      final text = '${item.id} ${(values[item.id]?.values ?? const <String>[]).join(' ')}'.toLowerCase();
      return text.contains(query);
    }).toList();
    result.sort((a, b) {
      if (sortField == null) return a.sortOrder.compareTo(b.sortOrder);
      final av = _value(a, values, sortField!).trim();
      final bv = _value(b, values, sortField!).trim();
      final an = double.tryParse(av.replaceAll(',', '.'));
      final bn = double.tryParse(bv.replaceAll(',', '.'));
      final comparison = an != null && bn != null ? an.compareTo(bn) : av.toLowerCase().compareTo(bv.toLowerCase());
      return descending ? -comparison : comparison;
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final sectionsAsync = ref.watch(collectionSectionsProvider(widget.collection.id));
    return sectionsAsync.when(
      loading: () => _shell(context, widget.sectionName ?? widget.collection.name, const Center(child: CircularProgressIndicator())),
      error: (error, _) => _shell(context, widget.sectionName ?? widget.collection.name, Center(child: Text('Ошибка разделов: $error'))),
      data: (sections) {
        final children = _childrenOf(sections);
        if (children.isNotEmpty || widget.sectionId == null && sections.isNotEmpty) return _sectionBrowser(context, sections);
        return _items(context);
      },
    );
  }

  Widget _shell(BuildContext context, String title, Widget body) => Scaffold(appBar: AppBar(title: Text(title)), body: body);

  Widget _sectionBrowser(BuildContext context, List<CollectionSection> sections) {
    final children = widget.sectionId == null ? sections.where((section) => section.parentId == null).toList() : _childrenOf(sections);
    children.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return _shell(context, widget.sectionName ?? widget.collection.name, ListView(padding: const EdgeInsets.all(16), children: [Card(child: ListTile(leading: const Icon(Icons.account_tree_outlined), title: Text(widget.sectionId == null ? 'Полный каталог' : widget.sectionName ?? 'Раздел'), subtitle: const Text('Фильтры и сортировка появляются только на уровне предметов.'))), const SizedBox(height: 12), ...children.map((section) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(leading: const CircleAvatar(child: Icon(Icons.folder_outlined)), title: Text(section.name), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ItemsPage(collection: widget.collection, sectionId: section.id, sectionName: section.name)))))]));
  }

  Widget _items(BuildContext context) {
    final itemsAsync = ref.watch(itemsProvider(widget.collection.id));
    final fieldsAsync = ref.watch(fieldsProvider(widget.collection.id));
    final valuesAsync = ref.watch(collectionItemValuesProvider(widget.collection.id));
    return _shell(context, widget.sectionName == null ? widget.collection.name : '${widget.collection.name} · ${widget.sectionName}', itemsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Ошибка: $error')),
      data: (items) => valuesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Ошибка значений: $error')),
        data: (values) {
          final fields = fieldsAsync.valueOrNull ?? widget.collection.fields;
          final sectionItems = items.where((item) => item.sectionId == widget.sectionId).toList();
          final filterFields = _filterFields(fields, values, sectionItems);
          return FutureBuilder<Map<String, ItemState>>(
            future: ItemStateStore.loadAll(),
            builder: (context, snapshot) {
              final states = snapshot.data ?? <String, ItemState>{};
              final prepared = _prepare(sectionItems, values, states);
              final active = sortField != null || descending || statusFilter != null || valueFilters.isNotEmpty;
              return RefreshIndicator(onRefresh: () async => _refresh(), child: ListView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(12), children: [
                TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Поиск по предметам', suffixIcon: search.isEmpty ? null : IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => search = '')), border: const OutlineInputBorder()), onChanged: (value) => setState(() => search = value)),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: FilledButton.tonalIcon(onPressed: () => _showFilters(context, fields, filterFields, values, sectionItems), icon: const Icon(Icons.tune), label: Text(active ? 'Фильтры активны' : 'Фильтры и сортировка'))),
                if (active) Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Wrap(spacing: 6, runSpacing: 6, children: [if (sortField != null) Chip(label: Text('Сортировка: ${_label(fields, sortField!)}')), if (statusFilter != null) Chip(label: Text(statusFilter!.title)), ...valueFilters.entries.map((entry) => Chip(label: Text('${_label(fields, entry.key)}: ${entry.value}')))])),
                if (prepared.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(24), child: Column(children: [Icon(Icons.inventory_2_outlined, size: 48), SizedBox(height: 10), Text('Предметы не найдены'), SizedBox(height: 6), Text('Измените поиск или фильтры.', textAlign: TextAlign.center)]))) else ...prepared.asMap().entries.map((entry) => _ItemCard(item: entry.value, index: entry.key, values: values, fields: fields, state: states[entry.value.id] ?? ItemState(updatedAt: DateTime.now()), onOpen: () async { await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ItemDetailPage(itemId: entry.value.id))); _refresh(); }))
              ]));
            },
          );
        },
      ),
    ));
  }

  String _label(List<dynamic> fields, String id) => fields.where((field) => field.id == id).map((field) => field.label.toString()).firstOrNull ?? id;

  Future<void> _showFilters(BuildContext context, List<dynamic> fields, List<dynamic> filterFields, Map<String, Map<String, String>> values, List<Item> items) async {
    await showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (sheet) => StatefulBuilder(builder: (context, setSheetState) => SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Фильтры', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      DropdownButtonFormField<CollectionItemStatus?>(initialValue: statusFilter, decoration: const InputDecoration(labelText: 'Наличие', border: OutlineInputBorder()), items: [const DropdownMenuItem<CollectionItemStatus?>(value: null, child: Text('Все')), ...CollectionItemStatus.values.map((status) => DropdownMenuItem(value: status, child: Text(status.title)))], onChanged: (value) { setSheetState(() {}); setState(() => statusFilter = value); }),
      const SizedBox(height: 12),
      DropdownButtonFormField<String?>(initialValue: sortField, decoration: const InputDecoration(labelText: 'Сортировка', border: OutlineInputBorder()), items: [const DropdownMenuItem<String?>(value: null, child: Text('По порядку каталога')), ...filterFields.map((field) => DropdownMenuItem(value: field.id.toString(), child: Text('По ${field.label}')))], onChanged: (value) { setSheetState(() {}); setState(() => sortField = value); }),
      SwitchListTile(title: Text(descending ? 'Обратная сортировка' : 'Прямая сортировка'), value: descending, onChanged: (value) { setSheetState(() {}); setState(() => descending = value); }),
      ...filterFields.map((field) {
        final distinct = items.map((item) => _value(item, values, field.id)).where((value) => value.isNotEmpty).toSet().toList()..sort();
        return DropdownButtonFormField<String?>(initialValue: valueFilters[field.id], decoration: InputDecoration(labelText: field.label, border: const OutlineInputBorder()), items: [const DropdownMenuItem<String?>(value: null, child: Text('Все')), ...distinct.map((value) => DropdownMenuItem(value: value, child: Text(value, overflow: TextOverflow.ellipsis)))], onChanged: (value) { setSheetState(() {}); setState(() { if (value == null) valueFilters.remove(field.id); else valueFilters[field.id] = value; }); });
      }),
      const SizedBox(height: 12),
      Row(children: [Expanded(child: OutlinedButton(onPressed: () { setState(() { sortField = null; descending = false; statusFilter = null; valueFilters.clear(); }); Navigator.pop(sheet); }, child: const Text('Сбросить'))), const SizedBox(width: 8), Expanded(child: FilledButton(onPressed: () => Navigator.pop(sheet), child: const Text('Применить')))]),
    ]))));
  }
}

class _ItemCard extends StatelessWidget {
  final Item item;
  final int index;
  final Map<String, Map<String, String>> values;
  final List<dynamic> fields;
  final ItemState state;
  final VoidCallback onOpen;
  const _ItemCard({required this.item, required this.index, required this.values, required this.fields, required this.state, required this.onOpen});
  @override
  Widget build(BuildContext context) {
    final itemValues = values[item.id] ?? const <String, String>{};
    final visible = fields.where((field) => (itemValues[field.id] ?? '').isNotEmpty).take(3).toList();
    final icon = state.status == CollectionItemStatus.owned || state.status == CollectionItemStatus.storage ? Icons.check_circle : state.status == CollectionItemStatus.wanted ? Icons.shopping_cart_outlined : state.status == CollectionItemStatus.ordered ? Icons.local_shipping_outlined : Icons.chevron_right;
    return Card(margin: const EdgeInsets.symmetric(vertical: 4), child: ListTile(leading: CircleAvatar(child: Text('${index + 1}')), title: Text(visible.isEmpty ? item.id : itemValues[visible.first.id]!, maxLines: 1, overflow: TextOverflow.ellipsis), subtitle: Text('${state.status.title}${state.quantity > 0 ? ' · ${state.quantity} шт.' : ''}${visible.length > 1 ? ' · ${visible.skip(1).map((field) => '${field.label}: ${itemValues[field.id]}').join(' · ')}' : ''}', maxLines: 2, overflow: TextOverflow.ellipsis), trailing: Icon(icon), onTap: onOpen));
  }
}

extension _FirstOrNull<T> on Iterable<T> { T? get firstOrNull => isEmpty ? null : first; }
