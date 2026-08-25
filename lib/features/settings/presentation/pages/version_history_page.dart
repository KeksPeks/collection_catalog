import 'package:flutter/material.dart';

/// История версий приложения, сформированная по реально зафиксированным изменениям проекта.
class VersionHistoryPage extends StatelessWidget {
  const VersionHistoryPage({super.key});

  static const _versions = <_VersionEntry>[
    _VersionEntry(
      version: '1.1.0+2',
      title: 'Текущая версия',
      date: '25.08.2026',
      changes: [
        'Обновлён интерфейс каталога: записи отображаются карточками.',
        'Добавлена поддержка изображений карточек.',
        'При отсутствии изображения показывается NO IMAGES.',
        'Для записей стран отображаются флаги.',
        'Добавлены локальные достижения, XP и уровни коллекционера.',
        'Обзор объединяет статистику коллекций, предметов и достижения.',
        'Настройки интерфейса, версии каталогов и резервное копирование доступны из обычных настроек.',
      ],
    ),
    _VersionEntry(
      version: '1.1.0',
      title: 'Основное обновление каталога',
      date: '24.08.2026',
      changes: [
        'Добавлены локальные каталоги и версии каталогов.',
        'Добавлены избранные каталоги и разделы.',
        'Добавлены резервное копирование и восстановление.',
        'Добавлены инструменты работы с коллекциями.',
        'Добавлены настройки внешнего вида и навигации.',
        'Добавлена локальная система достижений.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Версии приложения')),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: _versions.length,
        itemBuilder: (context, index) {
          final entry = _versions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              initiallyExpanded: index == 0,
              leading: const Icon(Icons.new_releases_outlined),
              title: Text(entry.version, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text('${entry.title} · ${entry.date}'),
              childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              children: [
                for (final change in entry.changes)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Padding(padding: EdgeInsets.only(top: 6), child: Icon(Icons.circle, size: 6)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(change)),
                    ]),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _VersionEntry {
  final String version;
  final String title;
  final String date;
  final List<String> changes;

  const _VersionEntry({required this.version, required this.title, required this.date, required this.changes});
}
