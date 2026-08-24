import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'wishlist_provider.dart';

/// Раздел «Хочу купить».
class WishlistPage extends ConsumerWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Хочу купить')),
      body: wishlist.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Ошибка: $error')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Wishlist пока пуст'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${item.priority}')),
                  title: Text(item.title),
                  subtitle: Text('${item.groupName}\n${item.priorityLabel}'),
                  isThreeLine: true,
                  trailing: IconButton(
                    tooltip: 'Удалить',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await ref.read(wishlistRepositoryProvider).delete(item.id);
                      ref.invalidate(wishlistProvider);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
