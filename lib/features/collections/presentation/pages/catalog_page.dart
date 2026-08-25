import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/settings/currency_settings.dart';
import '../../../../core/settings/ui_layout_settings.dart';
import '../../../catalogs/data/catalog_registry.dart';
import '../../../catalogs/data/catalog_ui_localization.dart';
import '../../../catalogs/data/catalog_version_store.dart';
import '../../../catalogs/domain/entities/catalog_category_definition.dart';
import '../../../catalogs/domain/entities/catalog_definition.dart';
import '../../../catalogs/domain/entities/catalog_entry_definition.dart';
import '../../../catalogs/presentation/catalog_category_page.dart';
import '../../../catalogs/presentation/catalog_online_page.dart';
import '../../../downloads/presentation/download_queue_provider.dart';
import '../../../items/domain/entities/item.dart';
import '../../../items/domain/entities/item_value.dart';
import '../../../items/presentation/pages/items_page.dart';
import '../../../items/presentation/providers/item_service_provider.dart';
import '../../domain/entities/collection.dart';
import '../../domain/entities/collection_section.dart';
import '../../domain/services/collection_section_service.dart';
import '../providers/collection_provider.dart';
import '../providers/collection_section_service_provider.dart';
import '../providers/collection_service_provider.dart';

class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({super.key});

  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
  String _search = '';
  VoidCallback? _layoutListener;

  @override
  void initState() {
    super.initState();
    _layoutListener = _reloadLayout;
    UiLayoutSettings.revision.addListener(_layoutListener!);
    UiLayoutSettings.ensureLoaded();
  }

  @override
  void dispose() {
    final listener = _layoutListener;
    if (listener != null) UiLayoutSettings.revision.removeListener(listener);
    super.dispose();
  }

  Future<void> _reloadLayout() async {
    await UiLayoutSettings.ensureLoaded();
    if (mounted) setState(() {});
  }

  Future<void> _selectCurrency(String code) async {
    await CurrencySettings.setCode(code);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(CurrencySettings.label(context))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = _filteredCategories(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.catalog, style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Валюта',
            icon: const Icon(Icons.currency_exchange_rounded),
            onSelected: _selectCurrency,
            itemBuilder: (_) => [
              for (final option in CurrencySettings.options)
                CheckedPopupMenuItem<String>(
                  value: option.code,
                  checked: option.code == CurrencySettings.code,
                  child: Text('${option.symbol} ${option.name(Localizations.localeOf(context))}'),
                ),
            ],
          ),
          IconButton(
            tooltip: l10n.search,
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _showSearch(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reloadLayout,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            _SectionTitle(title: l10n.categories, icon: Icons.category_outlined),
            const SizedBox(height: 10),
            categories.isEmpty ? _buildEmpty(context, l10n) : _buildCategories(context, categories),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context, List<CatalogCategoryDefinition> categories) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = UiLayoutSettings.resolveColumns(constraints.maxWidth);
        final textScale = MediaQuery.textScalerOf(context).scale(1.0);
        final columnWidth = (constraints.maxWidth - (columns - 1) * 12) / columns;
        final titlesFit = categories.every((category) {
          final title = CatalogUiLocalization.categoryName(context, category.id);
          final style = Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800);
          final painter = TextPainter(
            text: TextSpan(text: title, style: style),
            maxLines: 2,
            textDirection: Directionality.of(context),
          )..layout(maxWidth: (columnWidth - 28).clamp(40.0, 1000.0));
          return !painter.didExceedMaxLines;
        });
        final showText = columns == 1 || titlesFit;
        final height = showText ? (118 * textScale).clamp(104.0, 170.0).toDouble() : 82.0;

        if (columns == 1) {
          return Column(
            children: [
              for (final category in categories)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CategoryListTile(
                    category: category,
                    title: CatalogUiLocalization.categoryName(context, category.id),
                    onTap: () => _openCategory(category),
                  ),
                ),
            ],
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: height,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return _CategoryCard(
              category: category,
              title: CatalogUiLocalization.categoryName(context, category.id),
              showText: showText,
              onTap: () => _openCategory(category),
            );
          },
        );
      },
    );
  }

  Future<void> _openCategory(CatalogCategoryDefinition category) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CatalogCategoryPage(categoryId: category.id, onDownload: _downloadCatalog),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Center(child: Text(l10n.noResults, textAlign: TextAlign.center)),
    );
  }

  List<CatalogCategoryDefinition> _filteredCategories(BuildContext context) {
    final query = _search.trim().toLowerCase();
    if (query.isEmpty) return CatalogRegistry.categories;
    return CatalogRegistry.categories.where((category) {
      final name = CatalogUiLocalization.categoryName(context, category.id).toLowerCase();
      return name.contains(query) || category.catalogIds.any((id) => CatalogUiLocalization.catalogName(context, id).toLowerCase().contains(query));
    }).toList(growable: false);
  }

  Future<void> _showSearch(BuildContext context) async {
    final controller = TextEditingController(text: _search);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context).search),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: AppLocalizations.of(context).searchHint),
          onChanged: (value) => setState(() => _search = value),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(AppLocalizations.of(context).back)),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> _openCatalog(CatalogDefinition catalog) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CatalogOnlinePage(catalog: catalog, onDownload: () => _downloadCatalog(catalog)),
      ),
    );
  }

  Future<void> _downloadCatalog(CatalogDefinition catalog) async {
    final localCollections = ref.read(collectionsProvider).valueOrNull;
    final existing = localCollections?.where((collection) => collection.templateId == catalog.templateId).firstOrNull;
    if (existing != null) {
      await _openLocalCollection(existing);
      return;
    }
    ref.read(downloadQueueProvider.notifier).add(catalog.id, catalog.name);
    try {
      final collectionId = 'catalog_${catalog.id}_${DateTime.now().microsecondsSinceEpoch}';
      final now = DateTime.now();
      final fields = catalog.template.fields.map((field) => field.copyWith(id: '${collectionId}_${field.id}', collectionId: collectionId)).toList(growable: false);
      final collection = Collection(id: collectionId, name: catalog.name, templateId: catalog.templateId, fields: fields, createdAt: now, updatedAt: now);
      await ref.read(collectionServiceProvider).createCollection(collection);
      final sectionService = await ref.read(collectionSectionServiceProvider.future);
      final sectionIds = <String, String>{};
      await _createSections(sectionService, catalog.sections, collectionId, null, const [], sectionIds);
      final itemService = ref.read(itemServiceProvider);
      for (var index = 0; index < catalog.entries.length; index++) {
        final entry = catalog.entries[index];
        final itemId = '${collectionId}_item_${entry.id}';
        await itemService.saveItem(Item(id: itemId, collectionId: collectionId, sectionId: _sectionIdForPath(entry.sectionPath, sectionIds), sortOrder: index, createdAt: now, updatedAt: now));
        for (final field in fields) {
          final value = _entryValue(entry, field.id, field.label);
          if (value == null || value.isEmpty) continue;
          await itemService.saveValue(ItemValue(id: '${itemId}_${field.id}', itemId: itemId, fieldId: field.id, value: value));
        }
      }
      await CatalogVersionStore.markInstalled(catalog.id, catalog.version);
      ref.invalidate(collectionsProvider);
      if (mounted) await _openLocalCollection(collection);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка загрузки «${catalog.name}»: $error')));
    } finally {
      ref.read(downloadQueueProvider.notifier).remove(catalog.id);
    }
  }

  String? _entryValue(CatalogEntryDefinition entry, String fieldId, String label) {
    if (fieldId.endsWith('_owned') || fieldId == 'owned') return 'false';
    if (fieldId.endsWith('_quantity') && !entry.attributes.containsKey(label) && !entry.attributes.containsKey(fieldId)) return '0';
    return entry.attributes[fieldId] ?? entry.attributes[label];
  }

  String? _sectionIdForPath(List<String> path, Map<String, String> sectionIds) => path.isEmpty ? null : sectionIds[path.join('/')];

  Future<void> _createSections(CollectionSectionService service, List<CatalogSectionDefinition> definitions, String collectionId, String? parentId, List<String> path, Map<String, String> sectionIds) async {
    for (var index = 0; index < definitions.length; index++) {
      final definition = definitions[index];
      final currentPath = [...path, definition.id];
      final id = '${collectionId}_section_${currentPath.join('_')}';
      final now = DateTime.now();
      sectionIds[currentPath.join('/')] = id;
      await service.createSection(CollectionSection(id: id, collectionId: collectionId, parentId: parentId, name: definition.name, sortOrder: index, createdAt: now, updatedAt: now));
      await _createSections(service, definition.children, collectionId, id, currentPath, sectionIds);
    }
  }

  Future<void> _openLocalCollection(Collection collection) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ItemsPage(collection: collection)));
    if (mounted) ref.invalidate(collectionsProvider);
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) => Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 21),
            const SizedBox(width: 8),
            Flexible(child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
          ],
        ),
      );
}

class _CategoryListTile extends StatelessWidget {
  final CatalogCategoryDefinition category;
  final String title;
  final VoidCallback onTap;
  const _CategoryListTile({required this.category, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(width: 52, height: 52, decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(15)), child: Icon(_icon(category.id), color: colors.primary)),
          title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      ),
    );
  }

  IconData _icon(String id) => switch (id) {
        'constructors' => Icons.extension_rounded,
        'numismatics' => Icons.monetization_on_outlined,
        'banknotes' => Icons.payments_outlined,
        'cards' => Icons.style_outlined,
        'video_games' => Icons.sports_esports_outlined,
        'consoles' => Icons.gamepad_outlined,
        'movies' => Icons.movie_outlined,
        'figurines' => Icons.toys_outlined,
        'books' => Icons.menu_book_outlined,
        'music' => Icons.album_outlined,
        'sports' => Icons.emoji_events_outlined,
        'art' => Icons.palette_outlined,
        'antiques' => Icons.history_edu_outlined,
        _ => Icons.category_outlined,
      };
}

class _CategoryCard extends StatelessWidget {
  final CatalogCategoryDefinition category;
  final String title;
  final bool showText;
  final VoidCallback onTap;
  const _CategoryCard({required this.category, required this.title, required this.showText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: showText
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 48, height: 48, decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(14)), child: Icon(_icon(category.id), color: colors.primary)),
                    const SizedBox(height: 6),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
                  ],
                )
              : Container(width: 50, height: 50, decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(14)), child: Icon(_icon(category.id), color: colors.primary)),
        ),
      ),
    );
  }

  IconData _icon(String id) => switch (id) {
        'constructors' => Icons.extension_rounded,
        'numismatics' => Icons.monetization_on_outlined,
        'banknotes' => Icons.payments_outlined,
        'cards' => Icons.style_outlined,
        'video_games' => Icons.sports_esports_outlined,
        'consoles' => Icons.gamepad_outlined,
        'movies' => Icons.movie_outlined,
        'figurines' => Icons.toys_outlined,
        'books' => Icons.menu_book_outlined,
        'music' => Icons.album_outlined,
        'sports' => Icons.emoji_events_outlined,
        'art' => Icons.palette_outlined,
        'antiques' => Icons.history_edu_outlined,
        _ => Icons.category_outlined,
      };
}
