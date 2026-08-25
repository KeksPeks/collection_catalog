import 'package:flutter/material.dart';

class VersionHistoryPage extends StatelessWidget {
  const VersionHistoryPage({super.key});

  String _text(BuildContext context, String ru, String en) => Localizations.localeOf(context).languageCode == 'ru' ? ru : en;

  @override
  Widget build(BuildContext context) {
    final versions = <_VersionEntry>[
      _VersionEntry('Current develop', '2026-08-25', _text(context, 'Исправления интерфейса, синхронизация настроек, загрузки каталогов, SQLite, обзор и локальная геймификация.', 'Interface fixes, settings synchronization, catalog downloads, SQLite, overview and local gamification.')),
      _VersionEntry('2026.08', '2026-08-25', _text(context, 'Добавлены локальные достижения, XP и статистика коллекций.', 'Added local achievements, XP and collection statistics.')),
      _VersionEntry('2026.07', '2026-08-24', _text(context, 'Расширены каталоги, состояния предметов, избранное и инструменты коллекционера.', 'Expanded catalogs, item states, favorites and collector tools.')),
      _VersionEntry('2026.06', '2026-08-22', _text(context, 'Обновлена структура каталогов и подготовлена работа с большими наборами данных.', 'Updated catalog structure and prepared support for large datasets.')),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(_text(context, 'История версий', 'Version history'))),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: versions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, index) {
          final version = versions[index];
          return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(version.version, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))), Text(version.date, style: Theme.of(context).textTheme.bodySmall)]), const SizedBox(height: 8), Text(version.description)])));
        },
      ),
    );
  }
}

class _VersionEntry {
  final String version;
  final String date;
  final String description;
  const _VersionEntry(this.version, this.date, this.description);
}
