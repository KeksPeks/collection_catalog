import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/settings/ui_layout_settings.dart';
import '../../../catalogs/data/catalog_registry.dart';
import '../../domain/entities/collection.dart';
import '../providers/collection_provider.dart';
import '../../../items/presentation/pages/items_page.dart';

/// Экран загруженных каталогов.
/// Здесь пользователь видит именно те каталоги, которые загрузил на устройство.
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

  /// Название коллекции всегда берём из централизованного реестра.
  /// Благодаря этому «Нумизматика» не превращается после загрузки в «Монеты».
  String _displayName(Collection collection) {
    final templateId = collection.templateId;
    if (templateId != null && templateId.isNotEmpty) {
      final matches = CatalogRegistry.all
          .where((catalog) => catalog.templateId == templateId)
          .toList(growable: false);
      if (matches.length == 1) return matches.first.name;
    }
    return collection.name;
  }

  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(collectionsProvider);
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Мои коллекции')),
      body: collections.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _DatabaseError(
          error: error,
          onRetry: () => ref.invalidate(collectionsProvider),
        ),
        data: (items) {
          final downloaded = items
              .where((item) => item.templateId != null)
              .toList(growable: false);
          final query = _search.trim().toLowerCase();
          final filtered = downloaded
              .where((item) => _displayName(item).toLowerCase().contains(query))
              .toList(growable: false);

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
                        sliver: SliverToBoxAdapter(
                          child: _EmptyCollectionsCard(
                            hasCollections: downloaded.isNotEmpty,
                          ),
                        ),
                      )
                    else if (columns == 1)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _buildCollectionTile(
                                filtered[index],
                                compact: false,
                              ),
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
                            (context, index) => _buildCollectionTile(
                              filtered[index],
                              compact: true,
                            ),
                            childCount: filtered.length,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.55,
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
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => _search = ''),
              ),
      ),
      onChanged: (value) => setState(() => _search = value),
    );
  }

  Widget _buildCollectionTile(Collection collection, {required bool compact}) {
    final displayName = _displayName(collection);

    if (!compact) {
      return Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: const CircleAvatar(
            child: Icon(Icons.collections_bookmark),
          ),
          title: Text(
            displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: const Text(
            'Каталог сохранён на устройстве',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _openCollection(collection),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final titleStyle = Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(fontWeight: FontWeight.w800);
        final painter = TextPainter(
          text: TextSpan(text: displayName, style: titleStyle),
          maxLines: 1,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth - 12);
        final showTitle = !painter.didExceedMaxLines &&
            painter.width <= constraints.maxWidth - 12;

        return Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _openCollection(collection),
            child: Center(
              child: showTitle
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          child: Icon(Icons.collections_bookmark),
                        ),
                        const SizedBox(height: 3),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            textAlign: TextAlign.center,
                            style: titleStyle,
                          ),
                        ),
                      ],
                    )
                  : const CircleAvatar(
                      child: Icon(Icons.collections_bookmark),
                    ),
            ),
          ),
        );
      },
    );
  }

  /// Открываем загруженный каталог сразу как каталог предметов.
  /// Промежуточная техническая страница с внутренними ID, полями и
  /// малопонятной статистикой для пользователя больше не показывается.
  Future<void> _openCollection(Collection collection) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ItemsPage(collection: collection),
      ),
    );
    if (mounted) ref.invalidate(collectionsProvider);
  }
}

class _DatabaseError extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _DatabaseError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storage_outlined, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Не удалось открыть локальную базу данных',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('$error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
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
