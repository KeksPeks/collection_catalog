import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Единое локальное хранилище избранных каталогов.
///
/// SharedPreferences отвечает за постоянное хранение, а notifier мгновенно
/// сообщает открытым экранам об изменении избранного.
class FavoritesStore {
  FavoritesStore._();

  static const key = 'catalog.favoriteIds';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static Future<Set<String>> load() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(key)?.toSet() ?? <String>{};
  }

  static Future<bool> contains(String catalogId) async {
    final ids = await load();
    return ids.contains(catalogId);
  }

  static Future<Set<String>> toggle(String catalogId) async {
    final preferences = await SharedPreferences.getInstance();
    final ids = preferences.getStringList(key)?.toSet() ?? <String>{};

    if (!ids.add(catalogId)) {
      ids.remove(catalogId);
    }

    await preferences.setStringList(key, ids.toList()..sort());
    revision.value++;
    return ids;
  }

  static Future<void> remove(String catalogId) async {
    final preferences = await SharedPreferences.getInstance();
    final ids = preferences.getStringList(key)?.toSet() ?? <String>{};
    if (!ids.remove(catalogId)) return;
    await preferences.setStringList(key, ids.toList()..sort());
    revision.value++;
  }
}
