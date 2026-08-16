import '../../../templates/domain/entities/template.dart';
import 'catalog_entry_definition.dart';

/// Универсальное описание готового каталога.
class CatalogDefinition {
  final String id;
  final String name;
  final String description;
  final String templateId;
  final Template template;
  final int? totalItems;
  final List<CatalogSectionDefinition> sections;

  /// Поле, по которому записи открываются по умолчанию.
  final String primaryField;

  /// Демонстрационные записи. Сервер сможет заменить их реальными данными.
  final List<CatalogEntryDefinition> entries;

  const CatalogDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.templateId,
    required this.template,
    this.totalItems,
    this.sections = const [],
    this.primaryField = '',
    this.entries = const [],
  });
}

class CatalogSectionDefinition {
  final String id;
  final String name;
  final List<CatalogSectionDefinition> children;

  const CatalogSectionDefinition({
    required this.id,
    required this.name,
    this.children = const [],
  });
}
