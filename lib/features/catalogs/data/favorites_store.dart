import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStore {
  FavoritesStore._();

  static const key = 'catalog.favoriteIds';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);
  static Future<void> _writeQueue = Future<void>.value();
  static Set<String>? _cachedIds;

  static String catalogKey(String id) => 'catalog:$id';
  static String sectionKey(String id) => 'section:$id';
  static String itemKey(String id) => 'item:$id';

  static Future<T> _enqueue<T>(Future<T> Function() operation) {
    final result = _writeQueue.then((_) => operation());
    _writeQueue = result.then<void>((_) {}, onError: (_, __) {});
    return result;
  }

  static Set<String> _expandCatalogAliases(Iterable<String> ids) {
    final result = <String>{};
    for (final id in ids) {
      if (id.contains(':')) {
        result.add(id);
        if (id.startsWith('catalog:')) {
          result.add(id.substring('catalog:'.length));
        }
      } else {
        result.add(id);
        result.add(catalogKey(id));
      }
    }
    return result;
  }

  static Set<String> _canonical(Iterable<String> ids) => ids
      .map((id) => id.contains(':') ? id : catalogKey(id))
      .toSet();

  static Future<Set<String>> load() async {
    if (_cachedIds != null) return Set<String>.from(_cachedIds!);
    final preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    final raw = preferences.getStringList(key)?.toSet() ?? <String>{};
    _cachedIds = _expandCatalogAliases(raw);
    return Set<String>.from(_cachedIds!);
  }

  static Future<Set<String>> loadKeys() => load();

  static Future<bool> contains(String catalogId) =>
      containsKey(catalogKey(catalogId));

  static Future<bool> containsKey(String favoriteKey) async =>
      (await load()).contains(favoriteKey);

  static Future<Set<String>> toggle(String catalogId) =>
      toggleKey(catalogKey(catalogId));

  static Future<Set<String>> toggleKey(String favoriteKey) => _enqueue(() async {
        final preferences = await SharedPreferences.getInstance();
        await preferences.reload();
        final stored = preferences.getStringList(key)?.toSet() ?? <String>{};
        final normalized = _canonical(stored);
        if (favoriteKey.startsWith('catalog:')) {
          if (!normalized.add(favoriteKey)) normalized.remove(favoriteKey);
        } else {
          final canonical = catalogKey(favoriteKey);
          if (!normalized.add(canonical)) normalized.remove(canonical);
        }
        await _save(preferences, normalized);
        return Set<String>.from(_cachedIds!);
      });

  static Future<void> remove(String catalogId) => removeKey(catalogKey(catalogId));

  static Future<void> removeKey(String favoriteKey) => _enqueue(() async {
        final preferences = await SharedPreferences.getInstance();
        await preferences.reload();
        final stored = preferences.getStringList(key)?.toSet() ?? <String>{};
        final normalized = _canonical(stored);
        final canonical = favoriteKey.contains(':')
            ? favoriteKey
            : catalogKey(favoriteKey);
        normalized.remove(canonical);
        await _save(preferences, normalized);
      });

  static Future<void> replaceAll(Set<String> ids) => _enqueue(() async {
        final preferences = await SharedPreferences.getInstance();
        await _save(preferences, _canonical(ids));
      });

  static Future<void> _save(
    SharedPreferences preferences,
    Set<String> ids,
  ) async {
    final canonical = _canonical(ids);
    final saved = await preferences.setStringList(
      key,
      canonical.toList()..sort(),
    );
    if (!saved) throw StateError('Не удалось сохранить избранное');

    _cachedIds = _expandCatalogAliases(canonical);
    revision.value++;
  }
}
