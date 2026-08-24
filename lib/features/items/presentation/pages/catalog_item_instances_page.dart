import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/item_state_store.dart';
import '../../domain/entities/item.dart';
import '../providers/item_provider.dart';
import 'item_detail_page.dart';

/// Список физических экземпляров одной каталожной позиции.
class CatalogItemInstancesPage extends ConsumerStatefulWidget {
  final String catalogItemId;
  final String collectionId;
  final String? title;

  const CatalogItemInstancesPage({super.key, required this.catalogItemId, required this.collectionId, this.title});

  @override
  ConsumerState<CatalogItemInstancesPage> createState() => _CatalogItemInstancesPageState();
}

class _CatalogItemInstancesPageState extends ConsumerState<CatalogItemInstancesPage> {
  bool _creating = false;

  Future<void> _addInstance() async {
    if (_creating) return;
    setState(() => _creating = true);
    try {
      final service = ref.read(itemServiceProvider);
      final existing = await service.getItemsByCatalogItem(widget.catalogItemId);
      final now = DateTime.now();
      final item = Item(
        id: 'instance_${now.microsecondsSinceEpoch}',
        catalogItemId: widget.catalogItemId,
        collectionId: widget.collectionId,
        sortOrder: existing.length,
        createdAt: now,
        updatedAt: now,
      );
      await service.saveItem(item);
      await ItemStateStore.save(item.id, ItemState(status: CollectionItemStatus.owned, quantity: 1, updatedAt: now), title: '${widget.title ?? widget.catalogItemId} • Экземпляр #${existing.length + 1}', recordHistory: false);
      ref.invalidate(catalogItemInstancesProvider(widget.catalogItemId));
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ItemDetailPage(itemId: item.id)));
      ref.invalidate(catalogItemInstancesProvider(widget.catalogItemId));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Не удалось добавить экземпляр: $error')));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<void> _deleteInstance(Item item, int number) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text('Удалить экземпляр #$number?'),
        content: const Text('Будет удалён именно физический экземпляр. Каталожная позиция и остальные экземпляры останутся.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog, false), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(dialog, true), child: const Text('Удалить')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(itemServiceProvider).deleteItem(item.id);
      await ItemStateStore.remove(item.id);
      ref.invalidate(catalogItemInstancesProvider(widget.catalogItemId));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Не удалось удалить экземпляр: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final instancesAsync = ref.watch(catalogItemInstancesProvider(widget.catalogItemId));
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'Экземпляры'), actions: [IconButton(onPressed: _creating ? null : _addInstance, icon: const Icon(Icons.add))]),
      floatingActionButton: FloatingActionButton.extended(onPressed: _creating ? null : _addInstance, icon: const Icon(Icons.add), label: const Text('Добавить экземпляр')),
      body: instancesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Ошибка: $error')),
        data: (instances) => instances.isEmpty
            ? const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Физических экземпляров пока нет.\n\nДобавьте первый экземпляр.', textAlign: TextAlign.center)))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                itemCount: instances.length,
                itemBuilder: (context, index) {
                  final item = instances[index];
                  final number = index + 1;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(child: Text('$number')),
                      title: Text('Экземпляр #$number'),
                      subtitle: Text('ID: ${item.id}'),
                      trailing: PopupMenuButton<String>(onSelected: (value) { if (value == 'delete') _deleteInstance(item, number); }, itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Text('Удалить экземпляр'))]),
                      onTap: () async { await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ItemDetailPage(itemId: item.id))); ref.invalidate(catalogItemInstancesProvider(widget.catalogItemId)); },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
