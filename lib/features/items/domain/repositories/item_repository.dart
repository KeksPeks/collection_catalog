import '../entities/item.dart';
import '../entities/item_attachment.dart';
import '../entities/item_value.dart';

/// Репозиторий предметов коллекции.
///
/// Отвечает за хранение и получение:
/// - самих предметов Item;
/// - значений полей ItemValue;
/// - прикреплённых файлов ItemAttachment.
abstract class ItemRepository {
  /// Получить предметы коллекции.
  Future<List<Item>> getItems(
    String collectionId,
  );

  /// Получить предмет по идентификатору.
  Future<Item?> getItem(
    String id,
  );

  /// Сохранить предмет.
  Future<void> saveItem(
    Item item,
  );

  /// Обновить предмет.
  Future<void> updateItem(
    Item item,
  );

  /// Удалить предмет.
  Future<void> deleteItem(
    String id,
  );

  /// Получить значения полей предмета.
  Future<List<ItemValue>> getValues(
    String itemId,
  );

  /// Сохранить значение поля.
  Future<void> saveValue(
    ItemValue value,
  );

  /// Обновить значение поля.
  Future<void> updateValue(
    ItemValue value,
  );

  /// Удалить значение поля.
  Future<void> deleteValue(
    String id,
  );

  /// Получить файлы предмета.
  Future<List<ItemAttachment>> getAttachments(
    String itemId,
  );

  /// Сохранить файл предмета.
  Future<void> saveAttachment(
    ItemAttachment attachment,
  );

  /// Удалить файл предмета.
  Future<void> deleteAttachment(
    String id,
  );
}