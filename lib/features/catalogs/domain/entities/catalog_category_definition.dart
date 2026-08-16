/// Верхнеуровневая категория каталогов.
class CatalogCategoryDefinition {
  final String id;
  final String name;
  final String description;
  final List<String> catalogIds;

  const CatalogCategoryDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.catalogIds,
  });
}
