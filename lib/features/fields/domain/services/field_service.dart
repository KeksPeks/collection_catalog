import '../entities/field_definition.dart';
import '../repositories/field_repository.dart';

class FieldService {
  final FieldRepository repository;

  FieldService(
    this.repository,
  );

  Future<List<FieldDefinition>> getFields(
    String collectionId,
  ) {
    return repository.getFields(
      collectionId,
    );
  }

  Future<void> addField(
    FieldDefinition field,
  ) {
    return repository.saveField(
      field,
    );
  }

  Future<void> updateField(
    FieldDefinition field,
  ) {
    return repository.updateField(
      field,
    );
  }

  Future<void> deleteField(
    String id,
  ) {
    return repository.deleteField(
      id,
    );
  }
}