import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../collections/presentation/pages/collection_tools_page.dart';
import '../../../collections/presentation/providers/collection_provider.dart';
import '../../domain/services/built_in_template_registry.dart';

/// Панель каталогов.
///
/// Обычный пользователь не может изменять структуру централизованного
/// каталога. Административная сборка может быть включена через
/// --dart-define=COLLECTION_ADMIN=true; здесь оставлен отдельный контур для
/// будущей публикации серверных изменений без смешивания их с личными данными.
class CatalogAdminPage extends ConsumerWidget {
  const CatalogAdminPage({super.key});

  static const bool adminBuild = bool.fromEnvironment('COLLECTION_ADMIN', defaultValue: false);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(collectionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Каталоги')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.insights_outlined),
              title: const Text('Инструменты коллекционера'),
              subtitle: const Text('Прогресс, статистика, поиск, история, резервные копии, экспорт, сканер и уведомления.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CollectionToolsPage())),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(adminBuild ? Icons.admin_panel_settings : Icons.lock_outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      adminBuild
                          ? 'Административная сборка активна. Пользовательские данные отделены от структуры каталогов; публикация каталога должна выполняться через централизованный источник.'
                          : 'Структура каталогов централизована. Пользователь может только скачать каталог, отмечать своё состояние и отправлять предложения через обратную связь.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text('Доступные каталоги', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...BuiltInTemplateRegistry.templates.map(
            (template) => Card(
              child: ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(template.name),
                subtitle: Text(template.description),
                trailing: const Icon(Icons.lock_outline),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text('Загруженные каталоги', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          collections.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text(error.toString()),
            data: (items) => items.isEmpty
                ? const Card(child: ListTile(title: Text('Загруженных каталогов пока нет')))
                : Column(
                    children: items
                        .map(
                          (collection) => Card(
                            child: ListTile(
                              leading: const Icon(Icons.collections_bookmark_outlined),
                              title: Text(collection.name),
                              subtitle: Text(collection.templateId ?? 'Каталог'),
                              trailing: const Icon(Icons.lock_outline),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
