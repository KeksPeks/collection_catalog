import '../../domain/entities/item.dart';
import '../../domain/entities/item_attachment.dart';
import '../../domain/entities/item_value.dart';
import '../../domain/repositories/item_repository.dart';

/// Временная реализация репозитория предметов в памяти.
///
/// Используется до подключения Drift.
/// Интерфейс полностью совпадает с будущим хранилищем.
class MemoryItemRepository implements ItemRepository {
  final List<Item> _items = [];

  final List<ItemValue> _values = [];

  final List<ItemAttachment> _attachments = [];

  @override
  Future<List<Item>> getItems(
    String collectionId,
  ) async {
    return _items
        .where(
          (item) =>
              item.collectionId == collectionId,
        )
        .toList();
  }

  @override
  Future<Item?> getItem(
    String id,
  ) async {
    try {
      return _items.firstWhere(
        (item) =>
            item.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveItem(
    Item item,
  ) async {
    _items.removeWhere(
      (e) =>
          e.id == item.id,
    );

    _items.add(
      item,
    );
  }

  @override
  Future<void> updateItem(
    Item item,
  ) async {
    await saveItem(
      item,
    );
  }

  @override
  Future<void> deleteItem(
    String id,
  ) async {
    _items.removeWhere(
      (e) =>
          e.id == id,
    );

    _values.removeWhere(
      (e) =>
          e.itemId == id,
    );

    _attachments.removeWhere(
      (e) =>
          e.itemId == id,
    );
  }

  @override
  Future<List<ItemValue>> getValues(
    String itemId,
  ) async {
    return _values
        .where(
          (e) =>
              e.itemId == itemId,
        )
        .toList();
  }

  @override
  Future<void> saveValue(
    ItemValue value,
  ) async {
    _values.removeWhere(
      (e) =>
          e.id == value.id,
    );

    _values.add(
      value,
    );
  }

  @override
  Future<void> updateValue(
    ItemValue value,
  ) async {
    await saveValue(
      value,
    );
  }

  @override
  Future<void> deleteValue(
    String id,
  ) async {
    _values.removeWhere(
      (e) =>
          e.id == id,
    );
  }

  @override
  Future<List<ItemAttachment>> getAttachments(
    String itemId,
  ) async {
    return _attachments
        .where(
          (e) =>
              e.itemId == itemId,
        )
        .toList();
  }

  @override
  Future<void> saveAttachment(
    ItemAttachment attachment,
  ) async {
    _attachments.removeWhere(
      (e) =>
          e.id == attachment.id,
    );

    _attachments.add(
      attachment,
    );
  }

  @override
  Future<void> deleteAttachment(
    String id,
  ) async {
    _attachments.removeWhere(
      (e) =>
          e.id == id,
    );
  }
}