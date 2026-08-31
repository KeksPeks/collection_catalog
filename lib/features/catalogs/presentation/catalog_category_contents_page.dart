import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../data/catalog_ui_localization.dart';
import '../domain/entities/catalog_definition.dart';
import '../domain/entities/catalog_entry_definition.dart';
import '../domain/entities/catalog_section_definition.dart';
import 'catalog_online_page.dart';

/// Верхний уровень выбранного каталога без лишнего промежуточного раздела.
/// Для нумизматики технический раздел «Страны» раскрывается сразу.
class CatalogCategoryContentsPage extends StatelessWidget {
  final String categoryId;
  final CatalogDefinition catalog;
  final Future<void> Function()? onDownload;

  const CatalogCategoryContentsPage({super.key, required this.categoryId, required this.catalog, this.onDownload});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = CatalogUiLocalization.categoryName(context, categoryId);
    if (catalog.sections.isEmpty) return CatalogOnlinePage(catalog: catalog, onDownload: onDownload);

    final flattened = _flattenTopLevelSections();
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: flattened.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = flattened[index];
          final section = item.section;
          final path = item.path;
          final count = _countEntries(catalog.entries, path);
          final description = section.children.isEmpty ? '$count ${_recordWord(count)}' : '${section.children.length} ${_subdivisionWord(section.children.length)}';
          return Card(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.zero,
            child: InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CatalogOnlinePage(catalog: catalog, onDownload: onDownload, sectionPath: path))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(children: [
                  _sectionIcon(section.name),
                  const SizedBox(width: 14),
                  Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(section.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(description, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ])),
                  const Icon(Icons.chevron_right_rounded),
                ]),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: onDownload == null ? null : SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: FilledButton.icon(onPressed: () async { await onDownload!.call(); if (context.mounted) Navigator.of(context).pop(); }, icon: const Icon(Icons.download_rounded), label: Text(l10n.download)))),
    );
  }

  List<_SectionPath> _flattenTopLevelSections() {
    if (catalog.id != 'coins' || catalog.sections.length != 1) return [for (final section in catalog.sections) _SectionPath(section, [section.id])];
    final root = catalog.sections.first;
    final rootName = root.name.toLowerCase();
    final isCountries = rootName.contains('стран') || rootName.contains('countr');
    if (!isCountries || root.children.isEmpty) return [for (final section in catalog.sections) _SectionPath(section, [section.id])];
    return [for (final country in root.children) _SectionPath(country, [root.id, country.id])];
  }

  static int _countEntries(List<CatalogEntryDefinition> entries, List<String> path) => entries.where((entry) {
    if (entry.sectionPath.length < path.length) return false;
    for (var i = 0; i < path.length; i++) {
      if (entry.sectionPath[i] != path[i]) return false;
    }
    return true;
  }).length;

  static Widget _sectionIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('росси') || lower.contains('герм') || lower.contains('фран') || lower.contains('итал') || lower.contains('испан')) return const SizedBox(width: 54, height: 54, child: Center(child: Icon(Icons.flag_outlined, size: 34)));
    if (lower.contains('год')) return const SizedBox(width: 54, height: 54, child: Center(child: Icon(Icons.calendar_month_outlined, size: 34)));
    if (lower.contains('сер')) return const SizedBox(width: 54, height: 54, child: Center(child: Icon(Icons.collections_bookmark_outlined, size: 34)));
    return const SizedBox(width: 54, height: 54, child: Center(child: Icon(Icons.folder_outlined, size: 34)));
  }

  static String _recordWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'запись';
    if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) return 'записи';
    return 'записей';
  }

  static String _subdivisionWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'подраздел';
    if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) return 'подраздела';
    return 'подразделов';
  }
}

class _SectionPath {
  final CatalogSectionDefinition section;
  final List<String> path;
  const _SectionPath(this.section, this.path);
}
