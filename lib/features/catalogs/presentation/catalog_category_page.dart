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
        final cardHeight = UiLayoutSettings.resolveCardHeight(width: constraints.maxWidth, columns: columns, textScale: textScale);
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          itemCount: catalogs.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 12, mainAxisSpacing: 12, mainAxisExtent: cardHeight),
          itemBuilder: (context, index) => _CatalogTile(catalog: catalogs[index], columns: columns, onDownload: widget.onDownload),
        );
      }),
    );
  }
}

class _CatalogTile extends StatelessWidget {
  final CatalogDefinition catalog;
  final int columns;
  final Future<void> Function(CatalogDefinition catalog)? onDownload;

  const _CatalogTile({required this.catalog, required this.columns, this.onDownload});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final title = CatalogUiLocalization.catalogName(context, catalog.id);
    return LayoutBuilder(builder: (context, constraints) {
      final compactGrid = columns > 1;
      final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800);
      final painter = TextPainter(text: TextSpan(text: title, style: titleStyle), maxLines: 1, textDirection: Directionality.of(context))..layout(maxWidth: double.infinity);
      final showText = !compactGrid || painter.width <= constraints.maxWidth - 24;
      return Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CatalogOnlinePage(catalog: catalog, onDownload: onDownload == null ? null : () => onDownload!(catalog)))),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: showText
                  ? Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(width: 52, height: 52, decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(16)), child: Icon(Icons.inventory_2_outlined, color: colors.primary, size: 28)),
                      const SizedBox(height: 8),
                      Text(title, maxLines: compactGrid ? 2 : 3, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: titleStyle),
                    ])
                  : Container(width: 52, height: 52, decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(16)), child: Icon(Icons.inventory_2_outlined, color: colors.primary, size: 28)),
            ),
          ),
        ),
      );
    });
  }
}
