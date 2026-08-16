import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/collection_section.dart';
import '../providers/collection_section_provider.dart';
import '../../domain/entities/collection.dart';
import 'items_page.dart';

/// Иерархические разделы загруженного каталога.
///
/// Разделы каталога являются частью серверной структуры и доступны только
/// для просмотра. Изменять их пользователь не может.
class CollectionSectionsPage extends ConsumerWidget {
  final String collectionId;
  final String collectionName;
  final Collection collection;

  const CollectionSectionsPage({super.key, required this.collectionId, required this.collectionName, required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(collectionSectionsProvider(collectionId));
    return Scaffold(
      appBar: AppBar(title: Text(collectionName)),
      body: sections.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (items) {
          final roots = items.where((section) => section.parentId == null).toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          if (roots.isEmpty) return const Center(child: Text('Разделов пока нет'));
          return ListView(padding: const EdgeInsets.all(16), children: roots.map((section) => _buildSection(context, items, section, 0)).toList());
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, List<CollectionSection> all, CollectionSection section, int depth) {
    final children = all.where((item) => item.parentId == section.id).toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return Padding(
      padding: EdgeInsets.only(left: depth * 18.0, bottom: 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ListTile(
              leading: Icon(children.isEmpty ? Icons.folder_open_outlined : Icons.folder_outlined),
              title: Text(section.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ItemsPage(collection: collection, sectionId: section.id, sectionName: section.name))),
            ),
            if (children.isNotEmpty) ...children.map((child) => _buildSection(context, all, child, depth + 1)),
          ],
        ),
      ),
    );
  }
}
