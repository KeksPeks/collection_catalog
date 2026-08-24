import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/settings/ui_layout_settings.dart';
import '../../domain/entities/collection.dart';
import '../providers/collection_provider.dart';
import 'collection_detail_page.dart';

/// Экран загруженных каталогов.
///
/// Каталоги и их структура поставляются приложением. Пользователь не может
/// менять каталог, удалять его содержимое или добавлять новые записи.
class CollectionsPage extends ConsumerStatefulWidget {
  const CollectionsPage({super.key});

  @override
  ConsumerState<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends ConsumerState<CollectionsPage> {
  String _search = '';
  VoidCallback? _layoutListener;

  @override
  void initState() {
    super.initState();
    _layoutListener = () {
      if (mounted) setState(() {});
    };
    UiLayoutSettings.revision.addListener(_layoutListener!);
    UiLayoutSettings.ensureLoaded();
  }

  @override
  void dispose() {
    final listener = _layoutListener;
    if (listener != null) UiLayoutSettings.revision.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(collectionsProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Мои коллекции'),
      ),
      body: collections.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Ошибка: $error')),
        data: (items) {
          final downloaded = items.where((item) => item.templateId != null).toList(growable: false);
          final filtered = downloaded.where((item) => item.name.toLowerCase().contains(_search.toLowerCase())).toList(growable: false);

          return LayoutBuilder(
            builder: (context, constraints) {
              final columns = UiLayoutSettings.resolveColumns(constraints.maxWidth);
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(collectionsProvider);
                  await ref.read(collectionsProvider.future);
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      sliver: SliverToBoxAdapter(child: _buildSearchField()),
                    ),
                    if (filtered.isEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverToBoxAdapter(child: _EmptyCollectionsCard(hasCollections: downloaded.isNotEmpty)),
                      )
                    else if (columns == 1)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _buildCollectionTile(filtered[index]),
                            ),
                            childCount: filtered.length,
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildCollectionTile(filtered[index]),
                            childCount: filtered.length,
                          ),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent: UiLayoutSettings.cardHeight,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Поиск загруженной коллекции',
        border: const OutlineInputBorder(),
        suffixIcon: _search.isEmpty
            ? null
            : IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _search = '')),
      ),
      onChanged: (value) => setState(() => _search = value),
    );
  }

  Widget _buildCollectionTile(Collection collection) {
    return SizedBox(
      height: UiLayoutSettings.cardHeight,
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: const CircleAvatar(child: Icon(Icons.collections_bookmark)),
          title: Text(collection.name),
          subtitle: const Text('Каталог сохранён на устройстве'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _openCollection(collection),
        ),
      ),
    );
  }

  Future<void> _openCollection(Collection collection) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CollectionDetailPage(collectionId: collection.id, collectionName: collection.name),
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
              hasCollections ? 'Ничего не найдено' : 'Загруженных коллекций пока нет',
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
