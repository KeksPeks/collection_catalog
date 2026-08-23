import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/catalog_item.dart';
import '../../domain/repositories/catalog_item_repository.dart';

/// Репозиторий каталожных позиций.
class CatalogItemRepositoryDrift implements CatalogItemRepository {
  final AppDatabase database;

  CatalogItemRepositoryDrift(this.database);

  @override
  Future<List<CatalogItem>> getCatalogItems(String collectionId) async {
    final rows = await database.customSelect(
      '''
      SELECT id, collection_id, name, external_id, source_url,
             created_at, updated_at
      FROM catalog_items
      WHERE collection_id = ?
      ORDER BY name
      ''',
      variables: [Variable.withString(collectionId)],
    ).get();

    return rows.map(_fromRow).toList();
  }

  @override
  Future<CatalogItem?> getCatalogItem(String id) async {
    final rows = await database.customSelect(
      '''
      SELECT id, collection_id, name, external_id, source_url,
             created_at, updated_at
      FROM catalog_items
      WHERE id = ?
      LIMIT 1
      ''',
      variables: [Variable.withString(id)],
    ).get();

    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  @override
  Future<void> saveCatalogItem(CatalogItem item) async {
    await database.customStatement(
      '''
      INSERT INTO catalog_items
        (id, collection_id, name, external_id, source_url, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        collection_id = excluded.collection_id,
        name = excluded.name,
        external_id = excluded.external_id,
        source_url = excluded.source_url,
        updated_at = excluded.updated_at
      ''',
      [
        item.id,
        item.collectionId,
        item.name,
        item.externalId,
        item.sourceUrl,
        item.createdAt.microsecondsSinceEpoch,
        item.updatedAt.microsecondsSinceEpoch,
      ],
    );
  }

  @override
  Future<void> deleteCatalogItem(String id) async {
    // Удаляем каталожную позицию, но сохраняем физические экземпляры.
    // Они становятся независимыми от каталога и не теряют пользовательские данные.
    await database.transaction(() async {
      await database.customStatement(
        'DELETE FROM item_catalog_links WHERE catalog_item_id = ?',
        [id],
      );
      await database.customStatement(
        'DELETE FROM catalog_items WHERE id = ?',
        [id],
      );
    });
  }

  CatalogItem _fromRow(QueryRow row) {
    return CatalogItem(
      id: row.read<String>('id'),
      collectionId: row.read<String>('collection_id'),
      name: row.read<String>('name'),
      externalId: row.readNullable<String>('external_id'),
      sourceUrl: row.readNullable<String>('source_url'),
      createdAt: DateTime.fromMicrosecondsSinceEpoch(
        row.read<int>('created_at'),
      ),
      updatedAt: DateTime.fromMicrosecondsSinceEpoch(
        row.read<int>('updated_at'),
      ),
    );
  }
}
