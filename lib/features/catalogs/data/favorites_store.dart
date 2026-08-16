import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Единое локальное хранилище избранных каталогов.
///
/// Избранное хранится в SharedPreferences и переживает перезапуск приложения.
/// Перед каждой операцией записи хранилище перечитывается, поэтому кэш не
/// может затереть состояние, сохранённое другим экраном приложения.
class FavoritesStore {
  FavoritesStore._();

  static const key = 'catalog.favoriteIds';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);
  static Future<void> _writeQueue = Future<void>.value();
  static Set<String>? _cachedIds;

  static Future<T> _enqueue<T>(Future<T> Function() operation) {
    final result = _writeQueue.then((_) => operation());
    _writeQueue = result.then<void>((_) {}, onError: (_, __) {});
    return result;
  }

  static Future<Set<String>> load() async {
    if (_cachedIds != null) {
      return Set<String>.from(_cachedIds!);
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    _cachedIds = preferences.getStringList(key)?.toSet() ?? <String>{};
    return Set<String>.from(_cachedIds!);
  }

  static Future<bool> contains(String catalogId) async {
    final ids = await load();
    return ids.contains(catalogId);
  }

  static Future<Set<String>> toggle(String catalogId) {
    return _enqueue(() async {
      final preferences = await SharedPreferences.getInstance();
      await preferences.reload();

      final ids = preferences.getStringList(key)?.toSet() ?? <String>{};
      if (!ids.add(catalogId)) {
        ids.remove(catalogId);
      }

      final sorted = ids.toList()..sort();
      final saved = await preferences.setStringList(key, sorted);
      if (!saved) {
        throw StateError('Не удалось сохранить избранное');
      }

      _cachedIds = ids;
      revision.value++;
      return Set<String>.from(ids);
    });
  }

  static Future<void> remove(String catalogId) {
    return _enqueue(() async {
      final preferences = await SharedPreferences.getInstance();
      await preferences.reload();

      final ids = preferences.getStringList(key)?.toSet() ?? <String>{};
      if (!ids.remove(catalogId)) {
        _cachedIds = ids;
        return;
      }

      final sorted = ids.toList()..sort();
      final saved = await preferences.setStringList(key, sorted);
      if (!saved) {
        throw StateError('Не удалось сохранить избранное');
      }

      _cachedIds = ids;
      revision.value++;
    });
  }
}
