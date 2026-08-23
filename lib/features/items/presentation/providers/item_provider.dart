import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/item.dart';
import '../../domain/entities/item_value.dart';

import 'item_service_provider.dart';

/// Получение всех физических экземпляров коллекции.
final itemsProvider = FutureProvider.family<List<Item>, String>(
  (ref, collectionId) => ref.watch(itemServiceProvider).getItems(collectionId),
);

/// Получение одного физического экземпляра.
final itemProvider = FutureProvider.family<Item?, String>(
  (ref, itemId) => ref.watch(itemServiceProvider).getItem(itemId),
);

/// Получение всех физических экземпляров одной каталожной позиции.
final catalogItemInstancesProvider = FutureProvider.family<List<Item>, String>(
  (ref, catalogItemId) =>
      ref.watch(itemServiceProvider).getItemsByCatalogItem(catalogItemId),
);

/// Получение значений полей физического экземпляра.
final itemValuesProvider = FutureProvider.family<List<ItemValue>, String>(
  (ref, itemId) => ref.watch(itemServiceProvider).getValues(itemId),
);

/// Все значения предметов коллекции в форме itemId -> fieldId -> value.
final collectionItemValuesProvider = FutureProvider.family<
    Map<String, Map<String, String>>, String>(
  (ref, collectionId) async {
    final service = ref.watch(itemServiceProvider);
    final items = await service.getItems(collectionId);
    final result = <String, Map<String, String>>{};

    for (final item in items) {
      final values = await service.getValues(item.id);
      result[item.id] = {
        for (final value in values) value.fieldId: value.value,
      };
    }

    return result;
  },
);