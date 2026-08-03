import '../../domain/entities/field_definition.dart';
import '../../domain/repositories/field_repository.dart';

/// Временный репозиторий в памяти.
/// Используется только пока не удалим Memory-реализацию полностью.
class FieldRepositoryMemory implements FieldRepository {
  final List<FieldDefinition> _fields = [];

  @override
  Future<List<FieldDefinition>> getFields(
    String collectionId,
  ) async {
    return _fields
        .where(
          (field) => field.collectionId == collectionId,
        )
        .toList();
  }

  @override
  Future<FieldDefinition?> getField(
    String id,
  ) async {
    try {
      return _fields.firstWhere(
        (field) => field.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveField(
    FieldDefinition field,
  ) async {
    _fields.add(field);
  }

  @override
  Future<void> updateField(
    FieldDefinition field,
  ) async {
    final index = _fields.indexWhere(
      (e) => e.id == field.id,
    );

    if (index == -1) {
      return;
    }

    _fields[index] = field;
  }

  @override
  Future<void> deleteField(
    String id,
  ) async {
    _fields.removeWhere(
      (field) => field.id == id,
    );
  }
}