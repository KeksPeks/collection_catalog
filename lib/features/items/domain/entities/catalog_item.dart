import '../../../../shared/domain/entities/auditable_entity.dart';

/// Каталожный предмет.
///
/// Описывает именно модель/позицию каталога, а не физическую вещь
/// пользователя. Один CatalogItem может иметь несколько Item.
///
/// Например:
/// LEGO 75192 Millennium Falcon — один CatalogItem.
/// Экземпляры #1, #2 и #3 — отдельные Item, связанные с ним.
class CatalogItem extends AuditableEntity {
  /// Коллекция, к которой относится каталожный предмет.
  final String collectionId;

  /// Название каталожного предмета.
  final String name;

  /// Внешний идентификатор из каталога, если он есть.
  final String? externalId;

  /// URL источника каталожных данных.
  final String? sourceUrl;

  const CatalogItem({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.collectionId,
    required this.name,
    this.externalId,
    this.sourceUrl,
  });

  CatalogItem copyWith({
    String? collectionId,
    String? name,
    String? externalId,
    String? sourceUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CatalogItem(
      id: id,
      collectionId: collectionId ?? this.collectionId,
      name: name ?? this.name,
      externalId: externalId ?? this.externalId,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
