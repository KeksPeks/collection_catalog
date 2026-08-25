import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/storage_location.dart';
import '../storage_location_providers.dart';

class StorageLocationsPage extends ConsumerWidget {
  const StorageLocationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locations = ref.watch(storageLocationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Места хранения')),
      floatingActionButton: FloatingActionButton(onPressed: () => _addLocation(context, ref, null), child: const Icon(Icons.add)),
      body: locations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Ошибка: $error')),
        data: (items) {
          final roots = items.where((item) => item.parentId == null).toList();
          if (roots.isEmpty) return const Center(child: Text('Мест хранения пока нет'));
          return ListView(padding: const EdgeInsets.all(12), children: roots.map((root) => _LocationTile(location: root, all: items, ref: ref)).toList());
        },
      ),
    );
  }

  Future<void> _addLocation(BuildContext context, WidgetRef ref, String? parentId) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(context: context, builder: (context) => AlertDialog(
      title: Text(parentId == null ? 'Новое место' : 'Новое вложенное место'),
      content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'Название')),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')), FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Добавить'))],
    ));
    controller.dispose();
    if (name == null || name.isEmpty) return;
    final now = DateTime.now();
    await ref.read(storageLocationRepositoryProvider).save(StorageLocation(id: '${now.microsecondsSinceEpoch}', name: name, parentId: parentId, createdAt: now, updatedAt: now));
    ref.invalidate(storageLocationsProvider);
  }
}

class _LocationTile extends StatelessWidget {
  final StorageLocation location;
  final List<StorageLocation> all;
  final WidgetRef ref;
  const _LocationTile({required this.location, required this.all, required this.ref});

  @override
  Widget build(BuildContext context) {
    final children = all.where((item) => item.parentId == location.id).toList();
    return Card(child: ExpansionTile(
      leading: const Icon(Icons.folder_outlined),
      title: Text(location.name),
      children: [...children.map((child) => Padding(padding: const EdgeInsets.only(left: 20), child: _LocationTile(location: child, all: all, ref: ref))),
        ListTile(leading: const Icon(Icons.add), title: const Text('Добавить вложенное место'), onTap: () => _addChild(context)),
      ],
    ));
  }

  Future<void> _addChild(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(context: context, builder: (context) => AlertDialog(
      title: Text('Внутри «${location.name}»'),
      content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'Название')),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')), FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Добавить'))],
    ));
    controller.dispose();
    if (name == null || name.isEmpty) return;
    final now = DateTime.now();
    await ref.read(storageLocationRepositoryProvider).save(StorageLocation(id: '${now.microsecondsSinceEpoch}', name: name, parentId: location.id, createdAt: now, updatedAt: now));
    ref.invalidate(storageLocationsProvider);
  }
}
