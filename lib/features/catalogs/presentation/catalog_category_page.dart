import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/settings/ui_layout_settings.dart';
import '../data/catalog_registry.dart';
import '../data/catalog_ui_localization.dart';
import '../domain/entities/catalog_definition.dart';
import 'catalog_online_page.dart';

class CatalogCategoryPage extends StatefulWidget {
  final String categoryId;
  final Future<void> Function(CatalogDefinition catalog)? onDownload;

  const CatalogCategoryPage({super.key, required this.categoryId, this.onDownload});

  @override
  State<CatalogCategoryPage> createState() => _CatalogCategoryPageState();
}

class _CatalogCategoryPageState extends State<CatalogCategoryPage> {
  VoidCallback? _layoutListener;

  @override
  void initState() {
    super.initState();
    _layoutListener = () { if (mounted) setState(() {}); };
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
    final l10n = AppLocalizations.of(context);
    final category = CatalogRegistry.categoryById(widget.categoryId);
    final catalogs = CatalogRegistry.catalogsForCategory(widget.categoryId);
    if (category == null) return Scaffold(appBar: AppBar(title: Text(l10n.catalog)), body: Center(child: Text(l10n.noResults)));

    return Scaffold(
      appBar: AppBar(title: Text(CatalogUiLocalization.categoryName(context, category.id))),
      body: LayoutBuilder(builder: (context, constraints) {
        final columns = UiLayoutSettings.resolveColumns(constraints.maxWidth);
        final textScale = MediaQuery.textScalerOf(context).scale(1.0);
        final columnWidth = (constraints.maxWidth - (columns - 1) * 12) / columns;
        final canShowTitles = columns == 1 || catalogs.every((catalog) {
          final title = CatalogUiLocalization.catalogName(context, catalog.id);
          final style = Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800);
          final painter = TextPainter(text: TextSpan(text: title, style: style), maxLines: 2, textDirection: Directionality.of(context))..layout(maxWidth: columnWidth - 28);
          return painter.didExceedMaxLines == false;
        });
        final cardHeight = canShowTitles ? (118 * textScale).clamp(104.0, 170.0) : 82.0;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          itemCount: catalogs.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 12, mainAxisSpacing: 12, mainAxisExtent: cardHeight),
          itemBuilder: (context, index) => _CatalogTile(catalog: catalogs[index], columns: columns, showTitle: canShowTitles, onDownload: widget.onDownload),
        );
      }),
    );
  }
}

class _CatalogTile extends StatelessWidget {
  final CatalogDefinition catalog;
  final int columns;
  final bool showTitle;
  final Future<void> Function(CatalogDefinition catalog)? onDownload;

  const _CatalogTile({required this.catalog, required this.columns, required this.showTitle, this.onDownload});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final title = CatalogUiLocalization.catalogName(context, catalog.id);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CatalogOnlinePage(catalog: catalog, onDownload: onDownload == null ? null : () => onDownload!(catalog)))),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 48, height: 48, decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(15)), child: Icon(Icons.inventory_2_outlined, color: colors.primary, size: 27)),
                if (showTitle) ...[
                  const SizedBox(height: 6),
                  Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
