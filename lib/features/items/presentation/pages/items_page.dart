import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../collections/domain/entities/collection.dart';
import '../../../collections/domain/entities/collection_section.dart';
import '../../../collections/presentation/providers/collection_section_provider.dart';
import '../../../fields/presentation/providers/field_provider.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/item_value.dart';
import '../providers/item_provider.dart';
import '../providers/item_service_provider.dart';
import 'item_detail_page.dart';

/// Просмотр загруженного каталога.
///
/// На верхнем уровне показывается вся иерархия каталога. Предметы открываются
/// только при входе в конечный раздел. Пользователь может менять только
/// собственный статус наличия предмета.
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
  String search = '';
  String? sortField;
  bool descending = false;
  bool ownedOnly = false;

  bool get _isRussiaRegularCoins =>
      widget.collection.templateId == 'coins' &&
      widget.sectionName == 'Регулярный чекан';

  void _refresh() {
    if (!mounted) return;
    ref.invalidate(itemsProvider(widget.collection.id));
    ref.invalidate(collectionItemValuesProvider(widget.collection.id));
    ref.invalidate(collectionSectionsProvider(widget.collection.id));
  }

  String _value(
    Item item,
    Map<String, Map<String, String>> values,
    String? fieldId,
  ) {
    if (fieldId == null) return '';
    return values[item.id]?[fieldId] ?? '';
  }

  String? _ownedFieldId() {
    for (final field in widget.collection.fields) {
      if (field.id.endsWith('_owned') || field.id == 'owned') {
        return field.id;
      }
    }
    return null;
  }

  bool _owned(Item item, Map<String, Map<String, String>> values) {
    final fieldId = _ownedFieldId();
    if (fieldId == null) return false;
    return _value(item, values, fieldId).toLowerCase() == 'true';
  }

  List<dynamic> _sortFields(List<dynamic> fields) {
    if (!_isRussiaRegularCoins) return const [];
    const allowed = {'year', 'series', 'rarity'};
    return fields.where((field) {
      final id = field.id.toString().toLowerCase();
      final label = field.label.toString().toLowerCase();
      return allowed.contains(id) ||
          allowed.contains(id.split('_').last) ||
          label == 'год' ||
          label == 'серия' ||
          label == 'редкость';
    }).toList();
  }

  List<Item> _prepareItems(
    List<Item> source,
    Map<String, Map<String, String>> values,
  ) {
    final result = source.where((item) {
      if (ownedOnly && !_owned(item, values)) return false;
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

  CollectionSection? _sectionById(List<CollectionSection> sections, String? id) {
    if (id == null) return null;
    for (final section in sections) {
      if (section.id == id) return section;
    }
    return null;
  }

  List<CollectionSection> _childrenOf(
    List<CollectionSection> sections,
    String? parentId,
  ) {
    return sections.where((section) => section.parentId == parentId).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  Widget build(BuildContext context) {
    final sectionsAsync = ref.watch(collectionSectionsProvider(widget.collection.id));

    return sectionsAsync.when(
      loading: () => _shell(
        context,
        title: widget.sectionName ?? widget.collection.name,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _shell(
        context,
        title: widget.sectionName ?? widget.collection.name,
        body: Center(child: Text('Ошибка разделов: $error')),
      ),
      data: (sections) {
        final selected = _sectionById(sections, widget.sectionId);
        final children = _childrenOf(sections, widget.sectionId);

        if (children.isNotEmpty || widget.sectionId == null && sections.isNotEmpty) {
          return _buildSectionBrowser(context, sections, children);
        }

        return _buildItems(context);
      },
    );
  }

  Widget _shell(
    BuildContext context, {
    required String title,
    required Widget body,
  }) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: body,
    );
  }

  Widget _buildSectionBrowser(
    BuildContext context,
    List<CollectionSection> sections,
    List<CollectionSection> children,
  ) {
    final currentChildren = widget.sectionId == null
        ? _childrenOf(sections, null)
        : children;
    final title = widget.sectionName ?? widget.collection.name;

    return _shell(
      context,
      title: title,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_tree_outlined),
              title: Text(
                widget.sectionId == null
                    ? 'Полный каталог'
                    : widget.sectionName ?? 'Раздел каталога',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                widget.sectionId == null
                    ? 'Выберите подраздел, чтобы перейти к его записям.'
                    : 'Выберите конечный подраздел для просмотра предметов.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...currentChildren.map(
            (section) => _SectionTile(
              section: section,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ItemsPage(
                    collection: widget.collection,
                    sectionId: section.id,
                    sectionName: section.name,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItems(BuildContext context) {
    final itemsAsync = ref.watch(itemsProvider(widget.collection.id));
    final fieldsAsync = ref.watch(fieldsProvider(widget.collection.id));
    final valuesAsync = ref.watch(collectionItemValuesProvider(widget.collection.id));
    final ownedFieldId = _ownedFieldId();

    return _shell(
      context,
      title: widget.sectionName == null
          ? widget.collection.name
          : '${widget.collection.name} · ${widget.sectionName}',
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Ошибка: $error')),
        data: (items) => valuesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Ошибка значений: $error')),
          data: (values) {
            final fields = fieldsAsync.valueOrNull ?? widget.collection.fields;
            final prepared = _prepareItems(
              items.where((item) => item.sectionId == widget.sectionId).toList(),
              values,
            );
            final sortFields = _sortFields(fields);

            return RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Поиск по предметам',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => search = value),
                  ),
                  if (_isRussiaRegularCoins)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        'Для регулярного чекана России доступны сортировка по году, серии, редкости и наличию.',
                      ),
                    ),
                  if (_isRussiaRegularCoins && (sortField != null || ownedOnly))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (sortField != null)
                            Chip(
                              label: Text('Сортировка: ${_fieldLabel(fields, sortField!)}'),
                            ),
                          if (ownedOnly)
                            const Chip(label: Text('Только имеющиеся')),
                        ],
                      ),
                    ),
                  if (_isRussiaRegularCoins)
                    Align(
                      alignment: Alignment.centerRight,
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.tune),
                        onSelected: (value) {
                          if (value == 'reverse') {
                            setState(() => descending = !descending);
                          } else if (value == 'owned') {
                            setState(() => ownedOnly = !ownedOnly);
                          } else if (value == 'clear') {
                            setState(() {
                              sortField = null;
                              descending = false;
                              ownedOnly = false;
                            });
                          } else if (value.startsWith('sort:')) {
                            setState(() => sortField = value.substring(5));
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            enabled: false,
                            child: Text('Сортировка'),
                          ),
                          ...sortFields.map(
                            (field) => PopupMenuItem(
                              value: 'sort:${field.id}',
                              child: Text('По ${_fieldLabel(fields, field.id).toLowerCase()}'),
                            ),
                          ),
                          if (ownedFieldId != null)
                            PopupMenuItem(
                              value: 'owned',
                              child: Text(ownedOnly ? 'Показать все' : 'Только имеющиеся'),
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
                        ],
                      ),
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
                              'Измените поиск или фильтр.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...prepared.asMap().entries.map(
                      (entry) => _ItemCard(
                        item: entry.value,
                        index: entry.key,
                        values: values,
                        fields: fields,
                        owned: _owned(entry.value, values),
                        hasOwnedField: ownedFieldId != null,
                        onOwnedChanged: (value) => _setOwned(entry.value, value),
                        onOpen: () => _openItem(entry.value),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _setOwned(Item item, bool owned) async {
    final fieldId = _ownedFieldId();
    if (fieldId == null) return;

    await ref.read(itemServiceProvider).saveValue(
      ItemValue(
        id: '${item.id}_$fieldId',
        itemId: item.id,
        fieldId: fieldId,
        value: owned ? 'true' : 'false',
      ),
    );

    if (!mounted) return;
    ref.invalidate(collectionItemValuesProvider(widget.collection.id));
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
}

class _SectionTile extends StatelessWidget {
  final CollectionSection section;
  final VoidCallback onTap;

  const _SectionTile({required this.section, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.folder_outlined)),
        title: Text(
          section.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Item item;
  final int index;
  final Map<String, Map<String, String>> values;
  final List<dynamic> fields;
  final bool owned;
  final bool hasOwnedField;
  final ValueChanged<bool> onOwnedChanged;
  final VoidCallback onOpen;

  const _ItemCard({
    required this.item,
    required this.index,
    required this.values,
    required this.fields,
    required this.owned,
    required this.hasOwnedField,
    required this.onOwnedChanged,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final itemValues = values[item.id] ?? const <String, String>{};
    final visible = fields
        .where((field) {
          final value = itemValues[field.id] ?? '';
          return value.isNotEmpty &&
              field.id != _ownedFieldId(fields);
        })
        .take(3)
        .toList();

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
                visible
                    .skip(1)
                    .map((field) => '${field.label}: ${itemValues[field.id]}')
                    .join(' · '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
        onTap: onOpen,
        trailing: hasOwnedField
            ? Checkbox(
                value: owned,
                onChanged: (value) => onOwnedChanged(value ?? false),
              )
            : null,
      ),
    );
  }

  String? _ownedFieldId(List<dynamic> fields) {
    for (final field in fields) {
      if (field.id.endsWith('_owned') || field.id == 'owned') return field.id;
    }
    return null;
  }
}
