import '../../../items/domain/entities/item.dart';
import '../../../items/domain/entities/item_value.dart';
import '../../../fields/domain/entities/field_definition.dart';
import '../entities/collection_view.dart';
import '../entities/collection_filter.dart';

/// Движок выборки предметов для представлений коллекции.
class CollectionQueryService {
  List<Item> filterItems({
    required List<Item> items,
    required List<ItemValue> values,
    required List<FieldDefinition> fields,
    CollectionFilter? filter,
  }) {
    if (filter == null || filter.query.trim().isEmpty) {
      return [...items];
    }

    final fieldIds = fields.map((field) => field.id).toSet();
    if (!fieldIds.contains(filter.fieldId)) {
      return [...items];
    }

    final query = filter.query.toLowerCase().trim();
    final matchingItemIds = values
        .where(
          (value) =>
              value.fieldId == filter.fieldId &&
              value.value.toLowerCase().contains(query),
        )
        .map((value) => value.itemId)
        .toSet();

    final result = items
        .where((item) => matchingItemIds.contains(item.id))
        .toList();

    if (filter.descending) {
      return result.reversed.toList();
    }

    return result;
  }

  List<String> visibleFieldIds(
    CollectionView view,
    List<FieldDefinition> fields,
  ) {
    if (view.fieldIds.isEmpty) {
      return fields.map((field) => field.id).toList();
    }

    return fields
        .where((field) => view.fieldIds.contains(field.id))
        .map((field) => field.id)
        .toList();
  }
}
