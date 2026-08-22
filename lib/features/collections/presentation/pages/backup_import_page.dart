import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../../catalogs/data/favorites_store.dart';
import '../../../items/data/item_state_store.dart';
import '../../data/collection_history_store.dart';

class BackupImportPage extends StatefulWidget {
  const BackupImportPage({super.key});
  @override
  State<BackupImportPage> createState() => _BackupImportPageState();
}

class _BackupImportPageState extends State<BackupImportPage> {
  bool _loading = false;
  String _message = 'Выберите JSON-резервную копию. Структура централизованного каталога не импортируется.';

  Future<void> _import() async {
    setState(() { _loading = true; _message = 'Чтение резервной копии...'; });
    try {
      const group = XTypeGroup(label: 'JSON', extensions: ['json'], mimeTypes: ['application/json']);
      final file = await openFile(acceptedTypeGroups: [group]);
      if (file == null) { if (mounted) setState(() { _loading = false; _message = 'Импорт отменён.'; }); return; }
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) throw const FormatException('Некорректный JSON backup');

      final rawStates = decoded['itemStates'];
      final states = <String, ItemState>{};
      if (rawStates is Map) {
        for (final entry in rawStates.entries) {
          if (entry.value is Map) states[entry.key.toString()] = ItemState.fromJson(Map<String, dynamic>.from(entry.value as Map));
        }
      }
      await ItemStateStore.replaceAll(states);

      final rawFavorites = decoded['favorites'];
      if (rawFavorites is List) await FavoritesStore.replaceAll(rawFavorites.map((value) => value.toString()).toSet());

      final rawHistory = decoded['history'];
      if (rawHistory is List) {
        final history = rawHistory.whereType<Map>().map((entry) => CollectionHistoryEntry.fromJson(Map<String, dynamic>.from(entry))).toList();
        await CollectionHistoryStore.replaceAll(history);
      }

      if (!mounted) return;
      setState(() { _loading = false; _message = 'Импорт завершён. Восстановлено состояний: ${states.length}. Каталог и его структуру приложение не изменяло.'; });
    } catch (error) {
      if (!mounted) return;
      setState(() { _loading = false; _message = 'Ошибка импорта: $error'; });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Восстановление')), body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560), child: Padding(padding: const EdgeInsets.all(24), child: Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.restore_outlined, size: 56), const SizedBox(height: 16), Text(_message, textAlign: TextAlign.center), const SizedBox(height: 20), FilledButton.icon(onPressed: _loading ? null : _import, icon: const Icon(Icons.file_open_outlined), label: const Text('Выбрать JSON'))]))))));
}
