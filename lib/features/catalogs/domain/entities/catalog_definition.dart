import '../../../templates/domain/entities/template.dart';
import 'catalog_entry_definition.dart';

class CatalogDefinition {
  final String id;
  final String name;
  final String description;
  final String templateId;
  final Template template;
  final int? totalItems;
  final List<CatalogSectionDefinition> sections;
  final String primaryField;
  final List<CatalogEntryDefinition> entries;
  final int version;
  final DateTime? publishedAt;
  final List<String> changes;
  const CatalogDefinition({required this.id, required this.name, required this.description, required this.templateId, required this.template, this.totalItems, this.sections = const [], this.primaryField = '', this.entries = const [], this.version = 1, this.publishedAt, this.changes = const []});
}

class CatalogSectionDefinition {
  final String id;
  final String name;
  final List<CatalogSectionDefinition> children;
  const CatalogSectionDefinition({required this.id, required this.name, this.children = const []});
}
