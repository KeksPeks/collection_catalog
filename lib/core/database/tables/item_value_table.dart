import 'package:drift/drift.dart';

/// Таблица значений полей предметов.
class ItemValueTable extends Table {
  /// Идентификатор значения.
  TextColumn get id => text()();

  /// Идентификатор предмета.
  TextColumn get itemId => text()();

  /// Идентификатор поля.
  TextColumn get fieldId => text()();

  /// Значение поля.
  ///
  /// Хранится в строковом виде.
  /// Для чисел, дат, логических значений и ссылок используется
  /// строковое представление. Тип определяется FieldDefinition.
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {
        id,
      };
}