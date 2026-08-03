import '../../../../shared/domain/entities/auditable_entity.dart';

/// Раздел внутри коллекции.
///
/// Разделы позволяют создавать вложенную структуру:
/// Коллекция
/// ├── Раздел
/// │   ├── Подраздел
/// │   └── Подраздел
class CollectionSection extends AuditableEntity {
  /// Коллекция, которой принадлежит раздел.
  final String collectionId;

  /// Родительский раздел.
  /// null означает корневой раздел.
  final String? parentId;

  /// Название раздела.
  final String name;

  /// Порядок отображения.
  final int sortOrder;

  const CollectionSection({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.collectionId,
    this.parentId,
    required this.name,
    this.sortOrder = 0,
  });

  CollectionSection copyWith({
    String? collectionId,
    String? parentId,
    String? name,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CollectionSection(
      id: id,
      collectionId: collectionId ?? this.collectionId,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}