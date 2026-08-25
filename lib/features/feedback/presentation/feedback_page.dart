import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../catalogs/data/catalog_registry.dart';
import '../../catalogs/data/catalog_ui_localization.dart';

/// Форма обратной связи для предложений по централизованным каталогам.
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _detailsController = TextEditingController();
  String _type = 'Предложение';
  String? _catalogId;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    final catalogs = CatalogRegistry.all;
    if (catalogs.isNotEmpty) _catalogId = catalogs.first.id;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final catalog = CatalogRegistry.byId(_catalogId ?? '');
    if (catalog == null) return;
    setState(() => _sending = true);
    final locale = Localizations.localeOf(context);
    final catalogName = CatalogUiLocalization.catalogNameForLocale(locale, catalog.id);
    final title = Uri.encodeComponent('$_type: ${_subjectController.text.trim()}');
    final body = Uri.encodeComponent('Каталог: $catalogName\nCatalog ID: ${catalog.id}\nВерсия каталога: ${catalog.version}\nТип заявки: $_type\n\n${_detailsController.text.trim()}');
    final uri = Uri.parse('https://github.com/KeksPeks/collection_catalog/issues/new?title=$title&body=$body');
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Не удалось открыть форму отправки заявки.')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalogs = CatalogRegistry.all;
    final locale = Localizations.localeOf(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Обратная связь')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Каталоги централизованные. Пользователь не изменяет их структуру напрямую — здесь можно предложить добавить предмет, исправить данные или обновить каталог.', style: Theme.of(context).textTheme.bodyMedium))),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(initialValue: _type, decoration: const InputDecoration(labelText: 'Тип заявки', border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 'Добавить предмет', child: Text('Добавить предмет')), DropdownMenuItem(value: 'Добавить каталог', child: Text('Добавить каталог')), DropdownMenuItem(value: 'Исправить данные', child: Text('Исправить данные')), DropdownMenuItem(value: 'Предложение', child: Text('Предложение'))], onChanged: (value) { if (value != null) setState(() => _type = value); }),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(initialValue: _catalogId, decoration: const InputDecoration(labelText: 'Каталог', border: OutlineInputBorder()), items: [for (final catalog in catalogs) DropdownMenuItem(value: catalog.id, child: Text(CatalogUiLocalization.catalogNameForLocale(locale, catalog.id)))], onChanged: (value) => setState(() => _catalogId = value), validator: (value) => value == null ? 'Выберите каталог' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _subjectController, decoration: const InputDecoration(labelText: 'Название или идентификатор', hintText: 'Например: 10 рублей 2020, Россия', border: OutlineInputBorder()), validator: (value) => value == null || value.trim().isEmpty ? 'Укажите название или идентификатор' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _detailsController, minLines: 5, maxLines: 10, decoration: const InputDecoration(labelText: 'Описание предложения', hintText: 'Что необходимо добавить или исправить?', border: OutlineInputBorder(), alignLabelWithHint: true), validator: (value) => value == null || value.trim().isEmpty ? 'Опишите предложение' : null),
            const SizedBox(height: 20),
            FilledButton.icon(onPressed: _sending ? null : _send, icon: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send_outlined), label: const Text('Отправить предложение')),
          ],
        ),
      ),
    );
  }
}
