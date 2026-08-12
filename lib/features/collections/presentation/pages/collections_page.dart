import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/collection.dart';
import '../providers/collection_provider.dart';
import '../providers/collection_service_provider.dart';
import 'collection_detail_page.dart';
import 'edit_collection_page.dart';

/// Экран загруженных пользователем каталогов.
///
/// Готовые каталоги находятся во вкладке «Каталог». После скачивания
/// локальная копия появляется здесь и используется для ведения коллекции.
class CollectionsPage extends ConsumerStatefulWidget {
  const CollectionsPage({super.key});

  @override
  ConsumerState<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends ConsumerState<CollectionsPage> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(collectionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Мои коллекции')),
      body: collections.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Ошибка: $error')),
        data: (items) {
          final downloaded = items
              .where((item) => item.templateId != null)
              .toList(growable: false);
          final filtered = downloaded.where((item) {
            return item.name.toLowerCase().contains(_search.toLowerCase());
          }).toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(collectionsProvider);
              await ref.read(collectionsProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Поиск загруженной коллекции',
                    border: const OutlineInputBorder(),
                    suffixIcon: _search.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _search = ''),
                          ),
                  ),
                  onChanged: (value) => setState(() => _search = value),
                ),
                const SizedBox(height: 16),
                if (filtered.isEmpty)
                  _EmptyCollectionsCard(
                    hasCollections: downloaded.isNotEmpty,
                  )
                else
                  ...filtered.map(_buildCollectionTile),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCollectionTile(Collection collection) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: const CircleAvatar(
          child: Icon(Icons.collections_bookmark),
        ),
        title: Text(collection.name),
        subtitle: Text('Каталог сохранён на устройстве'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _collectionAction(collection, value),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'open', child: Text('Открыть')),
            PopupMenuItem(value: 'edit', child: Text('Изменить данные')),
            PopupMenuItem(value: 'delete', child: Text('Удалить локальную копию')),
          ],
        ),
        onTap: () => _openCollection(collection),
      ),
    );
  }

  Future<void> _collectionAction(Collection collection, String value) async {
    if (value == 'open') {
      await _openCollection(collection);
    } else if (value == 'edit') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EditCollectionPage(collection: collection),
        ),
      );
    } else if (value == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Удалить локальную копию?'),
          content: Text(collection.name),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Удалить'),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        await ref.read(collectionServiceProvider).deleteCollection(collection.id);
      }
    }

    if (!mounted) return;
    ref.invalidate(collectionsProvider);
  }

  Future<void> _openCollection(Collection collection) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CollectionDetailPage(
          collectionId: collection.id,
          collectionName: collection.name,
        ),
      ),
    );
    if (!mounted) return;
    ref.invalidate(collectionsProvider);
  }
}

class _EmptyCollectionsCard extends StatelessWidget {
  final bool hasCollections;

  const _EmptyCollectionsCard({required this.hasCollections});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.download_outlined, size: 52),
            const SizedBox(height: 12),
            Text(
              hasCollections
                  ? 'Ничего не найдено'
                  : 'Загруженных коллекций пока нет',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Откройте вкладку «Каталог», выберите нужный сборник и нажмите кнопку загрузки.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
