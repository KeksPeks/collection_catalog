import '../../templates/data/catalog_template_registry.dart';
import '../../templates/domain/entities/template.dart';
import '../domain/entities/catalog_definition.dart';

/// Реестр готовых каталогов приложения.
///
/// Сейчас структура поставляется вместе с приложением. Позже этот же
/// интерфейс можно подключить к серверному каталогу без изменения UI.
class CatalogRegistry {
  static List<CatalogDefinition> get all {
    final templates = CatalogTemplateRegistry.all;

    return [
      _coins(templates),
      _simple(templates, 'banknotes'),
      _simple(templates, 'pokemon_tcg'),
      _simple(templates, 'discs'),
      _simple(templates, 'games'),
      _simple(templates, 'movies'),
      _simple(templates, 'figurines'),
    ];
  }

  static CatalogDefinition? byId(String id) {
    for (final catalog in all) {
      if (catalog.id == id) return catalog;
    }
    return null;
  }

  static CatalogDefinition _coins(List<Template> templates) {
    final template = templates.firstWhere((item) => item.id == 'coins');
    return CatalogDefinition(
      id: 'coins',
      name: 'Монеты',
      description: 'Каталог монет с разбивкой по странам и типу чеканки.',
      templateId: template.id,
      template: template,
      sections: const [
        CatalogSectionDefinition(
          id: 'countries',
          name: 'Страны',
          children: [
            CatalogSectionDefinition(
              id: 'commemorative',
              name: 'Юбилейные',
            ),
            CatalogSectionDefinition(
              id: 'regular',
              name: 'Регулярный чекан',
            ),
            CatalogSectionDefinition(
              id: 'precious',
              name: 'Драгоценные металлы',
            ),
          ],
        ),
      ],
    );
  }

  static CatalogDefinition _simple(
    List<Template> templates,
    String templateId,
  ) {
    final template = templates.firstWhere((item) => item.id == templateId);
    return CatalogDefinition(
      id: template.id,
      name: template.name,
      description: template.description,
      templateId: template.id,
      template: template,
    );
  }
}
