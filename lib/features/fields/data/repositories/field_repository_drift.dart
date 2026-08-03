import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';

import '../../domain/entities/field_definition.dart';
import '../../domain/types/field_type.dart';
import '../../domain/repositories/field_repository.dart';

/// Репозиторий полей на базе Drift.
class FieldRepositoryDrift implements FieldRepository {
  final AppDatabase database;

  FieldRepositoryDrift(
    this.database,
  );

  /// Получить все поля коллекции.
  @override
  Future<List<FieldDefinition>> getFields(
    String collectionId,
  ) async {
    final rows =
        await (database.select(database.fieldTable)
              ..where(
                (t) => t.collectionId.equals(collectionId),
              ))
            .get();

    return rows
        .map(
          _fromRow,
        )
        .toList();
  }

  /// Получить поле по id.
  @override
  Future<FieldDefinition?> getField(
    String id,
  ) async {
    final row =
        await (database.select(database.fieldTable)
              ..where(
                (t) => t.id.equals(id),
              ))
            .getSingleOrNull();

    if (row == null) {
      return null;
    }

    return _fromRow(row);
  }

  /// Сохранить поле.
  @override
  Future<void> saveField(
    FieldDefinition field,
  ) async {
    await database.into(database.fieldTable).insert(
          FieldTableCompanion.insert(
            id: field.id,
            collectionId: field.collectionId,
            label: field.label,
            type: field.type.name,
          ),
        );
  }

  /// Обновить поле.
  @override
  Future<void> updateField(
    FieldDefinition field,
  ) async {
    await (database.update(database.fieldTable)
          ..where(
            (t) => t.id.equals(field.id),
          ))
        .write(
      FieldTableCompanion(
        collectionId: Value(field.collectionId),
        label: Value(field.label),
        type: Value(field.type.name),
      ),
    );
  }

  /// Удалить поле.
  @override
  Future<void> deleteField(
    String id,
  ) async {
    await (database.delete(database.fieldTable)
          ..where(
            (t) => t.id.equals(id),
          ))
        .go();
  }

  /// Преобразование записи Drift в доменную модель.
  FieldDefinition _fromRow(
    FieldTableData row,
  ) {
    return FieldDefinition(
      id: row.id,
      collectionId: row.collectionId,
      label: row.label,
      type: FieldType.values.firstWhere(
        (e) => e.name == row.type,
        orElse: () => FieldType.text,
      ),
    );
  }
}