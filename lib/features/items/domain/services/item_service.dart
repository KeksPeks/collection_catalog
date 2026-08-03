import '../entities/item.dart';
import '../entities/item_attachment.dart';
import '../entities/item_value.dart';
import '../repositories/item_repository.dart';

/// Сервис работы с предметами коллекции.
///
/// Содержит бизнес-логику работы с:
/// - предметами;
/// - значениями полей;
/// - файлами предметов.
///
/// Не зависит от способа хранения данных.
class ItemService {
  final ItemRepository repository;

  ItemService(
    this.repository,
  );

  /// Получить предметы коллекции.
  Future<List<Item>> getItems(
    String collectionId,
  ) {
    return repository.getItems(
      collectionId,
    );
  }

  /// Получить предмет по идентификатору.
  Future<Item?> getItem(
    String id,
  ) {
    return repository.getItem(
      id,
    );
  }

  /// Сохранить предмет.
  Future<void> saveItem(
    Item item,
  ) {
    return repository.saveItem(
      item,
    );
  }

  /// Обновить предмет.
  Future<void> updateItem(
    Item item,
  ) {
    return repository.updateItem(
      item,
    );
  }

  /// Удалить предмет.
  Future<void> deleteItem(
    String id,
  ) {
    return repository.deleteItem(
      id,
    );
  }

  /// Получить значения полей предмета.
  Future<List<ItemValue>> getValues(
    String itemId,
  ) {
    return repository.getValues(
      itemId,
    );
  }

  /// Сохранить значение поля.
  Future<void> saveValue(
    ItemValue value,
  ) {
    return repository.saveValue(
      value,
    );
  }

  /// Обновить значение поля.
  Future<void> updateValue(
    ItemValue value,
  ) {
    return repository.updateValue(
      value,
    );
  }

  /// Удалить значение поля.
  Future<void> deleteValue(
    String id,
  ) {
    return repository.deleteValue(
      id,
    );
  }

  /// Получить файлы предмета.
  Future<List<ItemAttachment>> getAttachments(
    String itemId,
  ) {
    return repository.getAttachments(
      itemId,
    );
  }

  /// Сохранить файл предмета.
  Future<void> saveAttachment(
    ItemAttachment attachment,
  ) {
    return repository.saveAttachment(
      attachment,
    );
  }

  /// Удалить файл предмета.
  Future<void> deleteAttachment(
    String id,
  ) {
    return repository.deleteAttachment(
      id,
    );
  }
}