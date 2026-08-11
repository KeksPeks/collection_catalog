import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/collection_provider.dart';
import 'collection_detail_page.dart';

/// Главный рабочий каталог коллекций.
class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({super.key});

  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
  String search = '';
  String sort = 'name';
  bool descending = false;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(collectionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                if (value == 'reverse') {
                  descending = !descending;
                } else {
                  sort = value;
                }
              });
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'name', child: Text('По названию')),
              const PopupMenuItem(value: 'date', child: Text('По дате создания')),
              PopupMenuItem(
                value: 'reverse',
                child: Text(descending ? 'Прямой порядок' : 'Обратный порядок'),
              ),
            ],
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Ошибка: $error')),
        data: (collections) {
          final filtered = collections.where((collection) {
            return collection.name.toLowerCase().contains(search.toLowerCase());
          }).toList();

          filtered.sort((a, b) {
            final result = sort == 'date'
                ? a.createdAt.compareTo(b.createdAt)
                : a.name.toLowerCase().compareTo(b.name.toLowerCase());
            return descending ? -result : result;
          });

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
                    hintText: 'Поиск по каталогам',
                    suffixIcon: search.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => search = ''),
                          ),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => search = value),
                ),
                const SizedBox(height: 16),
                if (filtered.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            collections.isEmpty ? 'Каталог пока пуст' : 'Ничего не найдено',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Создайте коллекцию во вкладке «Коллекции» или добавьте её из шаблона.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...filtered.map(
                    (collection) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: const CircleAvatar(
                            child: Icon(Icons.collections_bookmark),
                          ),
                          title: Text(collection.name),
                          subtitle: Text(
                            collection.templateId == null
                                ? '${collection.fields.length} полей • пользовательский каталог'
                                : '${collection.fields.length} полей • шаблон ${collection.templateId}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
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
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
