import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/storage_location.dart';
import '../../domain/repositories/storage_location_repository.dart';

class StorageLocationRepositoryDrift implements StorageLocationRepository {
  final AppDatabase database;
  StorageLocationRepositoryDrift(this.database);

  Future<void> _ensure() => database.ensureStorageTables();

  StorageLocation _fromRow(Map<String, Object?> row) => StorageLocation(
        id: row['id']! as String,
        name: row['name']! as String,
        parentId: row['parent_id'] as String?,
        sortOrder: row['sort_order']! as int,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at']! as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at']! as int),
      );

  @override
  Future<List<StorageLocation>> getAll() async {
    await _ensure();
    final rows = await database.customSelect('SELECT * FROM storage_location_table ORDER BY parent_id, sort_order, name').get();
    return rows.map((r) => _fromRow(r.data)).toList();
  }

  @override
  Future<List<StorageLocation>> getChildren(String? parentId) async {
    await _ensure();
    final rows = await database.customSelect(parentId == null ? 'SELECT * FROM storage_location_table WHERE parent_id IS NULL ORDER BY sort_order, name' : 'SELECT * FROM storage_location_table WHERE parent_id = ? ORDER BY sort_order, name', variables: parentId == null ? [] : [Variable.withString(parentId)]).get();
    return rows.map((r) => _fromRow(r.data)).toList();
  }

  @override
  Future<StorageLocation?> getById(String id) async {
    await _ensure();
    final rows = await database.customSelect('SELECT * FROM storage_location_table WHERE id = ?', variables: [Variable.withString(id)]).get();
    return rows.isEmpty ? null : _fromRow(rows.first.data);
  }

  @override
  Future<String> getPath(String id) async {
    await _ensure();
    final all = await getAll();
    final byId = {for (final location in all) location.id: location};
    final parts = <String>[];
    var current = byId[id];
    final visited = <String>{};
    while (current != null && visited.add(current.id)) {
      parts.insert(0, current.name);
      current = current.parentId == null ? null : byId[current.parentId];
    }
    return parts.join(' → ');
  }

  @override
  Future<void> save(StorageLocation location) async {
    await _ensure();
    await database.customStatement('''INSERT INTO storage_location_table(id,name,parent_id,sort_order,created_at,updated_at)
      VALUES(?,?,?,?,?,?) ON CONFLICT(id) DO UPDATE SET name=excluded.name,parent_id=excluded.parent_id,
      sort_order=excluded.sort_order,updated_at=excluded.updated_at''', [location.id, location.name, location.parentId, location.sortOrder, location.createdAt.millisecondsSinceEpoch, location.updatedAt.millisecondsSinceEpoch]);
  }

  @override
  Future<void> delete(String id) async {
    await _ensure();
    if ((await getChildren(id)).isNotEmpty) throw StateError('Нельзя удалить место, пока в нём есть вложенные места.');
    await database.customStatement('DELETE FROM item_storage_location_table WHERE location_id = ?', [id]);
    await database.customStatement('DELETE FROM storage_location_table WHERE id = ?', [id]);
  }

  @override
  Future<void> assignItem(String itemId, String locationId) async {
    await _ensure();
    await database.customStatement('''INSERT INTO item_storage_location_table(item_id,location_id) VALUES(?,?)
      ON CONFLICT(item_id) DO UPDATE SET location_id=excluded.location_id''', [itemId, locationId]);
  }

  @override
  Future<void> removeItem(String itemId) async {
    await _ensure();
    await database.customStatement('DELETE FROM item_storage_location_table WHERE item_id = ?', [itemId]);
  }

  @override
  Future<StorageLocation?> getItemLocation(String itemId) async {
    await _ensure();
    final rows = await database.customSelect('''SELECT s.* FROM storage_location_table s
      INNER JOIN item_storage_location_table l ON l.location_id = s.id WHERE l.item_id = ?''', variables: [Variable.withString(itemId)]).get();
    return rows.isEmpty ? null : _fromRow(rows.first.data);
  }
}
