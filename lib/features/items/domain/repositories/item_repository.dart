import '../entities/item.dart';
import '../entities/item_attachment.dart';
import '../entities/item_value.dart';

/// Репозиторий предметов коллекции.
///
/// Отвечает за хранение физических экземпляров, их значений и вложений.
abstract class ItemRepository {
  Future<List<Item>> getItems(String collectionId);
  Future<Item?> getItem(String id);

  /// Получить все экземпляры конкретной каталожной позиции.
  Future<List<Item>> getItemsByCatalogItem(String catalogItemId);

  /// Получить количество экземпляров конкретной каталожной позиции.
  Future<int> getItemCountByCatalogItem(String catalogItemId);

  Future<void> saveItem(Item item);
  Future<void> updateItem(Item item);
  Future<void> deleteItem(String id);
  Future<List<ItemValue>> getValues(String itemId);
  Future<void> saveValue(ItemValue value);
  Future<void> updateValue(ItemValue value);
  Future<void> deleteValue(String id);
  Future<List<ItemAttachment>> getAttachments(String itemId);
  Future<void> saveAttachment(ItemAttachment attachment);
  Future<void> deleteAttachment(String id);
}
