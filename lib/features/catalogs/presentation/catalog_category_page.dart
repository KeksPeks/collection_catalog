import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../data/catalog_registry.dart';
import '../data/catalog_ui_localization.dart';
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
      body: catalogs.isEmpty
          ? Center(child: Text(l10n.noResults))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: catalogs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final catalog = catalogs[index];
                return _CatalogRow(
                  catalog: catalog,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CatalogOnlinePage(
                        catalog: catalog,
                        onDownload: onDownload == null ? null : () => onDownload!(catalog),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _CatalogRow extends StatelessWidget {
  final CatalogDefinition catalog;
  final VoidCallback onTap;

  const _CatalogRow({required this.catalog, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final title = CatalogUiLocalization.catalogName(context, catalog.id);
    final count = catalog.totalItems ?? catalog.entries.length;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(16)),
                child: Icon(Icons.inventory_2_outlined, color: colors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(catalog.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text('$count записей', maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
