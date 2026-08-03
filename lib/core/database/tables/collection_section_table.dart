import 'package:drift/drift.dart';

/// Таблица разделов коллекции.
class CollectionSectionTable extends Table {
  /// Идентификатор раздела.
  TextColumn get id => text()();

  /// Коллекция, которой принадлежит раздел.
  TextColumn get collectionId => text()();

  /// Родительский раздел.
  TextColumn get parentId => text().nullable()();

  /// Название раздела.
  TextColumn get name => text()();

  /// Дата создания.
  DateTimeColumn get createdAt => dateTime()();

  /// Дата обновления.
  DateTimeColumn get updatedAt => dateTime()();

  /// Порядок отображения.
  IntColumn get sortOrder => integer().withDefault(
        const Constant(0),
      )();

  @override
  Set<Column> get primaryKey => {
        id,
      };
}