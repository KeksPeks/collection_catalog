import '../entities/item.dart';
import '../entities/item_attachment.dart';
import '../entities/item_value.dart';
import '../repositories/item_repository.dart';

/// Сервис работы с предметами коллекции.
class ItemService {
  final ItemRepository repository;
  ItemService(this.repository);

  Future<List<Item>> getItems(String collectionId) => repository.getItems(collectionId);
  Future<Item?> getItem(String id) => repository.getItem(id);
  Future<List<Item>> getItemsByCatalogItem(String catalogItemId) => repository.getItemsByCatalogItem(catalogItemId);
  Future<int> getItemCountByCatalogItem(String catalogItemId) => repository.getItemCountByCatalogItem(catalogItemId);
  Future<void> saveItem(Item item) => repository.saveItem(item);
  Future<void> updateItem(Item item) => repository.updateItem(item);
  Future<void> deleteItem(String id) => repository.deleteItem(id);
  Future<List<ItemValue>> getValues(String itemId) => repository.getValues(itemId);
  Future<void> saveValue(ItemValue value) => repository.saveValue(value);
  Future<void> updateValue(ItemValue value) => repository.updateValue(value);
  Future<void> deleteValue(String id) => repository.deleteValue(id);
  Future<List<ItemAttachment>> getAttachments(String itemId) => repository.getAttachments(itemId);
  Future<void> saveAttachment(ItemAttachment attachment) => repository.saveAttachment(attachment);
  Future<void> deleteAttachment(String id) => repository.deleteAttachment(id);
}
