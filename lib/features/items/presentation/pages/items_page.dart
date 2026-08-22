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

class ItemsPage extends ConsumerStatefulWidget {
  final Collection collection;
  final String? sectionId;
  final String? sectionName;

  const ItemsPage({
    super.key,
    required this.collection,
    this.sectionId,
    this.sectionName,
  });

  @override
  ConsumerState<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends ConsumerState<ItemsPage> {
  String _search = '';
  String? _sortField;
  bool _descending = false;
  CollectionItemStatus? _statusFilter;
  final Map<String, String> _valueFilters = <String, String>{};

  List<CollectionSection> _children(List<CollectionSection> sections) {
    final result = sections
        .where((section) => section.parentId == widget.sectionId)
        .toList(growable: false);
    return [...result]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  String _value(
    Item item,
    Map<String, Map<String, String>> values,
    String fieldId,
  ) {
    return values[item.id]?[fieldId] ?? '';
  }

  List<dynamic> _filterFields(
    List<dynamic> fields,
    Map<String, Map<String, String>> values,
    List<Item> items,
  ) {
    return fields.where((field) {
      final distinct = items
          .map((item) => _value(item, values, field.id))
          .where((value) => value.isNotEmpty)
          .toSet();
      return field.id.toString().isNotEmpty &&
          field.label.toString().isNotEmpty &&
          distinct.length > 1;
    }).toList(growable: false);
  }

  List<Item> _prepare(
    List<Item> source,
    Map<String, Map<String, String>> values,
    Map<String, ItemState> states,
  ) {
    final query = _search.trim().toLowerCase();
    final result = source.where((item) {
      final state = states[item.id] ??
          ItemState(updatedAt: DateTime.now());

      if (_statusFilter != null && state.status != _statusFilter) {
        return false;
      }

      for (final filter in _valueFilters.entries) {
        if (_value(item, values, filter.key) != filter.value) {
          return false;
        }
      }

      if (query.isEmpty) {
        return true;
      }

      final searchable = [
        item.id,
        ...(values[item.id]?.values ?? const <String>[]),
      ].join(' ').toLowerCase();
      return searchable.contains(query);
    }).toList(growable: false);

    final sorted = [...result];
    sorted.sort((a, b) {
      if (_sortField == null) {
        return a.sortOrder.compareTo(b.sortOrder);
      }

      final aValue = _value(a, values, _sortField!);
      final bValue = _value(b, values, _sortField!);
      final aNumber = double.tryParse(aValue.replaceAll(',', '.'));
      final bNumber = double.tryParse(bValue.replaceAll(',', '.'));
      final comparison = aNumber != null && bNumber != null
          ? aNumber.compareTo(bNumber)
          : aValue.toLowerCase().compareTo(bValue.toLowerCase());
      return _descending ? -comparison : comparison;
    });

    return sorted;
  }

  void _refresh() {
    ref.invalidate(itemsProvider(widget.collection.id));
    ref.invalidate(collectionItemValuesProvider(widget.collection.id));
    ref.invalidate(collectionSectionsProvider(widget.collection.id));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final sections = ref.watch(collectionSectionsProvider(widget.collection.id));

    return sections.when(
      loading: () => _shell(
        context,
        widget.sectionName ?? widget.collection.name,
        const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => _shell(
        context,
        widget.sectionName ?? widget.collection.name,
        Center(child: Text('Ошибка разделов: $error')),
      ),
      data: (allSections) {
        final children = _children(allSections);
        final browsingRoot = widget.sectionId == null;
        if (children.isNotEmpty || (browsingRoot && allSections.isNotEmpty)) {
          return _browser(context, allSections);
        }
        return _items(context);
      },
    );
  }

  Widget _shell(BuildContext context, String title, Widget body) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: body,
    );
  }

  Widget _browser(BuildContext context, List<CollectionSection> allSections) {
    final children = widget.sectionId == null
        ? allSections.where((section) => section.parentId == null).toList()
        : _children(allSections);

    children.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return _shell(
      context,
      widget.sectionName ?? widget.collection.name,
      ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_tree_outlined),
              title: Text(
                widget.sectionId == null
                    ? 'Полный каталог'
                    : widget.sectionName ?? 'Раздел',
              ),
              subtitle: const Text(
                'Фильтры появляются только на уровне предметов.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final section in children)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.folder_outlined),
                ),
                title: Text(section.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ItemsPage(
                        collection: widget.collection,
                        sectionId: section.id,
                        sectionName: section.name,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _items(BuildContext context) {
    final items = ref.watch(itemsProvider(widget.collection.id));
    final fields = ref.watch(fieldsProvider(widget.collection.id));
    final values = ref.watch(collectionItemValuesProvider(widget.collection.id));

    return _shell(
      context,
      widget.sectionName == null
          ? widget.collection.name
          : '${widget.collection.name} · ${widget.sectionName}',
      items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
        data: (itemList) => values.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Ошибка значений: $error')),
          data: (valueMap) => fields.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Ошибка полей: $error')),
            data: (fieldList) => FutureBuilder<Map<String, ItemState>>(
              future: ItemStateStore.loadAll(),
              builder: (context, snapshot) {
                final states = snapshot.data ?? <String, ItemState>{};
                final sectionItems = itemList
                    .where((item) => item.sectionId == widget.sectionId)
                    .toList(growable: false);
                final filterFields = _filterFields(
                  fieldList,
                  valueMap,
                  sectionItems,
                );
                final prepared = _prepare(
                  sectionItems,
                  valueMap,
                  states,
                );
                final filtersActive =
                    _sortField != null ||
                    _descending ||
                    _statusFilter != null ||
                    _valueFilters.isNotEmpty;

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
                          suffixIcon: _search.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () => setState(() => _search = ''),
                                  icon: const Icon(Icons.clear),
                                ),
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) => setState(() => _search = value),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.tonalIcon(
                          onPressed: () => _showFilters(
                            context,
                            fieldList,
                            filterFields,
                            valueMap,
                            sectionItems,
                          ),
                          icon: const Icon(Icons.tune),
                          label: Text(
                            filtersActive
                                ? 'Фильтры активны'
                                : 'Фильтры и сортировка',
                          ),
                        ),
                      ),
                      if (filtersActive)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (_sortField != null)
                              Chip(
                                label: Text(
                                  'Сортировка: ${_label(fieldList, _sortField!)}',
                                ),
                              ),
                            if (_statusFilter != null)
                              Chip(label: Text(_statusFilter!.title)),
                            for (final filter in _valueFilters.entries)
                              Chip(
                                label: Text(
                                  '${_label(fieldList, filter.key)}: ${filter.value}',
                                ),
                              ),
                          ],
                        ),
                      if (prepared.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Предметы не найдены',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        for (var index = 0; index < prepared.length; index++)
                          _ItemCard(
                            item: prepared[index],
                            index: index,
                            values: valueMap,
                            fields: fieldList,
                            state: states[prepared[index].id] ??
                                ItemState(updatedAt: DateTime.now()),
                            onOpen: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ItemDetailPage(
                                    itemId: prepared[index].id,
                                  ),
                                ),
                              );
                              if (!mounted) {
                                return;
                              }
                              _refresh();
                            },
                          ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _label(List<dynamic> fields, String id) {
    for (final field in fields) {
      if (field.id == id) {
        return field.label.toString();
      }
    }
    return id;
  }

  Future<void> _showFilters(
    BuildContext context,
    List<dynamic> fields,
    List<dynamic> filterFields,
    Map<String, Map<String, String>> values,
    List<Item> items,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Фильтры',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<CollectionItemStatus?>(
                  initialValue: _statusFilter,
                  decoration: const InputDecoration(
                    labelText: 'Наличие',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<CollectionItemStatus?>(
                      value: null,
                      child: Text('Все'),
                    ),
                    ...CollectionItemStatus.values.map(
                      (status) => DropdownMenuItem<CollectionItemStatus?>(
                        value: status,
                        child: Text(status.title),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setSheetState(() {});
                    setState(() => _statusFilter = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: _sortField,
                  decoration: const InputDecoration(
                    labelText: 'Сортировка',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('По порядку каталога'),
                    ),
                    ...filterFields.map(
                      (field) => DropdownMenuItem<String?>(
                        value: field.id.toString(),
                        child: Text('По ${field.label}'),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setSheetState(() {});
                    setState(() => _sortField = value);
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _descending
                        ? 'Обратная сортировка'
                        : 'Прямая сортировка',
                  ),
                  value: _descending,
                  onChanged: (value) {
                    setSheetState(() {});
                    setState(() => _descending = value);
                  },
                ),
                for (final field in filterFields)
                  _buildValueFilter(
                    field,
                    items,
                    values,
                    setSheetState,
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _sortField = null;
                            _descending = false;
                            _statusFilter = null;
                            _valueFilters.clear();
                          });
                          Navigator.of(sheetContext).pop();
                        },
                        child: const Text('Сбросить'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: const Text('Применить'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValueFilter(
    dynamic field,
    List<Item> items,
    Map<String, Map<String, String>> values,
    StateSetter setSheetState,
  ) {
    final distinct = items
        .map((item) => _value(item, values, field.id))
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String?>(
        initialValue: _valueFilters[field.id],
        decoration: InputDecoration(
          labelText: field.label.toString(),
          border: const OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('Все'),
          ),
          ...distinct.map(
            (value) => DropdownMenuItem<String?>(
              value: value,
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
        onChanged: (value) {
          setSheetState(() {});
          setState(() {
            if (value == null) {
              _valueFilters.remove(field.id.toString());
            } else {
              _valueFilters[field.id.toString()] = value;
            }
          });
        },
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Item item;
  final int index;
  final Map<String, Map<String, String>> values;
  final List<dynamic> fields;
  final ItemState state;
  final VoidCallback onOpen;

  const _ItemCard({
    required this.item,
    required this.index,
    required this.values,
    required this.fields,
    required this.state,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final itemValues = values[item.id] ?? const <String, String>{};
    final visibleFields = fields
        .where((field) => (itemValues[field.id] ?? '').isNotEmpty)
        .take(3)
        .toList(growable: false);

    final title = visibleFields.isEmpty
        ? item.id
        : itemValues[visibleFields.first.id] ?? item.id;

    final details = visibleFields.length > 1
        ? visibleFields
            .skip(1)
            .map((field) => '${field.label}: ${itemValues[field.id]}')
            .join(' · ')
        : '';

    final subtitle = [
      state.status.title,
      if (state.quantity > 0) '${state.quantity} шт.',
      if (details.isNotEmpty) details,
    ].join(' · ');

    final icon = switch (state.status) {
      CollectionItemStatus.owned || CollectionItemStatus.storage =>
        Icons.check_circle,
      CollectionItemStatus.wanted => Icons.shopping_cart_outlined,
      CollectionItemStatus.ordered => Icons.local_shipping_outlined,
      _ => Icons.chevron_right,
    };

    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text('${index + 1}')),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(icon),
        onTap: onOpen,
      ),
    );
  }
}
