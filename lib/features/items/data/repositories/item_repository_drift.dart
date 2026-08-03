import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';

import '../../domain/entities/item.dart';
import '../../domain/entities/item_attachment.dart';
import '../../domain/entities/item_value.dart';

import '../../domain/repositories/item_repository.dart';

class ItemRepositoryDrift implements ItemRepository {
  final AppDatabase database;

  ItemRepositoryDrift(
    this.database,
  );

  @override
  Future<List<Item>> getItems(
    String collectionId,
  ) async {
    final rows = await (database.select(
      database.itemTable,
    )
          ..where(
            (table) =>
                table.collectionId.equals(
              collectionId,
            ),
          )
          ..orderBy([
            (table) =>
                OrderingTerm.asc(
              table.sortOrder,
            ),
          ]))
        .get();

    return rows
        .map(
          (row) => Item(
            id: row.id,
            collectionId: row.collectionId,
            sectionId: row.sectionId,
            sortOrder: row.sortOrder,
            createdAt: row.createdAt,
            updatedAt: row.updatedAt,
          ),
        )
        .toList();
  }

  @override
  Future<Item?> getItem(
    String id,
  ) async {
    final row = await (database.select(
      database.itemTable,
    )
          ..where(
            (table) =>
                table.id.equals(id),
          ))
        .getSingleOrNull();

    if (row == null) {
      return null;
    }

    return Item(
      id: row.id,
      collectionId: row.collectionId,
      sectionId: row.sectionId,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  @override
  Future<void> saveItem(
    Item item,
  ) async {
    await database
        .into(
          database.itemTable,
        )
        .insertOnConflictUpdate(
          ItemTableCompanion(
            id: Value(
              item.id,
            ),
            collectionId: Value(
              item.collectionId,
            ),
            sectionId: Value(
              item.sectionId,
            ),
            sortOrder: Value(
              item.sortOrder,
            ),
            createdAt: Value(
              item.createdAt,
            ),
            updatedAt: Value(
              item.updatedAt,
            ),
          ),
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
    await (database.delete(
      database.itemTable,
    )
          ..where(
            (table) =>
                table.id.equals(id),
          ))
        .go();

    await (database.delete(
      database.itemValueTable,
    )
          ..where(
            (table) =>
                table.itemId.equals(id),
          ))
        .go();

    await (database.delete(
      database.itemAttachmentTable,
    )
          ..where(
            (table) =>
                table.itemId.equals(id),
          ))
        .go();
  }

  @override
  Future<List<ItemValue>> getValues(
    String itemId,
  ) async {
    final rows = await (database.select(
      database.itemValueTable,
    )
          ..where(
            (table) =>
                table.itemId.equals(itemId),
          ))
        .get();

    return rows
        .map(
          (row) => ItemValue(
            id: row.id,
            itemId: row.itemId,
            fieldId: row.fieldId,
            value: row.value,
          ),
        )
        .toList();
  }

  @override
  Future<void> saveValue(
    ItemValue value,
  ) async {
    await database
        .into(
          database.itemValueTable,
        )
        .insertOnConflictUpdate(
          ItemValueTableCompanion(
            id: Value(
              value.id,
            ),
            itemId: Value(
              value.itemId,
            ),
            fieldId: Value(
              value.fieldId,
            ),
            value: Value(
              value.value,
            ),
          ),
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
    await (database.delete(
      database.itemValueTable,
    )
          ..where(
            (table) =>
                table.id.equals(id),
          ))
        .go();
  }

  @override
  Future<List<ItemAttachment>> getAttachments(
    String itemId,
  ) async {
    final rows = await (database.select(
      database.itemAttachmentTable,
    )
          ..where(
            (table) =>
                table.itemId.equals(itemId),
          ))
        .get();

    return rows
        .map(
          (row) => ItemAttachment(
            id: row.id,
            itemId: row.itemId,
            path: row.path,
            type: row.type,
          ),
        )
        .toList();
  }

  @override
  Future<void> saveAttachment(
    ItemAttachment attachment,
  ) async {
    await database
        .into(
          database.itemAttachmentTable,
        )
        .insertOnConflictUpdate(
          ItemAttachmentTableCompanion(
            id: Value(
              attachment.id,
            ),
            itemId: Value(
              attachment.itemId,
            ),
            path: Value(
              attachment.path,
            ),
            type: Value(
              attachment.type,
            ),
          ),
        );
  }

  @override
  Future<void> deleteAttachment(
    String id,
  ) async {
    await (database.delete(
      database.itemAttachmentTable,
    )
          ..where(
            (table) =>
                table.id.equals(id),
          ))
        .go();
  }
}