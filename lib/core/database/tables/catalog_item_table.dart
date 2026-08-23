import 'package:drift/drift.dart';

/// SQL-описание каталожных предметов.
///
/// Таблица создаётся миграцией и намеренно не регистрируется как Drift Table:
/// это позволяет внедрить связь с физическими экземплярами без изменения
/// существующего сгенерированного файла app_database.g.dart.
class CatalogItemTable extends Table {
  TextColumn get id => text()();
  TextColumn get collectionId => text()();
  TextColumn get name => text()();
  TextColumn get externalId => text().nullable()();
  TextColumn get sourceUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
