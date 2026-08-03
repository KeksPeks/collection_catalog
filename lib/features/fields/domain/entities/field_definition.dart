import '../types/field_type.dart';

/// Описание поля коллекции.
class FieldDefinition {
  final String id;
  final String collectionId;
  final String label;
  final FieldType type;

  const FieldDefinition({
    required this.id,
    required this.collectionId,
    required this.label,
    required this.type,
  });

  FieldDefinition copyWith({
    String? id,
    String? collectionId,
    String? label,
    FieldType? type,
  }) {
    return FieldDefinition(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      label: label ?? this.label,
      type: type ?? this.type,
    );
  }
}