import 'package:flutter/material.dart';

import '../../../feedback/presentation/feedback_page.dart';

/// Каталожные данные доступны пользователю только для просмотра.
class CatalogAdminPage extends StatelessWidget {
  const CatalogAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Каталоги')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_outline, size: 42, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 14),
                  Text('Каталоги доступны только для просмотра', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text('Структура, записи, разделы и справочные данные каталога управляются централизованно. Пользователь не может изменять исходные данные каталога.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.feedback_outlined),
              title: const Text('Предложить изменение'),
              subtitle: const Text('Сообщить о недостающей записи, файле, разделе или ошибке в данных'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FeedbackPage())),
            ),
          ),
        ],
      ),
    );
  }
}
