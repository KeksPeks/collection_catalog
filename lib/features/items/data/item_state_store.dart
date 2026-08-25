import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../collections/data/collection_history_store.dart';

enum CollectionItemStatus {
  missing,
  wanted,
  ordered,
  inTransit,
  owned,
  duplicate,
  trade,
  forSale,
  sold,
  gifted,
  lost,
  repair,
  storage,
}

extension CollectionItemStatusX on CollectionItemStatus {
  String get value => name;
  String get title => localizedTitle('ru');

  String localizedTitle(String languageCode) {
    const titles = <String, Map<CollectionItemStatus, String>>{
      'ru': {
        CollectionItemStatus.missing: 'Не найден',
        CollectionItemStatus.wanted: 'Нужен',
        CollectionItemStatus.ordered: 'Заказан',
        CollectionItemStatus.inTransit: 'В пути',
        CollectionItemStatus.owned: 'Есть',
        CollectionItemStatus.duplicate: 'Дубликат',
        CollectionItemStatus.trade: 'На обмен',
        CollectionItemStatus.forSale: 'На продажу',
        CollectionItemStatus.sold: 'Продан',
        CollectionItemStatus.gifted: 'Подарен',
        CollectionItemStatus.lost: 'Потерян',
        CollectionItemStatus.repair: 'В ремонте',
        CollectionItemStatus.storage: 'На хранении',
      },
      'en': {
        CollectionItemStatus.missing: 'Not found',
        CollectionItemStatus.wanted: 'Needed',
        CollectionItemStatus.ordered: 'Ordered',
        CollectionItemStatus.inTransit: 'In transit',
        CollectionItemStatus.owned: 'Owned',
        CollectionItemStatus.duplicate: 'Duplicate',
        CollectionItemStatus.trade: 'For trade',
        CollectionItemStatus.forSale: 'For sale',
        CollectionItemStatus.sold: 'Sold',
        CollectionItemStatus.gifted: 'Gifted',
        CollectionItemStatus.lost: 'Lost',
        CollectionItemStatus.repair: 'In repair',
        CollectionItemStatus.storage: 'In storage',
      },
      'de': {
        CollectionItemStatus.missing: 'Nicht gefunden',
        CollectionItemStatus.wanted: 'Gesucht',
        CollectionItemStatus.ordered: 'Bestellt',
        CollectionItemStatus.inTransit: 'Unterwegs',
        CollectionItemStatus.owned: 'Vorhanden',
        CollectionItemStatus.duplicate: 'Duplikat',
        CollectionItemStatus.trade: 'Zum Tausch',
        CollectionItemStatus.forSale: 'Zum Verkauf',
        CollectionItemStatus.sold: 'Verkauft',
        CollectionItemStatus.gifted: 'Verschenkt',
        CollectionItemStatus.lost: 'Verloren',
        CollectionItemStatus.repair: 'In Reparatur',
        CollectionItemStatus.storage: 'Eingelagert',
      },
      'fr': {
        CollectionItemStatus.missing: 'Introuvable',
        CollectionItemStatus.wanted: 'Recherché',
        CollectionItemStatus.ordered: 'Commandé',
        CollectionItemStatus.inTransit: 'En transit',
        CollectionItemStatus.owned: 'Possédé',
        CollectionItemStatus.duplicate: 'Doublon',
        CollectionItemStatus.trade: 'À échanger',
        CollectionItemStatus.forSale: 'À vendre',
        CollectionItemStatus.sold: 'Vendu',
        CollectionItemStatus.gifted: 'Donné',
        CollectionItemStatus.lost: 'Perdu',
        CollectionItemStatus.repair: 'En réparation',
        CollectionItemStatus.storage: 'En stockage',
      },
      'es': {
        CollectionItemStatus.missing: 'No encontrado',
        CollectionItemStatus.wanted: 'Necesario',
        CollectionItemStatus.ordered: 'Pedido',
        CollectionItemStatus.inTransit: 'En tránsito',
        CollectionItemStatus.owned: 'En colección',
        CollectionItemStatus.duplicate: 'Duplicado',
        CollectionItemStatus.trade: 'Para intercambio',
        CollectionItemStatus.forSale: 'En venta',
        CollectionItemStatus.sold: 'Vendido',
        CollectionItemStatus.gifted: 'Regalado',
        CollectionItemStatus.lost: 'Perdido',
        CollectionItemStatus.repair: 'En reparación',
        CollectionItemStatus.storage: 'En almacenamiento',
      },
      'it': {
        CollectionItemStatus.missing: 'Non trovato',
        CollectionItemStatus.wanted: 'Necessario',
        CollectionItemStatus.ordered: 'Ordinato',
        CollectionItemStatus.inTransit: 'In transito',
        CollectionItemStatus.owned: 'Posseduto',
        CollectionItemStatus.duplicate: 'Doppione',
        CollectionItemStatus.trade: 'Da scambiare',
        CollectionItemStatus.forSale: 'In vendita',
        CollectionItemStatus.sold: 'Venduto',
        CollectionItemStatus.gifted: 'Regalato',
        CollectionItemStatus.lost: 'Perso',
        CollectionItemStatus.repair: 'In riparazione',
        CollectionItemStatus.storage: 'In deposito',
      },
      'pt': {
        CollectionItemStatus.missing: 'Não encontrado',
        CollectionItemStatus.wanted: 'Necessário',
        CollectionItemStatus.ordered: 'Encomendado',
        CollectionItemStatus.inTransit: 'Em trânsito',
        CollectionItemStatus.owned: 'Possuído',
        CollectionItemStatus.duplicate: 'Duplicado',
        CollectionItemStatus.trade: 'Para troca',
        CollectionItemStatus.forSale: 'À venda',
        CollectionItemStatus.sold: 'Vendido',
        CollectionItemStatus.gifted: 'Oferecido',
        CollectionItemStatus.lost: 'Perdido',
        CollectionItemStatus.repair: 'Em reparação',
        CollectionItemStatus.storage: 'Armazenado',
      },
      'zh': {
        CollectionItemStatus.missing: '未找到',
        CollectionItemStatus.wanted: '需要',
        CollectionItemStatus.ordered: '已订购',
        CollectionItemStatus.inTransit: '运输中',
        CollectionItemStatus.owned: '已有',
        CollectionItemStatus.duplicate: '重复品',
        CollectionItemStatus.trade: '待交换',
        CollectionItemStatus.forSale: '待出售',
        CollectionItemStatus.sold: '已售出',
        CollectionItemStatus.gifted: '已赠送',
        CollectionItemStatus.lost: '已丢失',
        CollectionItemStatus.repair: '维修中',
        CollectionItemStatus.storage: '存放中',
      },
      'ja': {
        CollectionItemStatus.missing: '未発見',
        CollectionItemStatus.wanted: '必要',
        CollectionItemStatus.ordered: '注文済み',
        CollectionItemStatus.inTransit: '輸送中',
        CollectionItemStatus.owned: '所持',
        CollectionItemStatus.duplicate: '重複',
        CollectionItemStatus.trade: '交換用',
        CollectionItemStatus.forSale: '販売用',
        CollectionItemStatus.sold: '売却済み',
        CollectionItemStatus.gifted: '譲渡済み',
        CollectionItemStatus.lost: '紛失',
        CollectionItemStatus.repair: '修理中',
        CollectionItemStatus.storage: '保管中',
      },
      'ko': {
        CollectionItemStatus.missing: '찾지 못함',
        CollectionItemStatus.wanted: '필요',
        CollectionItemStatus.ordered: '주문됨',
        CollectionItemStatus.inTransit: '배송 중',
        CollectionItemStatus.owned: '보유',
        CollectionItemStatus.duplicate: '중복',
        CollectionItemStatus.trade: '교환용',
        CollectionItemStatus.forSale: '판매용',
        CollectionItemStatus.sold: '판매됨',
        CollectionItemStatus.gifted: '선물함',
        CollectionItemStatus.lost: '분실',
        CollectionItemStatus.repair: '수리 중',
        CollectionItemStatus.storage: '보관 중',
      },
      'ar': {
        CollectionItemStatus.missing: 'غير موجود',
        CollectionItemStatus.wanted: 'مطلوب',
        CollectionItemStatus.ordered: 'تم الطلب',
        CollectionItemStatus.inTransit: 'قيد النقل',
        CollectionItemStatus.owned: 'موجود',
        CollectionItemStatus.duplicate: 'مكرر',
        CollectionItemStatus.trade: 'للتبادل',
        CollectionItemStatus.forSale: 'للبيع',
        CollectionItemStatus.sold: 'مباع',
        CollectionItemStatus.gifted: 'تم إهداؤه',
        CollectionItemStatus.lost: 'مفقود',
        CollectionItemStatus.repair: 'قيد الإصلاح',
        CollectionItemStatus.storage: 'في التخزين',
      },
    };
    return titles[languageCode]?[this] ?? titles['en']![this]!;
  }

  static CollectionItemStatus fromValue(String? value) =>
      CollectionItemStatus.values.firstWhere(
        (item) => item.name == value,
        orElse: () => CollectionItemStatus.missing,
      );
}

enum CollectionItemCondition {
  newItem,
  likeNew,
  veryGood,
  good,
  satisfactory,
  poor,
  damaged,
  incomplete,
}

extension CollectionItemConditionX on CollectionItemCondition {
  String get value => name;
  String get title => localizedTitle('ru');

  String localizedTitle(String languageCode) {
    const titles = <String, Map<CollectionItemCondition, String>>{
      'ru': {
        CollectionItemCondition.newItem: 'Новый',
        CollectionItemCondition.likeNew: 'Как новый',
        CollectionItemCondition.veryGood: 'Очень хорошее',
        CollectionItemCondition.good: 'Хорошее',
        CollectionItemCondition.satisfactory: 'Удовлетворительное',
        CollectionItemCondition.poor: 'Плохое',
        CollectionItemCondition.damaged: 'Поврежден',
        CollectionItemCondition.incomplete: 'Не полный комплект',
      },
      'en': {
        CollectionItemCondition.newItem: 'New',
        CollectionItemCondition.likeNew: 'Like new',
        CollectionItemCondition.veryGood: 'Very good',
        CollectionItemCondition.good: 'Good',
        CollectionItemCondition.satisfactory: 'Satisfactory',
        CollectionItemCondition.poor: 'Poor',
        CollectionItemCondition.damaged: 'Damaged',
        CollectionItemCondition.incomplete: 'Incomplete set',
      },
      'de': {
        CollectionItemCondition.newItem: 'Neu',
        CollectionItemCondition.likeNew: 'Wie neu',
        CollectionItemCondition.veryGood: 'Sehr gut',
        CollectionItemCondition.good: 'Gut',
        CollectionItemCondition.satisfactory: 'Befriedigend',
        CollectionItemCondition.poor: 'Schlecht',
        CollectionItemCondition.damaged: 'Beschädigt',
        CollectionItemCondition.incomplete: 'Unvollständig',
      },
      'fr': {
        CollectionItemCondition.newItem: 'Neuf',
        CollectionItemCondition.likeNew: 'Comme neuf',
        CollectionItemCondition.veryGood: 'Très bon',
        CollectionItemCondition.good: 'Bon',
        CollectionItemCondition.satisfactory: 'Satisfaisant',
        CollectionItemCondition.poor: 'Mauvais',
        CollectionItemCondition.damaged: 'Endommagé',
        CollectionItemCondition.incomplete: 'Ensemble incomplet',
      },
      'es': {
        CollectionItemCondition.newItem: 'Nuevo',
        CollectionItemCondition.likeNew: 'Como nuevo',
        CollectionItemCondition.veryGood: 'Muy bueno',
        CollectionItemCondition.good: 'Bueno',
        CollectionItemCondition.satisfactory: 'Satisfactorio',
        CollectionItemCondition.poor: 'Malo',
        CollectionItemCondition.damaged: 'Dañado',
        CollectionItemCondition.incomplete: 'Conjunto incompleto',
      },
      'it': {
        CollectionItemCondition.newItem: 'Nuovo',
        CollectionItemCondition.likeNew: 'Come nuovo',
        CollectionItemCondition.veryGood: 'Molto buono',
        CollectionItemCondition.good: 'Buono',
        CollectionItemCondition.satisfactory: 'Soddisfacente',
        CollectionItemCondition.poor: 'Scarso',
        CollectionItemCondition.damaged: 'Danneggiato',
        CollectionItemCondition.incomplete: 'Set incompleto',
      },
      'pt': {
        CollectionItemCondition.newItem: 'Novo',
        CollectionItemCondition.likeNew: 'Como novo',
        CollectionItemCondition.veryGood: 'Muito bom',
        CollectionItemCondition.good: 'Bom',
        CollectionItemCondition.satisfactory: 'Satisfatório',
        CollectionItemCondition.poor: 'Mau',
        CollectionItemCondition.damaged: 'Danificado',
        CollectionItemCondition.incomplete: 'Conjunto incompleto',
      },
      'zh': {
        CollectionItemCondition.newItem: '全新',
        CollectionItemCondition.likeNew: '近新',
        CollectionItemCondition.veryGood: '非常好',
        CollectionItemCondition.good: '良好',
        CollectionItemCondition.satisfactory: '一般',
        CollectionItemCondition.poor: '较差',
        CollectionItemCondition.damaged: '损坏',
        CollectionItemCondition.incomplete: '套装不完整',
      },
      'ja': {
        CollectionItemCondition.newItem: '新品',
        CollectionItemCondition.likeNew: '新品同様',
        CollectionItemCondition.veryGood: '非常に良い',
        CollectionItemCondition.good: '良い',
        CollectionItemCondition.satisfactory: '可',
        CollectionItemCondition.poor: '悪い',
        CollectionItemCondition.damaged: '破損',
        CollectionItemCondition.incomplete: '不完全なセット',
      },
      'ko': {
        CollectionItemCondition.newItem: '새 제품',
        CollectionItemCondition.likeNew: '새 제품과 같음',
        CollectionItemCondition.veryGood: '매우 좋음',
        CollectionItemCondition.good: '좋음',
        CollectionItemCondition.satisfactory: '보통',
        CollectionItemCondition.poor: '나쁨',
        CollectionItemCondition.damaged: '손상됨',
        CollectionItemCondition.incomplete: '불완전한 세트',
      },
      'ar': {
        CollectionItemCondition.newItem: 'جديد',
        CollectionItemCondition.likeNew: 'كالجديد',
        CollectionItemCondition.veryGood: 'جيد جداً',
        CollectionItemCondition.good: 'جيد',
        CollectionItemCondition.satisfactory: 'مقبول',
        CollectionItemCondition.poor: 'سيئ',
        CollectionItemCondition.damaged: 'تالف',
        CollectionItemCondition.incomplete: 'مجموعة غير مكتملة',
      },
    };
    return titles[languageCode]?[this] ?? titles['en']![this]!;
  }

  static CollectionItemCondition? fromValue(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final condition in CollectionItemCondition.values) {
      if (condition.name == value) return condition;
    }
    return null;
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

  CollectionItemCondition? get conditionValue =>
      CollectionItemConditionX.fromValue(condition);

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
    return decoded.map(
      (key, value) => MapEntry(
        key.toString(),
        ItemState.fromJson(
          value is Map
              ? Map<String, dynamic>.from(value)
              : <String, dynamic>{},
        ),
      ),
    );
  }

  static Future<ItemState> load(String itemId) async =>
      (await loadAll())[itemId] ?? ItemState(updatedAt: DateTime.now());

  static Future<void> save(
    String itemId,
    ItemState state, {
    String? title,
    bool recordHistory = true,
  }) async {
    final states = await loadAll();
    states[itemId] = state;
    await replaceAll(states);
    if (recordHistory) {
      await CollectionHistoryStore.record(
        type: 'item_state',
        title: title ?? itemId,
        details: '${state.status.title}; ${state.quantity} шт.; ${state.condition}',
      );
    }
  }

  static Future<void> remove(String itemId) async {
    final states = await loadAll();
    if (!states.containsKey(itemId)) return;
    states.remove(itemId);
    await replaceAll(states);
  }

  static Future<void> replaceAll(Map<String, ItemState> states) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      states.map((key, value) => MapEntry(key, value.toJson())),
    );
    final saved = await preferences.setString(_key, encoded);
    if (!saved) throw StateError('Не удалось сохранить состояния предметов');
    revision.value++;
  }
}
