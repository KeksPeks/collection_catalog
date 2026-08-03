import '../entities/field_definition.dart';

abstract class FieldRepository {
  /// Получить все поля коллекции.
  Future<List<FieldDefinition>> getFields(
    String collectionId,
  );

  /// Получить поле по id.
  Future<FieldDefinition?> getField(
    String id,
  );

  /// Сохранить новое поле.
  Future<void> saveField(
    FieldDefinition field,
  );

  /// Обновить поле.
  Future<void> updateField(
    FieldDefinition field,
  );

  /// Удалить поле.
  Future<void> deleteField(
    String id,
  );
}