import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage_location_providers.dart';

/// Показывает полный путь хранения конкретного физического экземпляра.
class ItemStorageLocationCard extends ConsumerWidget {
  final String itemId;
  const ItemStorageLocationCard({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = ref.watch(itemStorageLocationProvider(itemId));
    return path.when(
      loading: () => const ListTile(leading: Icon(Icons.location_on_outlined), title: Text('Загрузка места...')),
      error: (error, _) => ListTile(leading: const Icon(Icons.location_off_outlined), title: Text('Ошибка места хранения: $error')),
      data: (value) => ListTile(leading: const Icon(Icons.location_on_outlined), title: Text(value.isEmpty ? 'Место хранения не указано' : value)),
    );
  }
}
