/// Модель элемента каталога.
class CatalogItemModel {
  /// Уникальный идентификатор.
  final String id;

  /// Название.
  final String title;

  /// Описание.
  final String description;

  /// Платформа.
  final String platform;

  /// Жанр.
  final String genre;

  /// Разработчик.
  final String developer;

  /// Издатель.
  final String publisher;

  /// Год выпуска.
  final int year;

  /// Ссылка на изображение.
  final String? imageUrl;

  /// Есть ли в коллекции.
  final bool isOwned;

  const CatalogItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.platform,
    required this.genre,
    required this.developer,
    required this.publisher,
    required this.year,
    this.imageUrl,
    this.isOwned = false,
  });
}