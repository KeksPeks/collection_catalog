import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/item_provider.dart';
import 'catalog_item_instances_page.dart';

/// Карточка каталожной позиции.
///
/// Здесь отображается модель каталога и количество физических экземпляров.
/// Индивидуальные данные экземпляров открываются отдельно.
class CatalogItemDetailPage extends ConsumerWidget {
  final String catalogItemId;
  final String collectionId;
  final String title;

  const CatalogItemDetailPage({
    super.key,
    required this.catalogItemId,
    required this.collectionId,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instancesAsync =
        ref.watch(catalogItemInstancesProvider(catalogItemId));

    return Scaffold(
      appBar: AppBar(title: const Text('Каталожный предмет')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 42),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('Каталожная позиция: $catalogItemId'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          instancesAsync.when(
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (error, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Ошибка загрузки экземпляров: $error'),
              ),
            ),
            data: (instances) => Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.copy_all_outlined),
                    title: const Text('В моей коллекции'),
                    subtitle: Text(
                      instances.isEmpty
                          ? 'Экземпляров пока нет'
                          : '${instances.length} физических экземпляров',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openInstances(context),
                  ),
                  if (instances.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _openInstances(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Добавить первый экземпляр'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Каталог и экземпляры разделены'),
              subtitle: const Text(
                'Эта карточка описывает модель каталога. Цена, состояние, комплектность, место хранения и другие личные данные принадлежат конкретному физическому экземпляру.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openInstances(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CatalogItemInstancesPage(
          catalogItemId: catalogItemId,
          collectionId: collectionId,
          title: title,
        ),
      ),
    );
  }
}
