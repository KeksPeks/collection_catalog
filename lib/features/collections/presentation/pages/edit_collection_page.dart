import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/collection.dart';
import '../providers/collection_provider.dart';
import '../providers/collection_service_provider.dart';

/// Редактирование основных свойств коллекции.
class EditCollectionPage extends ConsumerStatefulWidget {
  final Collection collection;

  const EditCollectionPage({
    super.key,
    required this.collection,
  });

  @override
  ConsumerState<EditCollectionPage> createState() => _EditCollectionPageState();
}

class _EditCollectionPageState extends ConsumerState<EditCollectionPage> {
  late final TextEditingController controller;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.collection.name);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать коллекцию')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Основные данные', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Название коллекции',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.collections_bookmark_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: saving ? null : _save,
                      icon: saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(saving ? 'Сохранение...' : 'Сохранить'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Структура коллекции'),
              subtitle: Text(
                widget.collection.templateId == null
                    ? 'Пользовательская структура. Поля можно изменить на странице коллекции.'
                    : 'Создана из шаблона «${widget.collection.templateId}». Поля можно изменить независимо от шаблона.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final name = controller.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название коллекции')),
      );
      return;
    }

    setState(() => saving = true);

    try {
      final updated = widget.collection.copyWith(
        name: name,
        updatedAt: DateTime.now(),
      );

      await ref.read(collectionServiceProvider).updateCollection(updated);
      ref.invalidate(collectionsProvider);
      ref.invalidate(collectionProvider(widget.collection.id));

      if (!mounted) return;
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      setState(() => saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось сохранить: $error')),
      );
    }
  }
}
