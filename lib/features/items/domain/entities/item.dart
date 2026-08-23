import '../../../../shared/domain/entities/auditable_entity.dart';

/// Физический экземпляр предмета коллекции.
///
/// Важно: Item не является каталожной позицией.
/// Один CatalogItem может иметь несколько Item.
class Item extends AuditableEntity {
  /// Идентификатор каталожного предмета.
  final String? catalogItemId;

  /// Коллекция, которой принадлежит экземпляр.
  final String collectionId;

  /// Раздел коллекции.
  final String? sectionId;

  /// Порядок отображения внутри раздела.
  final int sortOrder;

  const Item({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.collectionId,
    this.catalogItemId,
    this.sectionId,
    this.sortOrder = 0,
  });

  Item copyWith({
    String? catalogItemId,
    String? collectionId,
    String? sectionId,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id,
      catalogItemId: catalogItemId ?? this.catalogItemId,
      collectionId: collectionId ?? this.collectionId,
      sectionId: sectionId ?? this.sectionId,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
