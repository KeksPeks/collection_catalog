import 'package:drift/drift.dart';

/// Таблица предметов коллекции.
class ItemTable extends Table {
  /// Идентификатор предмета.
  TextColumn get id => text()();

  /// Коллекция, которой принадлежит предмет.
  TextColumn get collectionId => text()();

  /// Раздел коллекции.
  TextColumn get sectionId => text().nullable()();

  /// Порядок отображения.
  IntColumn get sortOrder => integer().withDefault(
        const Constant(0),
      )();

  /// Дата создания.
  DateTimeColumn get createdAt => dateTime()();

  /// Дата последнего изменения.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {
        id,
      };
}