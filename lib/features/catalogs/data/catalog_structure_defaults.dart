import '../domain/entities/catalog_definition.dart';
import '../domain/entities/catalog_entry_definition.dart';
import 'catalog_sample_entries.dart';
import 'catalog_section_defaults.dart';

/// Нормализует каталог перед показом и загрузкой на устройство.
/// Пустые демонстрационные направления получают разделы и шесть образцов
/// первого уровня, а Pokémon TCG — базовый набор карточек.
class CatalogStructureDefaults {
  static CatalogDefinition apply(CatalogDefinition catalog) {
    final sections = catalog.sections.isNotEmpty
        ? catalog.sections
        : CatalogSectionDefaults.forCatalog(catalog.id);

    if (catalog.id != 'pokemon_tcg') {
      final entries = catalog.entries.isNotEmpty
          ? catalog.entries
          : CatalogSampleEntries.forCatalog(catalog.id);
      return CatalogDefinition(
        id: catalog.id,
        name: catalog.name,
        description: catalog.description,
        templateId: catalog.templateId,
        template: catalog.template,
        totalItems: catalog.entries.isNotEmpty
            ? (catalog.totalItems ?? catalog.entries.length)
            : entries.length,
        sections: sections,
        primaryField: catalog.primaryField,
        entries: entries,
        version: catalog.version,
        publishedAt: catalog.publishedAt,
        changes: catalog.entries.isNotEmpty
            ? catalog.changes
            : [...catalog.changes, 'Добавлены шесть демонстрационных записей первого уровня.'],
      );
    }

    final entries = catalog.entries.isNotEmpty ? catalog.entries : _pokemonEntries;
    return CatalogDefinition(
      id: catalog.id,
      name: catalog.name,
      description: catalog.description,
      templateId: catalog.templateId,
      template: catalog.template,
      totalItems: entries.length,
      sections: sections,
      primaryField: catalog.primaryField,
      entries: entries,
      version: catalog.version,
      publishedAt: catalog.publishedAt,
      changes: [...catalog.changes, 'Добавлен базовый набор карточек Pokémon TCG для локальной коллекции.'],
    );
  }

  static const _pokemonEntries = <CatalogEntryDefinition>[
    CatalogEntryDefinition(id: 'pokemon-001', title: 'Pikachu', primaryValue: 'Scarlet & Violet', subtitle: 'Common • Basic', attributes: {'Серия': 'Scarlet & Violet', 'Редкость': 'Обычная', 'Тип карты': 'Покемон', 'Покемон': 'Pikachu'}),
    CatalogEntryDefinition(id: 'pokemon-002', title: 'Charizard', primaryValue: 'Scarlet & Violet', subtitle: 'Rare • Basic', attributes: {'Серия': 'Scarlet & Violet', 'Редкость': 'Редкая', 'Тип карты': 'Покемон', 'Покемон': 'Charizard'}),
    CatalogEntryDefinition(id: 'pokemon-003', title: 'Bulbasaur', primaryValue: 'Scarlet & Violet', subtitle: 'Common • Basic', attributes: {'Серия': 'Scarlet & Violet', 'Редкость': 'Обычная', 'Тип карты': 'Покемон', 'Покемон': 'Bulbasaur'}),
    CatalogEntryDefinition(id: 'pokemon-004', title: 'Squirtle', primaryValue: 'Scarlet & Violet', subtitle: 'Common • Basic', attributes: {'Серия': 'Scarlet & Violet', 'Редкость': 'Обычная', 'Тип карты': 'Покемон', 'Покемон': 'Squirtle'}),
    CatalogEntryDefinition(id: 'pokemon-005', title: 'Mew ex', primaryValue: 'Scarlet & Violet', subtitle: 'Ultra Rare • Basic', attributes: {'Серия': 'Scarlet & Violet', 'Редкость': 'Ультраредкая', 'Тип карты': 'Покемон', 'Покемон': 'Mew'}),
    CatalogEntryDefinition(id: 'pokemon-006', title: 'Gardevoir ex', primaryValue: 'Scarlet & Violet', subtitle: 'Rare • Stage 2', attributes: {'Серия': 'Scarlet & Violet', 'Редкость': 'Редкая', 'Тип карты': 'Покемон', 'Покемон': 'Gardevoir'}),
    CatalogEntryDefinition(id: 'pokemon-007', title: 'Eevee', primaryValue: 'Sword & Shield', subtitle: 'Common • Basic', attributes: {'Серия': 'Sword & Shield', 'Редкость': 'Обычная', 'Тип карты': 'Покемон', 'Покемон': 'Eevee'}),
    CatalogEntryDefinition(id: 'pokemon-008', title: 'Umbreon V', primaryValue: 'Sword & Shield', subtitle: 'Ultra Rare • Basic', attributes: {'Серия': 'Sword & Shield', 'Редкость': 'Ультраредкая', 'Тип карты': 'Покемон', 'Покемон': 'Umbreon'}),
    CatalogEntryDefinition(id: 'pokemon-009', title: 'Professor’s Research', primaryValue: 'Scarlet & Violet', subtitle: 'Trainer • Supporter', attributes: {'Серия': 'Scarlet & Violet', 'Редкость': 'Обычная', 'Тип карты': 'Тренер', 'Покемон': ''}),
    CatalogEntryDefinition(id: 'pokemon-010', title: 'Nest Ball', primaryValue: 'Scarlet & Violet', subtitle: 'Trainer • Item', attributes: {'Серия': 'Scarlet & Violet', 'Редкость': 'Обычная', 'Тип карты': 'Тренер', 'Покемон': ''}),
    CatalogEntryDefinition(id: 'pokemon-011', title: 'Fire Energy', primaryValue: 'Scarlet & Violet', subtitle: 'Energy • Basic', attributes: {'Серия': 'Scarlet & Violet', 'Редкость': 'Обычная', 'Тип карты': 'Энергия', 'Покемон': ''}),
    CatalogEntryDefinition(id: 'pokemon-012', title: 'Lightning Energy', primaryValue: 'Scarlet & Violet', subtitle: 'Energy • Basic', attributes: {'Серия': 'Scarlet & Violet', 'Редкость': 'Обычная', 'Тип карты': 'Энергия', 'Покемон': ''}),
  ];
}
