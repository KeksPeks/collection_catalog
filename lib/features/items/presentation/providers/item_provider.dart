import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/item.dart';
import '../../domain/entities/item_value.dart';

import 'item_service_provider.dart';

/// Получение всех предметов коллекции.
final itemsProvider = FutureProvider.family<
    List<Item>,
    String>(
  (
    ref,
    collectionId,
  ) {
    return ref
        .watch(
          itemServiceProvider,
        )
        .getItems(
          collectionId,
        );
  },
);

/// Получение одного предмета.
final itemProvider = FutureProvider.family<
    Item?,
    String>(
  (
    ref,
    itemId,
  ) {
    return ref
        .watch(
          itemServiceProvider,
        )
        .getItem(
          itemId,
        );
  },
);

/// Получение значений полей предмета.
final itemValuesProvider = FutureProvider.family<
    List<ItemValue>,
    String>(
  (
    ref,
    itemId,
  ) {
    return ref
        .watch(
          itemServiceProvider,
        )
        .getValues(
          itemId,
        );
  },
);