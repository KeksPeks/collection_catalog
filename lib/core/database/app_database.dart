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
  int get schemaVersion => 6;

  /// Создаёт дополнительные таблицы каталожных позиций и мест хранения.
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
          if (from < 5) {
            await m.addColumn(collectionSectionTable, collectionSectionTable.sortOrder);
          }
          if (from < 6) {
            // Важно: пользователи с уже существующей схемой 5 тоже должны
            // получить таблицы каталожных позиций и мест хранения.
            await ensureCatalogItemTables();
            await ensureStorageTables();
          }
        },
      );
}
