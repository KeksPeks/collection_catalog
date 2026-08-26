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
  int get schemaVersion => 8;

  Future<bool> _hasColumn(String table, String column) async {
    final rows = await customSelect('PRAGMA table_info("$table")').get();
    return rows.any((row) => row.data['name']?.toString() == column);
  }

  Future<void> _ensureColumn(String table, String column, String definition) async {
    if (!await _hasColumn(table, column)) {
      await customStatement('ALTER TABLE "$table" ADD COLUMN "$column" $definition');
    }
  }

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

  Future<void> _ensureCurrentSchema() async {
    await customStatement('CREATE TABLE IF NOT EXISTS collection_table (id TEXT PRIMARY KEY NOT NULL, name TEXT NOT NULL, template_id TEXT, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)');
    await customStatement('CREATE TABLE IF NOT EXISTS field_table (id TEXT PRIMARY KEY NOT NULL, collection_id TEXT NOT NULL, label TEXT NOT NULL, type TEXT NOT NULL)');
    await customStatement('CREATE TABLE IF NOT EXISTS collection_section_table (id TEXT PRIMARY KEY NOT NULL, collection_id TEXT NOT NULL, parent_id TEXT, name TEXT NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)');
    await _ensureColumn('collection_section_table', 'sort_order', 'INTEGER NOT NULL DEFAULT 0');
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
          // Не используем m.addColumn здесь: старые локальные базы могли
          // уже содержать sort_order при старой версии схемы.
          await _ensureColumn('collection_section_table', 'sort_order', 'INTEGER NOT NULL DEFAULT 0');
          if (from < 6) {
            await ensureCatalogItemTables();
            await ensureStorageTables();
          }
          await _ensureCurrentSchema();
        },
        beforeOpen: (details) async {
          // Проверяем фактическую SQLite-схему при каждом открытии. Это
          // исправляет базы, созданные промежуточными версиями приложения.
          await _ensureCurrentSchema();
        },
      );
}
