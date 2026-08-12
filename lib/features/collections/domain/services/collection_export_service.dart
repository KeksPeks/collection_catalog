import '../../../items/domain/entities/item.dart';

/// Подготавливает данные коллекции для резервного копирования.
class CollectionExportService {
  Map<String, dynamic> exportItems({
    required String collectionId,
    required List<Item> items,
  }) {
    return {
      'version': 1,
      'collectionId': collectionId,
      'items': items
          .map(
            (item) => {
              'id': item.id,
              'collectionId': item.collectionId,
              'sectionId': item.sectionId,
              'sortOrder': item.sortOrder,
              'createdAt': item.createdAt.toIso8601String(),
              'updatedAt': item.updatedAt.toIso8601String(),
            },
          )
          .toList(),
    };
  }
}
