import 'package:drift/drift.dart';

/// Связь физического экземпляра с местом хранения.
class ItemStorageLocationTable extends Table {
  TextColumn get itemId => text()();
  TextColumn get locationId => text()();

  @override
  Set<Column> get primaryKey => {itemId};
}
