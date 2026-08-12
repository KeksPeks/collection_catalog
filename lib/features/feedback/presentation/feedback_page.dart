import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Форма обратной связи для заявок пользователей.
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _detailsController = TextEditingController();
  String _type = 'Добавить файл';
  String _catalog = 'Монеты';
  bool _sending = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _sending = true);
    final subject = Uri.encodeComponent(
      'Collection Catalog: $_type — ${_subjectController.text.trim()}',
    );
    final body = Uri.encodeComponent(
      'Каталог: $_catalog\n'
      'Тип заявки: $_type\n\n'
      '${_detailsController.text.trim()}',
    );
    final uri = Uri.parse(
      'mailto:catalog@collection-catalog.example?subject=$subject&body=$body',
    );

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('На устройстве не найдено почтовое приложение.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Обратная связь')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Сообщите о недостающем файле, ошибке в каталоге или предложите изменение. Заявка откроется в почтовом приложении.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'Тип заявки',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Добавить файл',
                  child: Text('Добавить файл'),
                ),
                DropdownMenuItem(
                  value: 'Изменить файл',
                  child: Text('Изменить файл'),
                ),
                DropdownMenuItem(
                  value: 'Исправить данные',
                  child: Text('Исправить данные'),
                ),
                DropdownMenuItem(
                  value: 'Предложение',
                  child: Text('Предложение'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _type = value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _catalog,
              decoration: const InputDecoration(
                labelText: 'Каталог',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Монеты', child: Text('Монеты')),
                DropdownMenuItem(value: 'Банкноты', child: Text('Банкноты')),
                DropdownMenuItem(value: 'Pokémon TCG', child: Text('Pokémon TCG')),
                DropdownMenuItem(value: 'Диски', child: Text('Диски')),
                DropdownMenuItem(value: 'Игры', child: Text('Игры')),
                DropdownMenuItem(value: 'Фильмы', child: Text('Фильмы')),
                DropdownMenuItem(value: 'Фигурки', child: Text('Фигурки')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _catalog = value);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Название или идентификатор файла',
                hintText: 'Например: 2 евро 2004, Германия',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Укажите название или идентификатор'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _detailsController,
              minLines: 5,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Описание заявки',
                hintText: 'Что необходимо добавить или исправить?',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Опишите заявку'
                  : null,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _sending ? null : _send,
              icon: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_outlined),
              label: const Text('Отправить заявку'),
            ),
          ],
        ),
      ),
    );
  }
}
