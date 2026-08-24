import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalog/presentation/providers/catalog_provider.dart';
import '../../wishlist/presentation/wishlist_provider.dart';

/// Экран предметов, которых ещё нет в коллекции.
class MissingPage extends ConsumerWidget {
  const MissingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    final missing = catalog.where((item) => !item.isOwned).toList();

    final groups = <String, List<dynamic>>{};
    for (final item in missing) {
      final group = item.collectionName ?? item.publisher;
      groups.putIfAbsent(group, () => []).add(item);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Что мне осталось собрать')),
      body: missing.isEmpty
          ? const Center(child: Text('Все предметы каталога уже собраны'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                ...groups.entries.map(
                  (entry) => _MissingGroup(
                    title: entry.key,
                    items: entry.value,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () async {
                    final repository = ref.read(wishlistRepositoryProvider);
                    final added = await repository.addAll(
                      missing.map(
                        (item) => (
                          id: item.id,
                          title: item.title,
                          groupName: item.collectionName ?? item.publisher,
                        ),
                      ),
                    );
                    ref.invalidate(wishlistProvider);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          added == 0
                              ? 'Все отсутствующие предметы уже в Wishlist'
                              : 'Добавлено в Wishlist: $added',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.playlist_add),
                  label: const Text('Добавить всё в Wishlist'),
                ),
              ],
            ),
    );
  }
}

class _MissingGroup extends StatelessWidget {
  final String title;
  final List<dynamic> items;

  const _MissingGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                ListTile(
                  leading: const Icon(Icons.radio_button_unchecked),
                  title: Text(items[i].title),
                  subtitle: Text(items[i].platform),
                ),
                if (i < items.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
