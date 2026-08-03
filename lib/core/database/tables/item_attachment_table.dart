import 'package:drift/drift.dart';

/// Таблица файлов предметов.
class ItemAttachmentTable extends Table {
  /// Идентификатор файла.
  TextColumn get id => text()();

  /// Идентификатор предмета.
  TextColumn get itemId => text()();

  /// Путь к файлу.
  TextColumn get path => text()();

  /// Тип файла.
  ///
  /// Например:
  /// - image
  /// - pdf
  /// - video
  /// - audio
  /// - archive
  TextColumn get type => text()();

  @override
  Set<Column> get primaryKey => {
        id,
      };
}