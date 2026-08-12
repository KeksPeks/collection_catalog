import 'package:flutter/material.dart';

import '../domain/entities/catalog_definition.dart';

/// Онлайн-просмотр структуры готового каталога.
///
/// Страница не требует скачивания каталога. При подключении серверного
/// источника здесь будут отображаться реальные записи каталога.
class CatalogOnlinePage extends StatelessWidget {
  final CatalogDefinition catalog;
  final VoidCallback? onDownload;

  const CatalogOnlinePage({
    super.key,
    required this.catalog,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(catalog.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    catalog.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(catalog.description),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onDownload,
                    icon: const Icon(Icons.download),
                    label: const Text('Скачать каталог'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Структура каталога',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (catalog.sections.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Основные записи группируются по полям: ${catalog.template.fields.map((field) => field.label).join(', ')}.',
                ),
              ),
            )
          else
            ...catalog.sections.map(
              (section) => _SectionTile(section: section),
            ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Онлайн-просмотр не занимает место в памяти телефона. Скачивание создаёт локальную копию каталога.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  final CatalogSectionDefinition section;

  const _SectionTile({required this.section});

  @override
  Widget build(BuildContext context) {
    if (section.children.isEmpty) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.folder_outlined),
          title: Text(section.name),
        ),
      );
    }

    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.folder_outlined),
        title: Text(section.name),
        children: section.children
            .map(
              (child) => ListTile(
                contentPadding: const EdgeInsets.only(left: 56, right: 16),
                leading: const Icon(Icons.subdirectory_arrow_right),
                title: Text(child.name),
              ),
            )
            .toList(),
      ),
    );
  }
}
