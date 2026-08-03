import '../../../../shared/domain/entities/auditable_entity.dart';

/// Предмет коллекции.
///
/// Представляет собой экземпляр объекта коллекции.
/// Сам предмет не хранит значения пользовательских полей.
/// Они находятся в сущностях ItemValue.
///
/// Примеры:
/// - монета;
/// - банкнота;
/// - карточка Pokémon;
/// - книга;
/// - фигурка.
class Item extends AuditableEntity {
  /// Коллекция, которой принадлежит предмет.
  final String collectionId;

  /// Раздел коллекции.
  ///
  /// Может быть null, если предмет находится в корне.
  final String? sectionId;

  /// Порядок отображения внутри раздела.
  final int sortOrder;

  const Item({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.collectionId,
    this.sectionId,
    this.sortOrder = 0,
  });

  Item copyWith({
    String? collectionId,
    String? sectionId,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id,
      collectionId: collectionId ?? this.collectionId,
      sectionId: sectionId ?? this.sectionId,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}