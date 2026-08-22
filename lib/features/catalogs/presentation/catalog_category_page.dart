import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../data/catalog_registry.dart';
import '../data/catalog_ui_localization.dart';
import '../domain/entities/catalog_category_definition.dart';
import '../domain/entities/catalog_definition.dart';
import 'catalog_online_page.dart';

class CatalogCategoryPage extends StatelessWidget {
  final String categoryId;
  final Future<void> Function(CatalogDefinition catalog)? onDownload;

  const CatalogCategoryPage({super.key, required this.categoryId, this.onDownload});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final category = CatalogRegistry.categoryById(categoryId);
    final catalogs = CatalogRegistry.catalogsForCategory(categoryId);
    if (category == null) {
      return Scaffold(appBar: AppBar(title: Text(l10n.catalog)), body: Center(child: Text(l10n.noResults)));
    }

    return Scaffold(
      appBar: AppBar(title: Text(CatalogUiLocalization.categoryName(context, category.id))),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1100 ? 4 : constraints.maxWidth >= 700 ? 3 : constraints.maxWidth >= 520 ? 2 : 1;
          return CustomScrollView(slivers: [
            SliverPadding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), sliver: SliverToBoxAdapter(child: _CategoryHeader(category: category, count: catalogs.length))),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) => _CatalogTile(catalog: catalogs[index], onDownload: onDownload), childCount: catalogs.length),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: columns == 1 ? 2.0 : 1.15),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final CatalogCategoryDefinition category;
  final int count;
  const _CategoryHeader({required this.category, required this.count});
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [colors.primaryContainer, colors.secondaryContainer]), borderRadius: BorderRadius.circular(26)),
      child: Row(children: [
        CircleAvatar(radius: 30, backgroundColor: colors.surface.withValues(alpha: 0.7), child: Icon(_icon(category.id), color: colors.primary, size: 30)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(CatalogUiLocalization.categoryName(context, category.id), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text(CatalogUiLocalization.categoryName(context, category.id)),
          const SizedBox(height: 8),
          Text('$count', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: colors.primary, fontWeight: FontWeight.w800)),
        ])),
      ]),
    );
  }
  IconData _icon(String id) {
    switch (id) {
      case 'constructors': return Icons.extension_rounded;
      case 'numismatics': return Icons.monetization_on_outlined;
      case 'banknotes': return Icons.payments_outlined;
      case 'cards': return Icons.style_outlined;
      case 'video_games': return Icons.sports_esports_outlined;
      case 'consoles': return Icons.gamepad_outlined;
      case 'movies': return Icons.movie_outlined;
      case 'figurines': return Icons.toys_outlined;
      case 'books': return Icons.menu_book_outlined;
      case 'music': return Icons.album_outlined;
      case 'sports': return Icons.emoji_events_outlined;
      case 'art': return Icons.palette_outlined;
      default: return Icons.category_outlined;
    }
  }
}

class _CatalogTile extends StatelessWidget {
  final CatalogDefinition catalog;
  final Future<void> Function(CatalogDefinition catalog)? onDownload;
  const _CatalogTile({required this.catalog, this.onDownload});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CatalogOnlinePage(catalog: catalog, onDownload: onDownload == null ? null : () => onDownload!(catalog)))),
        child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [
          Container(width: 58, height: 58, decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(18)), child: Icon(Icons.inventory_2_outlined, color: colors.primary, size: 30)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(CatalogUiLocalization.catalogName(context, catalog.id), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text(CatalogUiLocalization.catalogDescription(context, catalog.id), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text('${l10n.primaryAttribute}: ${catalog.primaryField}', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colors.primary, fontWeight: FontWeight.w700)),
          ])),
          const Icon(Icons.chevron_right_rounded),
        ])),
      ),
    );
  }
}
