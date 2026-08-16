import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Единое локальное хранилище избранных каталогов.
///
/// Избранное хранится в SharedPreferences и поэтому переживает перезапуск
/// приложения. Операции записи сериализуются, чтобы быстрые повторные нажатия
/// не перетирали друг друга.
class FavoritesStore {
  FavoritesStore._();

  static const key = 'catalog.favoriteIds';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);
  static Future<void> _writeQueue = Future<void>.value();

  static Future<T> _enqueue<T>(Future<T> Function() operation) {
    final result = _writeQueue.then((_) => operation());
    _writeQueue = result.then<void>((_) {}, onError: (_, __) {});
    return result;
  }

  static Future<Set<String>> load() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    return preferences.getStringList(key)?.toSet() ?? <String>{};
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

      await preferences.setStringList(key, ids.toList()..sort());
      revision.value++;
      return ids;
    });
  }

  static Future<void> remove(String catalogId) {
    return _enqueue(() async {
      final preferences = await SharedPreferences.getInstance();
      await preferences.reload();
      final ids = preferences.getStringList(key)?.toSet() ?? <String>{};
      if (!ids.remove(catalogId)) return;
      await preferences.setStringList(key, ids.toList()..sort());
      revision.value++;
    });
  }
}
