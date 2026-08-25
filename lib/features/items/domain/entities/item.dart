import '../../../../shared/domain/entities/auditable_entity.dart';

/// Предмет коллекции.
///
/// Представляет собой физический экземпляр объекта коллекции.
/// Сам предмет не хранит значения пользовательских полей.
/// Они находятся в сущностях ItemValue.
class Item extends AuditableEntity {
  /// Каталожная позиция, которой соответствует физический экземпляр.
  final String? catalogItemId;

  /// Коллекция, которой принадлежит предмет.
  final String collectionId;

  /// Раздел коллекции. Может быть null, если предмет находится в корне.
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
