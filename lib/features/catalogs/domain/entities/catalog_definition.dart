import '../../../templates/domain/entities/template.dart';

/// Описание готового каталога, доступного пользователю.
///
/// Каталог является источником структуры и может быть просмотрен онлайн
/// или загружен в локальное хранилище телефона.
class CatalogDefinition {
  final String id;
  final String name;
  final String description;
  final String templateId;
  final Template template;
  final List<CatalogSectionDefinition> sections;

  const CatalogDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.templateId,
    required this.template,
    this.sections = const [],
  });
}

/// Раздел готового каталога.
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
