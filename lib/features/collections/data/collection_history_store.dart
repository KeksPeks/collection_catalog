import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CollectionHistoryEntry {
  final String type;
  final String title;
  final String details;
  final DateTime timestamp;
  const CollectionHistoryEntry({required this.type, required this.title, required this.details, required this.timestamp});
  Map<String, dynamic> toJson() => {'type': type, 'title': title, 'details': details, 'timestamp': timestamp.toIso8601String()};
  factory CollectionHistoryEntry.fromJson(Map<String, dynamic> json) => CollectionHistoryEntry(type: json['type'] as String? ?? 'change', title: json['title'] as String? ?? '', details: json['details'] as String? ?? '', timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now());
}

class CollectionHistoryStore {
  CollectionHistoryStore._();
  static const _key = 'collection.history.v1';
  static const _maxEntries = 500;
  static Future<List<CollectionHistoryEntry>> load() async { final preferences = await SharedPreferences.getInstance(); await preferences.reload(); final raw = preferences.getString(_key); if (raw == null || raw.isEmpty) return const []; final decoded = jsonDecode(raw); if (decoded is! List) return const []; return decoded.whereType<Map>().map((item) => CollectionHistoryEntry.fromJson(Map<String, dynamic>.from(item))).toList(growable: false); }
  static Future<void> record({required String type, required String title, required String details}) async { final entries = (await load()).toList(); entries.insert(0, CollectionHistoryEntry(type: type, title: title, details: details, timestamp: DateTime.now())); if (entries.length > _maxEntries) entries.removeRange(_maxEntries, entries.length); await replaceAll(entries); }
  static Future<void> replaceAll(List<CollectionHistoryEntry> entries) async { final preferences = await SharedPreferences.getInstance(); final limited = entries.length > _maxEntries ? entries.take(_maxEntries).toList() : entries; await preferences.setString(_key, jsonEncode(limited.map((item) => item.toJson()).toList())); }
  static Future<void> clear() async { final preferences = await SharedPreferences.getInstance(); await preferences.remove(_key); }
}
