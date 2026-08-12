import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../templates/data/catalog_template_registry.dart';
import '../../../templates/domain/entities/template.dart';
import '../../../templates/presentation/pages/catalog_templates_page.dart';
import '../../domain/entities/collection.dart';
import '../providers/collection_provider.dart';
import '../providers/collection_service_provider.dart';
import 'collection_detail_page.dart';
import 'edit_collection_page.dart';

/// Главный экран управления коллекциями.
class CollectionsPage extends ConsumerStatefulWidget {
  const CollectionsPage({super.key});

  @override
  ConsumerState<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends ConsumerState<CollectionsPage> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(collectionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои коллекции'),
        actions: [
          IconButton(
            tooltip: 'Шаблоны каталогов',
            icon: const Icon(Icons.auto_awesome),
            onPressed: _openTemplates,
          ),
        ],
      ),
      body: collections.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Ошибка: $error')),
        data: (items) {
          final filtered = items.where((item) {
            return item.name.toLowerCase().contains(_search.toLowerCase());
          }).toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(collectionsProvider);
              await ref.read(collectionsProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Поиск коллекции',
                    border: const OutlineInputBorder(),
                    suffixIcon: _search.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _search = ''),
                          ),
                  ),
                  onChanged: (value) => setState(() => _search = value),
                ),
                const SizedBox(height: 16),
                if (filtered.isEmpty)
                  _EmptyCollectionsCard(
                    hasCollections: items.isNotEmpty,
                    onTemplate: _openTemplates,
                    onCreate: _createCollection,
                  )
                else
                  ...filtered.map(_buildCollectionTile),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createCollection,
        icon: const Icon(Icons.add),
        label: const Text('Новая коллекция'),
      ),
    );
  }

  Widget _buildCollectionTile(Collection collection) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: const CircleAvatar(child: Icon(Icons.collections_bookmark)),
        title: Text(collection.name),
        subtitle: Text(
          collection.templateId == null
              ? 'Пустая коллекция'
              : 'Шаблон: ${collection.templateId}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _collectionAction(collection, value),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'open', child: Text('Открыть')),
            PopupMenuItem(value: 'edit', child: Text('Изменить')),
            PopupMenuItem(value: 'delete', child: Text('Удалить')),
          ],
        ),
        onTap: () => _openCollection(collection),
      ),
    );
  }

  Future<void> _collectionAction(Collection collection, String value) async {
    if (value == 'open') {
      await _openCollection(collection);
    } else if (value == 'edit') {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => EditCollectionPage(collection: collection)),
      );
    } else if (value == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Удалить коллекцию?'),
          content: Text(collection.name),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Удалить'),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        await ref.read(collectionServiceProvider).deleteCollection(collection.id);
      }
    }

    if (!mounted) return;
    ref.invalidate(collectionsProvider);
  }

  Future<void> _openCollection(Collection collection) async {
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

  Future<void> _openTemplates() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CatalogTemplatesPage()),
    );
    if (!mounted) return;
    ref.invalidate(collectionsProvider);
  }

  Future<void> _createCollection() async {
    final result = await showDialog<_CreateCollectionResult>(
      context: context,
      builder: (_) => const _CreateCollectionDialog(),
    );

    if (!mounted || result == null || result.name.isEmpty) return;

    final collectionId = DateTime.now().microsecondsSinceEpoch.toString();
    final now = DateTime.now();
    final fields = result.template == null
        ? <dynamic>[]
        : result.template!.fields
            .map(
              (field) => field.copyWith(
                id: '${collectionId}_${field.id}',
                collectionId: collectionId,
              ),
            )
            .toList();

    final collection = Collection(
      id: collectionId,
      name: result.name,
      templateId: result.template?.id,
      fields: fields,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await ref.read(collectionServiceProvider).createCollection(collection);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось создать каталог: $error')),
      );
      return;
    }

    if (!mounted) return;
    ref.invalidate(collectionsProvider);
    await _openCollection(collection);
  }
}

class _CreateCollectionResult {
  final String name;
  final Template? template;

  const _CreateCollectionResult({required this.name, required this.template});
}

class _CreateCollectionDialog extends StatefulWidget {
  const _CreateCollectionDialog();

  @override
  State<_CreateCollectionDialog> createState() => _CreateCollectionDialogState();
}

class _CreateCollectionDialogState extends State<_CreateCollectionDialog> {
  final TextEditingController _controller = TextEditingController();
  Template? _template;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    Navigator.pop(
      context,
      _CreateCollectionResult(name: value, template: _template),
    );
  }

  @override
  Widget build(BuildContext context) {
    final templates = CatalogTemplateRegistry.all;

    return AlertDialog(
      title: const Text('Новая коллекция'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Название',
                hintText: 'Например: Мои монеты',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Template?>(
              initialValue: _template,
              decoration: const InputDecoration(
                labelText: 'Тип каталога',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<Template?>(
                  value: null,
                  child: Text('Пустая коллекция'),
                ),
                ...templates.map(
                  (template) => DropdownMenuItem<Template?>(
                    value: template,
                    child: Text(template.name),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _template = value),
            ),
            if (_template != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_template!.description}\nБудет создано полей: ${_template!.fields.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.add),
          label: const Text('Создать'),
        ),
      ],
    );
  }
}

class _EmptyCollectionsCard extends StatelessWidget {
  final bool hasCollections;
  final VoidCallback onTemplate;
  final VoidCallback onCreate;

  const _EmptyCollectionsCard({
    required this.hasCollections,
    required this.onTemplate,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.collections_bookmark_outlined, size: 52),
            const SizedBox(height: 12),
            Text(
              hasCollections ? 'Ничего не найдено' : 'Коллекций пока нет',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Создайте коллекцию и сразу выберите подходящий тип каталога.',
              textAlign: TextAlign.center,
            ),
            if (!hasCollections) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onTemplate,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Готовые шаблоны'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add),
                label: const Text('Создать каталог'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
