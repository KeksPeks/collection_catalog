import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../collections/presentation/providers/collection_provider.dart';
import '../../items/data/item_state_store.dart';
import '../../items/presentation/providers/item_service_provider.dart';
import '../data/wishlist_store.dart';

class WishlistPage extends ConsumerStatefulWidget {
  const WishlistPage({super.key});

  @override
  ConsumerState<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends ConsumerState<WishlistPage> {
  bool _loading = true;
  String? _error;
  List<_WantedEntry> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final collections = await ref.read(collectionsProvider.future);
      final service = ref.read(itemServiceProvider);
      final ids = await WishlistStore.loadIds();
      final result = <_WantedEntry>[];
      for (final collection in collections) {
        final items = await service.getItems(collection.id);
        for (final item in items) {
          if (ids.contains(item.id)) result.add(_WantedEntry(item.id, item.title, collection.name));
        }
      }
      if (!mounted) return;
      setState(() { _items = result; _loading = false; });
    } catch (error) {
      if (!mounted) return;
      setState(() { _loading = false; _error = error.toString(); });
    }
  }

  Future<void> _remove(String id) async {
    await WishlistStore.remove(id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist'), actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))]),
      body: _error != null
          ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center)))
          : _items.isEmpty
              ? const Center(child: Text('Список желаний пуст'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Card(child: ListTile(title: Text(item.title), subtitle: Text(item.collection), trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _remove(item.id))));
                  },
                ),
    );
  }
}

class _WantedEntry {
  final String id;
  final String title;
  final String collection;
  const _WantedEntry(this.id, this.title, this.collection);
}
