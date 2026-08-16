import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/catalogs/data/catalog_registry.dart';
import '../../../../features/catalogs/domain/entities/catalog_definition.dart';
import '../../../../features/catalogs/presentation/catalog_online_page.dart';
import '../../../../features/downloads/presentation/download_queue_provider.dart';
import '../../../items/presentation/providers/item_service_provider.dart';
import '../../domain/entities/collection.dart';
import '../../domain/entities/collection_section.dart';
import '../../domain/services/collection_section_service.dart';
import '../providers/collection_provider.dart';
import '../providers/collection_section_service_provider.dart';
import '../providers/collection_service_provider.dart';
import 'collection_detail_page.dart';

/// Главный экран готовых каталогов.
///
/// Здесь используется отдельный визуальный слой, но сами каталоги,
/// коллекции и сервисы остаются прежними.
class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({super.key});

  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
  String _search = '';
  String _selectedType = 'Все';
  String _sort = 'name';
  bool _descending = false;

  @override
  Widget build(BuildContext context) {
    final collections =
        ref.watch(collectionsProvider).valueOrNull ?? const <Collection>[];
    final catalogs = _filteredCatalogs();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(collectionsProvider);
          try {
            await ref.read(collectionsProvider.future);
          } catch (_) {
            // Каталоги доступны и без локальной базы.
          }
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              titleSpacing: 20,
              title: const Text(
                'Каталог',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              actions: [
                PopupMenuButton<String>(
                  tooltip: 'Сортировка',
                  icon: const Icon(Icons.sort_rounded),
                  onSelected: (value) {
                    setState(() {
                      if (value == 'reverse') {
                        _descending = !_descending;
                      } else {
                        _sort = value;
                      }
                    });
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'name',
                      child: Text('По названию'),
                    ),
                    const PopupMenuItem(
                      value: 'type',
                      child: Text('По типу'),
                    ),
                    PopupMenuItem(
                      value: 'reverse',
                      child: Text(
                        _descending
                            ? 'Прямой порядок'
                            : 'Обратный порядок',
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  final contentWidth = width >= 1100 ? 1060.0 : width;
                  final horizontalPadding =
                      ((width - contentWidth) / 2).clamp(0.0, double.infinity);

                  return SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildHero(context, colorScheme, catalogs.length),
                        const SizedBox(height: 20),
                        _buildSearch(context),
                        const SizedBox(height: 14),
                        _buildFilters(context),
                        const SizedBox(height: 24),
                        if (catalogs.isEmpty)
                          _buildEmptyState(context)
                        else
                          _buildCatalogGrid(
                            context,
                            catalogs,
                            collections,
                          ),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(
    BuildContext context,
    ColorScheme colorScheme,
    int visibleCount,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$visibleCount каталогов доступно',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Собирайте свою коллекцию',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Text(
                  'Выберите готовый каталог, изучайте его онлайн и сохраняйте нужные каталоги на устройстве.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    height: 1.45,
                  ),
                ),
              ),
            ],
          );

          if (compact) return text;

          return Row(
            children: [
              Expanded(child: text),
              const SizedBox(width: 24),
              Icon(
                Icons.collections_bookmark_rounded,
                size: 86,
                color: colorScheme.primary.withValues(alpha: 0.22),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearch(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: TextEditingController(text: _search)
        ..selection = TextSelection.collapsed(offset: _search.length),
      onChanged: (value) => setState(() => _search = value),
      decoration: InputDecoration(
        labelText: 'Поиск каталогов',
        hintText: 'Например: монеты, Pokémon, фигурки...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _search.isEmpty
            ? null
            : IconButton(
                tooltip: 'Очистить',
                icon: const Icon(Icons.close_rounded),
                onPressed: () => setState(() => _search = ''),
              ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final types = <String>['Все', ..._catalogTypes()];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final type in types) ...[
            ChoiceChip(
              label: Text(type),
              selected: _selectedType == type,
              onSelected: (_) => setState(() => _selectedType = type),
              avatar: type == 'Все'
                  ? const Icon(Icons.apps_rounded, size: 18)
                  : Icon(_iconForType(type), size: 18),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildCatalogGrid(
    BuildContext context,
    List<CatalogDefinition> catalogs,
    List<Collection> collections,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 590
                ? 2
                : 1;

        if (columns == 1) {
          return Column(
            children: [
              for (final catalog in catalogs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _CatalogCard(
                    catalog: catalog,
                    localCollection: _findLocalCollection(catalog, collections),
                    ownedFuture: _ownedFuture(catalog, collections),
                    onOpen: () => _openOnline(catalog),
                    onAction: () => _actionForCatalog(catalog, collections),
                  ),
                ),
            ],
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: catalogs.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: columns == 3 ? 1.18 : 1.22,
          ),
          itemBuilder: (context, index) {
            final catalog = catalogs[index];
            return _CatalogCard(
              catalog: catalog,
              localCollection: _findLocalCollection(catalog, collections),
              ownedFuture: _ownedFuture(catalog, collections),
              onOpen: () => _openOnline(catalog),
              onAction: () => _actionForCatalog(catalog, collections),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 52,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(height: 14),
          Text(
            'Ничего не найдено',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Измените запрос или выберите другой тип каталога.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  List<String> _catalogTypes() {
    final values = CatalogRegistry.all
        .map(_typeName)
        .toSet()
        .toList(growable: false);
    values.sort();
    return values;
  }

  String _typeName(CatalogDefinition catalog) {
    switch (catalog.id) {
      case 'coins':
        return 'Монеты';
      case 'banknotes':
        return 'Банкноты';
      case 'pokemon_tcg':
        return 'Карточки';
      case 'discs':
        return 'Диски';
      case 'games':
        return 'Игры';
      case 'movies':
        return 'Фильмы';
      case 'figurines':
        return 'Фигурки';
      default:
        return 'Другое';
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'Монеты':
        return Icons.monetization_on_outlined;
      case 'Банкноты':
        return Icons.payments_outlined;
      case 'Карточки':
        return Icons.style_outlined;
      case 'Диски':
        return Icons.album_outlined;
      case 'Игры':
        return Icons.sports_esports_outlined;
      case 'Фильмы':
        return Icons.movie_outlined;
      case 'Фигурки':
        return Icons.toys_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  List<CatalogDefinition> _filteredCatalogs() {
    final query = _search.trim().toLowerCase();
    final result = CatalogRegistry.all.where((catalog) {
      final matchesSearch = query.isEmpty ||
          catalog.name.toLowerCase().contains(query) ||
          catalog.description.toLowerCase().contains(query);
      final matchesType =
          _selectedType == 'Все' || _typeName(catalog) == _selectedType;
      return matchesSearch && matchesType;
    }).toList();

    result.sort((a, b) {
      final value = _sort == 'type'
          ? _typeName(a).compareTo(_typeName(b))
          : a.name.toLowerCase().compareTo(b.name.toLowerCase());
      return _descending ? -value : value;
    });

    return result;
  }

  Future<int> _ownedFuture(
    CatalogDefinition catalog,
    List<Collection> collections,
  ) {
    final localCollection = _findLocalCollection(catalog, collections);
    if (localCollection == null) return Future<int>.value(0);
    return ref
        .read(itemServiceProvider)
        .getItems(localCollection.id)
        .then((items) => items.length);
  }

  Collection? _findLocalCollection(
    CatalogDefinition catalog,
    List<Collection> collections,
  ) {
    for (final collection in collections) {
      if (collection.templateId == catalog.templateId) return collection;
    }
    return null;
  }

  Future<void> _actionForCatalog(
    CatalogDefinition catalog,
    List<Collection> collections,
  ) async {
    final localCollection = _findLocalCollection(catalog, collections);
    if (localCollection == null) {
      await _downloadCatalog(catalog);
    } else {
      await _openLocalCollection(localCollection);
    }
  }

  Future<void> _openOnline(CatalogDefinition catalog) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CatalogOnlinePage(
          catalog: catalog,
          onDownload: () async {
            await _downloadCatalog(catalog);
            if (!mounted) return;
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Future<void> _openLocalCollection(Collection collection) async {
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

  Future<void> _downloadCatalog(CatalogDefinition catalog) async {
    final localCollections = ref.read(collectionsProvider).valueOrNull;
    if (localCollections != null) {
      for (final collection in localCollections) {
        if (collection.templateId == catalog.templateId) {
          await _openLocalCollection(collection);
          return;
        }
      }
    }

    ref.read(downloadQueueProvider.notifier).add(catalog.id, catalog.name);

    try {
      final collectionId =
          'catalog_${catalog.id}_${DateTime.now().microsecondsSinceEpoch}';
      final now = DateTime.now();
      final fields = catalog.template.fields
          .map(
            (field) => field.copyWith(
              id: '${collectionId}_${field.id}',
              collectionId: collectionId,
            ),
          )
          .toList(growable: false);

      final collection = Collection(
        id: collectionId,
        name: catalog.name,
        templateId: catalog.templateId,
        fields: fields,
        createdAt: now,
        updatedAt: now,
      );

      await ref.read(collectionServiceProvider).createCollection(collection);
      final sectionService =
          await ref.read(collectionSectionServiceProvider.future);
      await _createSections(
        sectionService,
        catalog.sections,
        collectionId,
        null,
      );

      ref.invalidate(collectionsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Каталог «${catalog.name}» сохранён на устройстве'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось скачать каталог: $error')),
      );
    } finally {
      ref.read(downloadQueueProvider.notifier).remove(catalog.id);
    }
  }

  Future<void> _createSections(
    CollectionSectionService service,
    List<CatalogSectionDefinition> definitions,
    String collectionId,
    String? parentId,
  ) async {
    for (var index = 0; index < definitions.length; index++) {
      final definition = definitions[index];
      final id = '${collectionId}_section_${definition.id}';
      final now = DateTime.now();
      await service.createSection(
        CollectionSection(
          id: id,
          collectionId: collectionId,
          parentId: parentId,
          name: definition.name,
          sortOrder: index,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await _createSections(
        service,
        definition.children,
        collectionId,
        id,
      );
    }
  }
}

class _CatalogCard extends StatelessWidget {
  final CatalogDefinition catalog;
  final Collection? localCollection;
  final Future<int> ownedFuture;
  final VoidCallback onOpen;
  final VoidCallback onAction;

  const _CatalogCard({
    required this.catalog,
    required this.localCollection,
    required this.ownedFuture,
    required this.onOpen,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final downloaded = localCollection != null;
    final total = catalog.totalItems?.toString() ?? '—';

    return Material(
      color: colors.surface,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onOpen,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      _iconForCatalog(catalog.id),
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const Spacer(),
                  IconButton.filledTonal(
                    tooltip: downloaded
                        ? 'Открыть мою коллекцию'
                        : 'Сохранить каталог',
                    onPressed: onAction,
                    icon: Icon(
                      downloaded
                          ? Icons.collections_bookmark_rounded
                          : Icons.download_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                catalog.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w750,
                ),
              ),
              const SizedBox(height: 7),
              Expanded(
                child: Text(
                  catalog.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Stat(
                      icon: Icons.inventory_2_outlined,
                      value: total,
                      label: 'Всего',
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<int>(
                      future: ownedFuture,
                      builder: (context, snapshot) => _Stat(
                        icon: Icons.check_circle_outline_rounded,
                        value: '${snapshot.data ?? 0}',
                        label: 'У меня',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    downloaded
                        ? Icons.cloud_done_outlined
                        : Icons.public_rounded,
                    size: 17,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      downloaded ? 'Сохранён на устройстве' : 'Онлайн-каталог',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _iconForCatalog(String id) {
    switch (id) {
      case 'coins':
        return Icons.monetization_on_outlined;
      case 'banknotes':
        return Icons.payments_outlined;
      case 'pokemon_tcg':
        return Icons.style_outlined;
      case 'discs':
        return Icons.album_outlined;
      case 'games':
        return Icons.sports_esports_outlined;
      case 'movies':
        return Icons.movie_outlined;
      case 'figurines':
        return Icons.toys_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 19, color: colors.onSurfaceVariant),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
