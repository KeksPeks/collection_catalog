import '../entities/catalog_item.dart';

/// Репозиторий каталожных позиций.
abstract class CatalogItemRepository {
  Future<List<CatalogItem>> getCatalogItems(String collectionId);

  Future<CatalogItem?> getCatalogItem(String id);

  Future<void> saveCatalogItem(CatalogItem item);

  /// Удаляет только каталожную позицию и связи с экземплярами.
  /// Физические экземпляры пользователя не удаляются.
  Future<void> deleteCatalogItem(String id);
}
