import 'package:flutter_test/flutter_test.dart';

import '../../../lib/features/items/data/item_state_store.dart';

void main() {
  test('все статусы предмета имеют уникальные коды и восстанавливаются', () {
    final values =
        CollectionItemStatus.values.map((item) => item.value).toList();

    expect(values.toSet().length, values.length);
    expect(
      CollectionItemStatusX.fromValue('inTransit'),
      CollectionItemStatus.inTransit,
    );
    expect(
      CollectionItemStatusX.fromValue('forSale'),
      CollectionItemStatus.forSale,
    );
    expect(
      CollectionItemStatusX.fromValue('repair'),
      CollectionItemStatus.repair,
    );
    expect(
      CollectionItemStatusX.fromValue('unknown'),
      CollectionItemStatus.missing,
    );
  });

  test('состояния предмета локализуются и восстанавливаются', () {
    expect(
      CollectionItemCondition.newItem.localizedTitle('ru'),
      'Новый',
    );
    expect(
      CollectionItemCondition.damaged.localizedTitle('en'),
      'Damaged',
    );
    expect(
      CollectionItemConditionX.fromValue('incomplete'),
      CollectionItemCondition.incomplete,
    );
    expect(CollectionItemConditionX.fromValue(''), isNull);
  });

  test('ItemState сохраняет статус и состояние в JSON', () {
    final state = ItemState(
      status: CollectionItemStatus.inTransit,
      quantity: 2,
      condition: CollectionItemCondition.likeNew.name,
      note: 'Проверить упаковку',
      updatedAt: DateTime(2026, 8, 22),
    );

    final restored = ItemState.fromJson(state.toJson());

    expect(restored.status, CollectionItemStatus.inTransit);
    expect(restored.quantity, 2);
    expect(restored.conditionValue, CollectionItemCondition.likeNew);
    expect(restored.note, 'Проверить упаковку');
  });
}
