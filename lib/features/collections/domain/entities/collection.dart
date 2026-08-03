import '../../../../shared/domain/entities/auditable_entity.dart';
import '../../../fields/domain/entities/field_definition.dart';

/// Коллекция пользователя.
///
/// Коллекция создаётся на основе шаблона и содержит собственную
/// структуру полей. После создания коллекция становится независимой
/// от шаблона и может изменяться пользователем.
class Collection extends AuditableEntity {
  /// Название коллекции.
  final String name;

  /// Идентификатор шаблона, из которого была создана коллекция.
  final String? templateId;

  /// Структура полей коллекции.
  ///
  /// Например:
  /// - Страна
  /// - Год
  /// - Материал
  final List<FieldDefinition> fields;

  const Collection({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
    this.templateId,
    this.fields = const [],
  });

  Collection copyWith({
    String? name,
    String? templateId,
    List<FieldDefinition>? fields,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Collection(
      id: id,
      name: name ?? this.name,
      templateId: templateId ?? this.templateId,
      fields: fields ?? this.fields,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}