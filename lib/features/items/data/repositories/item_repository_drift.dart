import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/item_attachment.dart';
import '../../domain/entities/item_value.dart';
import '../../domain/repositories/item_repository.dart';

/// Репозиторий физических экземпляров и их данных.
class ItemRepositoryDrift implements ItemRepository {
  final AppDatabase database;

  ItemRepositoryDrift(this.database);

  @override
  Future<List<Item>> getItems(String collectionId) async {
    final rows = await (database.select(database.itemTable)
          ..where((table) => table.collectionId.equals(collectionId))
          ..orderBy([(table) => OrderingTerm.asc(table.sortOrder)]))
        .get();
    return Future.wait(rows.map(_fromRow));
  }

  @override
  Future<Item?> getItem(String id) async {
    final row = await (database.select(database.itemTable)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<List<Item>> getItemsByCatalogItem(String catalogItemId) async {
    final rows = await database.customSelect('''
      SELECT i.id, i.collection_id, i.section_id, i.sort_order, i.created_at, i.updated_at
      FROM item_table i
      INNER JOIN item_catalog_links l ON l.item_id = i.id
      WHERE l.catalog_item_id = ?
      ORDER BY i.sort_order
    ''', variables: [Variable.withString(catalogItemId)]).get();
    return rows.map((row) => Item(
      id: row.read<String>('id'), catalogItemId: catalogItemId,
      collectionId: row.read<String>('collection_id'),
      sectionId: row.readNullable<String>('section_id'),
      sortOrder: row.read<int>('sort_order'),
      createdAt: DateTime.fromMicrosecondsSinceEpoch(row.read<int>('created_at')),
      updatedAt: DateTime.fromMicrosecondsSinceEpoch(row.read<int>('updated_at')),
    )).toList();
  }

  @override
  Future<int> getItemCountByCatalogItem(String catalogItemId) async {
    final rows = await database.customSelect('SELECT COUNT(*) AS count FROM item_catalog_links WHERE catalog_item_id = ?', variables: [Variable.withString(catalogItemId)]).get();
    return rows.first.read<int>('count');
  }

  @override
  Future<void> saveItem(Item item) async {
    await database.transaction(() async {
      await database.into(database.itemTable).insertOnConflictUpdate(ItemTableCompanion(
        id: Value(item.id), collectionId: Value(item.collectionId), sectionId: Value(item.sectionId),
        sortOrder: Value(item.sortOrder), createdAt: Value(item.createdAt), updatedAt: Value(item.updatedAt),
      ));
      if (item.catalogItemId != null) {
        await database.customStatement('''INSERT INTO item_catalog_links (item_id, catalog_item_id)
          VALUES (?, ?) ON CONFLICT(item_id) DO UPDATE SET catalog_item_id = excluded.catalog_item_id''',
          [item.id, item.catalogItemId]);
      } else {
        await database.customStatement('DELETE FROM item_catalog_links WHERE item_id = ?', [item.id]);
      }
    });
  }

  @override
  Future<void> updateItem(Item item) => saveItem(item);

  @override
  Future<void> deleteItem(String id) async {
    await database.transaction(() async {
      await database.delete(database.itemValueTable).where((table) => table.itemId.equals(id)).go();
      await database.delete(database.itemAttachmentTable).where((table) => table.itemId.equals(id)).go();
      await database.customStatement('DELETE FROM item_catalog_links WHERE item_id = ?', [id]);
      await database.delete(database.itemTable).where((table) => table.id.equals(id)).go();
    });
  }

  @override
  Future<List<ItemValue>> getValues(String itemId) async {
    final rows = await (database.select(database.itemValueTable)..where((table) => table.itemId.equals(itemId))).get();
    return rows.map((row) => ItemValue(id: row.id, itemId: row.itemId, fieldId: row.fieldId, value: row.value)).toList();
  }

  @override
  Future<void> saveValue(ItemValue value) async {
    await database.into(database.itemValueTable).insertOnConflictUpdate(ItemValueTableCompanion(
      id: Value(value.id), itemId: Value(value.itemId), fieldId: Value(value.fieldId), value: Value(value.value),
    ));
  }

  @override
  Future<void> updateValue(ItemValue value) => saveValue(value);

  @override
  Future<void> deleteValue(String id) async {
    await database.delete(database.itemValueTable).where((table) => table.id.equals(id)).go();
  }

  @override
  Future<List<ItemAttachment>> getAttachments(String itemId) async {
    final rows = await (database.select(database.itemAttachmentTable)..where((table) => table.itemId.equals(itemId))).get();
    return rows.map((row) => ItemAttachment(id: row.id, itemId: row.itemId, path: row.path, type: row.type)).toList();
  }

  @override
  Future<void> saveAttachment(ItemAttachment attachment) async {
    await database.into(database.itemAttachmentTable).insertOnConflictUpdate(ItemAttachmentTableCompanion(
      id: Value(attachment.id), itemId: Value(attachment.itemId), path: Value(attachment.path), type: Value(attachment.type),
    ));
  }

  @override
  Future<void> deleteAttachment(String id) async {
    await database.delete(database.itemAttachmentTable).where((table) => table.id.equals(id)).go();
  }

  Future<Item> _fromRow(ItemTableData row) async {
    final rows = await database.customSelect('SELECT catalog_item_id FROM item_catalog_links WHERE item_id = ? LIMIT 1', variables: [Variable.withString(row.id)]).get();
    return Item(
      id: row.id,
      catalogItemId: rows.isEmpty ? null : rows.first.read<String>('catalog_item_id'),
      collectionId: row.collectionId,
      sectionId: row.sectionId,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
