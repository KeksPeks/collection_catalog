import 'entity.dart';

/// Базовая сущность с датами создания и изменения.
abstract class AuditableEntity extends Entity {
  /// Дата создания.
  final DateTime createdAt;

  /// Дата последнего изменения.
  final DateTime updatedAt;

  const AuditableEntity({
    required super.id,
    required this.createdAt,
    required this.updatedAt,
  });
}