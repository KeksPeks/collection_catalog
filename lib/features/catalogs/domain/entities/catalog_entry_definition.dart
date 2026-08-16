/// Универсальная демонстрационная запись каталога.
///
/// Реальный серверный источник сможет поставлять записи в этом же формате.
class CatalogEntryDefinition {
  final String id;
  final String title;
  final String primaryValue;
  final String subtitle;
  final Map<String, String> attributes;

  const CatalogEntryDefinition({
    required this.id,
    required this.title,
    required this.primaryValue,
    required this.subtitle,
    this.attributes = const {},
  });
}
