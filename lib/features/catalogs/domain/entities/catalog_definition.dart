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

  /// Общее число записей в серверном каталоге.
  ///
  /// Пока серверный источник не подключён, значение равно null и интерфейс
  /// показывает «—», не подменяя реальные данные вымышленным числом.
  final int? totalItems;
  final List<CatalogSectionDefinition> sections;

  const CatalogDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.templateId,
    required this.template,
    this.totalItems,
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
