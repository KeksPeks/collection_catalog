import '../entities/item.dart';
import '../entities/item_attachment.dart';
import '../entities/item_value.dart';
import '../repositories/item_repository.dart';

/// Сервис работы с физическими экземплярами коллекции.
class ItemService {
  final ItemRepository repository;

  ItemService(this.repository);

  Future<List<Item>> getItems(String collectionId) {
    return repository.getItems(collectionId);
  }

  Future<Item?> getItem(String id) {
    return repository.getItem(id);
  }

  /// Получить все физические экземпляры одной каталожной позиции.
  Future<List<Item>> getItemsByCatalogItem(String catalogItemId) {
    return repository.getItemsByCatalogItem(catalogItemId);
  }

  /// Получить количество физических экземпляров одной каталожной позиции.
  Future<int> getItemCountByCatalogItem(String catalogItemId) {
    return repository.getItemCountByCatalogItem(catalogItemId);
  }

  Future<void> saveItem(Item item) {
    return repository.saveItem(item);
  }

  Future<void> updateItem(Item item) {
    return repository.updateItem(item);
  }

  Future<void> deleteItem(String id) {
    return repository.deleteItem(id);
  }

  Future<List<ItemValue>> getValues(String itemId) {
    return repository.getValues(itemId);
  }

  Future<void> saveValue(ItemValue value) {
    return repository.saveValue(value);
  }

  Future<void> updateValue(ItemValue value) {
    return repository.updateValue(value);
  }

  Future<void> deleteValue(String id) {
    return repository.deleteValue(id);
  }

  Future<List<ItemAttachment>> getAttachments(String itemId) {
    return repository.getAttachments(itemId);
  }

  Future<void> saveAttachment(ItemAttachment attachment) {
    return repository.saveAttachment(attachment);
  }

  Future<void> deleteAttachment(String id) {
    return repository.deleteAttachment(id);
  }
}
