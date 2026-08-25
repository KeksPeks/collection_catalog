/// Универсальная демонстрационная запись каталога.
///
/// Реальный серверный источник сможет поставлять записи в этом же формате.
class CatalogEntryDefinition {
  final String id;
  final String title;
  final String primaryValue;
  final String subtitle;
  final Map<String, String> attributes;

  /// Иерархический путь раздела внутри каталога.
  /// Например: countries -> russia -> regular.
  final List<String> sectionPath;

  /// URL изображения карточки. Если его нет, интерфейс показывает NO IMAGES.
  final String? imageUrl;

  /// Код страны ISO 3166-1 alpha-2 для отображения флага.
  /// Если не задан, код определяется по полю «Страна».
  final String? countryCode;

  const CatalogEntryDefinition({
    required this.id,
    required this.title,
    required this.primaryValue,
    required this.subtitle,
    this.attributes = const {},
    this.sectionPath = const [],
    this.imageUrl,
    this.countryCode,
  });
}
