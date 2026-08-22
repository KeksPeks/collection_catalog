import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/settings/ui_layout_settings.dart';
import '../data/catalog_registry.dart';
import '../data/catalog_ui_localization.dart';
import '../domain/entities/catalog_category_definition.dart';
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
    final l10n = AppLocalizations.of(context);
    final category = CatalogRegistry.categoryById(widget.categoryId);
    final catalogs = CatalogRegistry.catalogsForCategory(widget.categoryId);
    if (category == null) {
      return Scaffold(appBar: AppBar(title: Text(l10n.catalog)), body: Center(child: Text(l10n.noResults)));
    }

    return Scaffold(
      appBar: AppBar(title: Text(CatalogUiLocalization.categoryName(context, category.id))),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = UiLayoutSettings.resolveColumns(constraints.maxWidth);
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: catalogs.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: UiLayoutSettings.cardHeight,
            ),
            itemBuilder: (context, index) => _CatalogTile(
              catalog: catalogs[index],
              onDownload: widget.onDownload,
            ),
          );
        },
      ),
    );
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
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CatalogOnlinePage(
              catalog: catalog,
              onDownload: onDownload == null ? null : () => onDownload!(catalog),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(18)),
                child: Icon(Icons.inventory_2_outlined, color: colors.primary, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(CatalogUiLocalization.catalogName(context, catalog.id), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 5),
                    Text(CatalogUiLocalization.catalogDescription(context, catalog.id), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text('${l10n.primaryAttribute}: ${catalog.primaryField}', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colors.primary, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
