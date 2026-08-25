import 'package:drift/drift.dart';

import 'tables/collection_table.dart';
import 'tables/field_table.dart';
import 'tables/collection_section_table.dart';
import 'tables/item_table.dart';
import 'tables/item_value_table.dart';
import 'tables/item_attachment_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    CollectionTable,
    FieldTable,
    CollectionSectionTable,
    ItemTable,
    ItemValueTable,
    ItemAttachmentTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 7;

  Future<void> ensureStorageTables() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS storage_location_table (
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL,
        parent_id TEXT,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS item_storage_location_table (
        item_id TEXT PRIMARY KEY NOT NULL,
        location_id TEXT NOT NULL
      )
    ''');
  }

  Future<void> ensureCatalogItemTables() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS catalog_items (
        id TEXT PRIMARY KEY NOT NULL,
        collection_id TEXT NOT NULL,
        name TEXT NOT NULL,
        external_id TEXT,
        source_url TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS item_catalog_links (
        item_id TEXT PRIMARY KEY NOT NULL,
        catalog_item_id TEXT NOT NULL
      )
    ''');
  }

  Future<bool> _hasColumn(String tableName, String columnName) async {
    final rows = await customSelect('PRAGMA table_info("$tableName")').get();
    return rows.any((row) => row.data['name'] == columnName);
  }

  Future<void> _ensureCurrentSchema() async {
    // Восстанавливаем отсутствующие таблицы в старых локальных базах.
    await customStatement('CREATE TABLE IF NOT EXISTS collection_table (id TEXT PRIMARY KEY NOT NULL, name TEXT NOT NULL, template_id TEXT, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)');
    await customStatement('CREATE TABLE IF NOT EXISTS field_table (id TEXT PRIMARY KEY NOT NULL, collection_id TEXT NOT NULL, label TEXT NOT NULL, type TEXT NOT NULL)');
    await customStatement('CREATE TABLE IF NOT EXISTS collection_section_table (id TEXT PRIMARY KEY NOT NULL, collection_id TEXT NOT NULL, parent_id TEXT, name TEXT NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, sort_order INTEGER NOT NULL DEFAULT 0)');
    await customStatement('CREATE TABLE IF NOT EXISTS item_table (id TEXT PRIMARY KEY NOT NULL, collection_id TEXT NOT NULL, section_id TEXT, sort_order INTEGER NOT NULL DEFAULT 0, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)');
    await customStatement('CREATE TABLE IF NOT EXISTS item_value_table (id TEXT PRIMARY KEY NOT NULL, item_id TEXT NOT NULL, field_id TEXT NOT NULL, value TEXT NOT NULL)');
    await customStatement('CREATE TABLE IF NOT EXISTS item_attachment_table (id TEXT PRIMARY KEY NOT NULL, item_id TEXT NOT NULL, path TEXT NOT NULL, type TEXT NOT NULL)');
    await ensureCatalogItemTables();
    await ensureStorageTables();
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await ensureCatalogItemTables();
          await ensureStorageTables();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) await m.createTable(collectionTable);
          if (from < 3) await m.createTable(collectionSectionTable);
          if (from < 4) {
            await m.createTable(itemTable);
            await m.createTable(itemValueTable);
            await m.createTable(itemAttachmentTable);
          }
          if (from < 5 && !await _hasColumn('collection_section_table', 'sort_order')) {
            await m.addColumn(collectionSectionTable, collectionSectionTable.sortOrder);
          }
          if (from < 6) {
            await ensureCatalogItemTables();
            await ensureStorageTables();
          }
          if (from < 7) await _ensureCurrentSchema();
        },
        beforeOpen: (details) async {
          if (!details.wasCreated && !details.hadUpgrade) await _ensureCurrentSchema();
        },
      );
}
