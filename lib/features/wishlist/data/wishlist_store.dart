import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Локальный Wishlist. Сервер для хранения списка желаний не требуется.
class WishlistStore {
  WishlistStore._();

  static const _key = 'collection.wishlist.v1';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static Future<Set<String>> loadIds() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    final raw = preferences.getString(_key);
    if (raw == null || raw.isEmpty) return <String>{};
    final decoded = jsonDecode(raw);
    if (decoded is! List) return <String>{};
    return decoded.map((value) => value.toString()).toSet();
  }

  static Future<void> replaceAll(Set<String> ids) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(_key, jsonEncode(ids.toList()));
    if (!saved) throw StateError('Не удалось сохранить список желаний');
    revision.value++;
  }

  static Future<void> addAll(Iterable<String> ids) async {
    final current = await loadIds();
    current.addAll(ids);
    await replaceAll(current);
  }

  static Future<void> add(String id) => addAll([id]);

  static Future<void> remove(String id) async {
    final current = await loadIds();
    if (!current.remove(id)) return;
    await replaceAll(current);
  }

  static Future<void> removeAll(Iterable<String> ids) async {
    final current = await loadIds();
    current.removeAll(ids.toSet());
    await replaceAll(current);
  }
}
