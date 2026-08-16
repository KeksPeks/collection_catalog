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
  AppDatabase(
    super.executor,
  );

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(
              collectionTable,
            );
          }

          if (from < 3) {
            await m.createTable(
              collectionSectionTable,
            );
          }

          if (from < 4) {
            await m.createTable(
              itemTable,
            );

            await m.createTable(
              itemValueTable,
            );

            await m.createTable(
              itemAttachmentTable,
            );
          }

          if (from < 5) {
            await m.addColumn(
              collectionSectionTable,
              collectionSectionTable.sortOrder,
            );
          }
        },
      );
}