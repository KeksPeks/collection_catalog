import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../collections/data/collection_history_store.dart';

/// Пользовательские статусы предмета. Структура каталога при этом не меняется.
enum CollectionItemStatus {
  missing,
  owned,
  wanted,
  ordered,
  trade,
  storage,
}

extension CollectionItemStatusX on CollectionItemStatus {
  String get value => name;

  String get title {
    switch (this) {
      case CollectionItemStatus.missing:
        return 'Нет';
      case CollectionItemStatus.owned:
        return 'Есть';
      case CollectionItemStatus.wanted:
        return 'Хочу купить';
      case CollectionItemStatus.ordered:
        return 'Заказан';
      case CollectionItemStatus.trade:
        return 'Обмен';
      case CollectionItemStatus.storage:
        return 'На хранении';
    }
  }

  static CollectionItemStatus fromValue(String? value) {
    return CollectionItemStatus.values.firstWhere(
      (item) => item.name == value,
      orElse: () => CollectionItemStatus.missing,
    );
  }
}

class ItemState {
  final CollectionItemStatus status;
  final int quantity;
  final String condition;
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final String note;
  final DateTime updatedAt;

  const ItemState({
    this.status = CollectionItemStatus.missing,
    this.quantity = 0,
    this.condition = '',
    this.purchaseDate,
    this.purchasePrice,
    this.note = '',
    required this.updatedAt,
  });

  ItemState copyWith({
    CollectionItemStatus? status,
    int? quantity,
    String? condition,
    DateTime? purchaseDate,
    bool clearPurchaseDate = false,
    double? purchasePrice,
    bool clearPurchasePrice = false,
    String? note,
    DateTime? updatedAt,
  }) {
    return ItemState(
      status: status ?? this.status,
      quantity: quantity ?? this.quantity,
      condition: condition ?? this.condition,
      purchaseDate: clearPurchaseDate ? null : (purchaseDate ?? this.purchaseDate),
      purchasePrice: clearPurchasePrice ? null : (purchasePrice ?? this.purchasePrice),
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'quantity': quantity,
        'condition': condition,
        'purchaseDate': purchaseDate?.toIso8601String(),
        'purchasePrice': purchasePrice,
        'note': note,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ItemState.fromJson(Map<String, dynamic> json) => ItemState(
        status: CollectionItemStatusX.fromValue(json['status'] as String?),
        quantity: (json['quantity'] as num?)?.toInt() ?? 0,
        condition: json['condition'] as String? ?? '',
        purchaseDate: DateTime.tryParse(json['purchaseDate'] as String? ?? ''),
        purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
        note: json['note'] as String? ?? '',
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      );
}

/// Локальное хранилище пользовательского состояния предметов.
///
/// Каталог остаётся централизованным и неизменяемым: здесь хранятся только
/// личные данные коллекционера. Формат JSON выбран специально, чтобы не
/// требовать миграции Drift при добавлении новых пользовательских атрибутов.
class ItemStateStore {
  ItemStateStore._();

  static const _key = 'collection.itemStates.v1';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static Future<Map<String, ItemState>> loadAll() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    final raw = preferences.getString(_key);
    if (raw == null || raw.isEmpty) return <String, ItemState>{};

    final decoded = jsonDecode(raw);
    if (decoded is! Map) return <String, ItemState>{};

    return decoded.map((key, value) {
      final map = value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
      return MapEntry(key.toString(), ItemState.fromJson(map));
    });
  }

  static Future<ItemState> load(String itemId) async {
    final states = await loadAll();
    return states[itemId] ?? ItemState(updatedAt: DateTime.now());
  }

  static Future<void> save(String itemId, ItemState state, {String? title}) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    final states = await loadAll();
    states[itemId] = state;
    final encoded = jsonEncode(states.map((key, value) => MapEntry(key, value.toJson())));
    final saved = await preferences.setString(_key, encoded);
    if (!saved) throw StateError('Не удалось сохранить состояние предмета');
    revision.value++;

    await CollectionHistoryStore.record(
      type: 'item_state',
      title: title ?? itemId,
      details: '${state.status.title}; ${state.quantity} шт.; ${state.condition}',
    );
  }
}
