import '../../../items/domain/entities/item.dart';

/// Подготавливает данные коллекции для резервного копирования.
///
/// Сервис намеренно не занимается записью файлов: он формирует простую
/// структуру данных, которую можно передать JSON- или файловому хранилищу.
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
              'storageNodeId': item.storageNodeId,
              'createdAt': item.createdAt.toIso8601String(),
              'updatedAt': item.updatedAt.toIso8601String(),
            },
          )
          .toList(),
    };
  }
}
