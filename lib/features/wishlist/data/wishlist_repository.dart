import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/entities/wishlist_item.dart';

/// Локальное хранилище Wishlist.
class WishlistRepository {
  final AppDatabase database;

  WishlistRepository(this.database);

  Future<List<WishlistItem>> getAll() async {
    final rows = await database.customSelect('''
      SELECT id, catalog_item_id, title, group_name, current_price,
             target_price, priority, url, comment, created_at, updated_at
      FROM wishlist_items
      ORDER BY priority ASC, group_name COLLATE NOCASE, title COLLATE NOCASE
    ''').get();

    return rows.map(_fromRow).toList();
  }

  Future<bool> contains(String catalogItemId) async {
    final rows = await database.customSelect(
      'SELECT id FROM wishlist_items WHERE catalog_item_id = ? LIMIT 1',
      variables: [Variable.withString(catalogItemId)],
    ).get();
    return rows.isNotEmpty;
  }

  Future<void> addFromCatalog({
    required String catalogItemId,
    required String title,
    required String groupName,
    int priority = 2,
  }) async {
    final now = DateTime.now();
    await database.customStatement('''
      INSERT INTO wishlist_items
        (id, catalog_item_id, title, group_name, priority, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(catalog_item_id) DO UPDATE SET
        title = excluded.title,
        group_name = excluded.group_name,
        updated_at = excluded.updated_at
    ''', [
      '${now.microsecondsSinceEpoch}_$catalogItemId',
      catalogItemId,
      title,
      groupName,
      priority,
      now.microsecondsSinceEpoch,
      now.microsecondsSinceEpoch,
    ]);
  }

  Future<int> addAll(Iterable<({String id, String title, String groupName})> items) async {
    var added = 0;
    for (final item in items) {
      final exists = await contains(item.id);
      if (exists) continue;
      await addFromCatalog(
        catalogItemId: item.id,
        title: item.title,
        groupName: item.groupName,
      );
      added++;
    }
    return added;
  }

  Future<void> delete(String id) async {
    await database.customStatement(
      'DELETE FROM wishlist_items WHERE id = ?',
      [id],
    );
  }

  WishlistItem _fromRow(QueryRow row) {
    return WishlistItem(
      id: row.read<String>('id'),
      catalogItemId: row.read<String>('catalog_item_id'),
      title: row.read<String>('title'),
      groupName: row.read<String>('group_name'),
      currentPrice: row.readNullable<double>('current_price'),
      targetPrice: row.readNullable<double>('target_price'),
      priority: row.read<int>('priority'),
      url: row.readNullable<String>('url'),
      comment: row.readNullable<String>('comment'),
      createdAt: DateTime.fromMicrosecondsSinceEpoch(row.read<int>('created_at')),
      updatedAt: DateTime.fromMicrosecondsSinceEpoch(row.read<int>('updated_at')),
    );
  }
}
