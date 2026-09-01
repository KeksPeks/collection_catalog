import '../domain/entities/catalog_definition.dart';
import '../domain/entities/catalog_entry_definition.dart';
import 'catalog_sample_entries.dart';
import 'catalog_section_defaults.dart';

/// Нормализует каталог перед показом и загрузкой на устройство.
class CatalogStructureDefaults {
  static CatalogDefinition apply(CatalogDefinition catalog) {
    final sections = catalog.sections.isNotEmpty ? catalog.sections : CatalogSectionDefaults.forCatalog(catalog.id);
    final entries = switch (catalog.id) {
      'lego' => _constructorEntries,
      'pokemon_tcg' => catalog.entries.isNotEmpty ? catalog.entries : _pokemonEntries,
      _ => catalog.entries.isNotEmpty ? catalog.entries : CatalogSampleEntries.forCatalog(catalog.id),
    };

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
      changes: catalog.id == 'pokemon_tcg'
          ? [...catalog.changes, 'Добавлен базовый набор карточек Pokémon TCG для локальной коллекции.']
          : catalog.changes,
    );
  }

  static const _constructorEntries = <CatalogEntryDefinition>[
    CatalogEntryDefinition(id: 'constructor-001', title: 'LEGO City Пожарная станция', primaryValue: 'LEGO', subtitle: 'City • 60414 • 2025', attributes: {'Производитель': 'LEGO', 'Серия': 'City', 'Категория': 'Здания', 'Модель': '60414', 'Год': '2025'}, sectionPath: ['manufacturers', 'lego', 'city', 'buildings']),
    CatalogEntryDefinition(id: 'constructor-002', title: 'LEGO Technic Ferrari SF-24', primaryValue: 'LEGO', subtitle: 'Technic • 42207 • 2025', attributes: {'Производитель': 'LEGO', 'Серия': 'Technic', 'Категория': 'Техника', 'Модель': '42207', 'Год': '2025'}, sectionPath: ['manufacturers', 'lego', 'technic', 'vehicles']),
    CatalogEntryDefinition(id: 'constructor-003', title: 'LEGO Icons Букет цветов', primaryValue: 'LEGO', subtitle: 'Icons • 10280 • 2021', attributes: {'Производитель': 'LEGO', 'Серия': 'Icons', 'Категория': 'Декор', 'Модель': '10280', 'Год': '2021'}, sectionPath: ['manufacturers', 'lego', 'icons', 'decor']),
    CatalogEntryDefinition(id: 'constructor-004', title: 'LEGO Star Wars Millennium Falcon', primaryValue: 'LEGO', subtitle: 'Star Wars • 75375 • 2024', attributes: {'Производитель': 'LEGO', 'Серия': 'Star Wars', 'Категория': 'Транспорт', 'Модель': '75375', 'Год': '2024'}, sectionPath: ['manufacturers', 'lego', 'city', 'vehicles']),
    CatalogEntryDefinition(id: 'constructor-005', title: 'COBI Tiger 131', primaryValue: 'COBI', subtitle: 'Historical Collection • 131 • 2024', attributes: {'Производитель': 'COBI', 'Серия': 'Historical Collection', 'Категория': 'Военная техника', 'Модель': '131', 'Год': '2024'}, sectionPath: ['manufacturers', 'cobi', 'military']),
    CatalogEntryDefinition(id: 'constructor-006', title: 'COBI Ford Mustang', primaryValue: 'COBI', subtitle: 'Youngtimer Collection • 24334 • 2023', attributes: {'Производитель': 'COBI', 'Серия': 'Youngtimer Collection', 'Категория': 'Транспорт', 'Модель': '24334', 'Год': '2023'}, sectionPath: ['manufacturers', 'cobi', 'vehicles']),
    CatalogEntryDefinition(id: 'constructor-007', title: 'CaDA Ferrari Daytona SP3', primaryValue: 'CaDA', subtitle: 'Master • C61042W • 2024', attributes: {'Производитель': 'CaDA', 'Серия': 'Master', 'Категория': 'Автомобили', 'Модель': 'C61042W', 'Год': '2024'}, sectionPath: ['manufacturers', 'cada', 'cars']),
    CatalogEntryDefinition(id: 'constructor-008', title: 'CaDA Japanese Sports Car', primaryValue: 'CaDA', subtitle: 'Technic • C61073W • 2023', attributes: {'Производитель': 'CaDA', 'Серия': 'Technic', 'Категория': 'Автомобили', 'Модель': 'C61073W', 'Год': '2023'}, sectionPath: ['manufacturers', 'cada', 'technic']),
    CatalogEntryDefinition(id: 'constructor-009', title: 'BlueBrixx Orient Express', primaryValue: 'BlueBrixx', subtitle: 'Trains • 104965 • 2024', attributes: {'Производитель': 'BlueBrixx', 'Серия': 'Trains', 'Категория': 'Поезда', 'Модель': '104965', 'Год': '2024'}, sectionPath: ['manufacturers', 'bluebrixx', 'trains']),
    CatalogEntryDefinition(id: 'constructor-010', title: 'BlueBrixx Medieval Castle', primaryValue: 'BlueBrixx', subtitle: 'Buildings • 105000 • 2025', attributes: {'Производитель': 'BlueBrixx', 'Серия': 'Buildings', 'Категория': 'Здания', 'Модель': '105000', 'Год': '2025'}, sectionPath: ['manufacturers', 'bluebrixx', 'buildings']),
    CatalogEntryDefinition(id: 'constructor-011', title: 'MEGA Pokémon Center', primaryValue: 'MEGA', subtitle: 'Pokémon • HKT79 • 2024', attributes: {'Производитель': 'MEGA', 'Серия': 'Pokémon', 'Категория': 'Покемон', 'Модель': 'HKT79', 'Год': '2024'}, sectionPath: ['manufacturers', 'mega', 'pokemon']),
    CatalogEntryDefinition(id: 'constructor-012', title: 'MEGA Halo Warthog', primaryValue: 'MEGA', subtitle: 'Halo • HHC62 • 2023', attributes: {'Производитель': 'MEGA', 'Серия': 'Halo', 'Категория': 'Транспорт', 'Модель': 'HHC62', 'Год': '2023'}, sectionPath: ['manufacturers', 'mega', 'vehicles']),
  ];

  static const _pokemonEntries = <CatalogEntryDefinition>[
    CatalogEntryDefinition(id: 'pokemon-001', title: 'Pikachu', primaryValue: 'Scarlet & Violet', subtitle: 'Common • Basic', attributes: {'Серия': 'Scarlet & Violet', 'Редкость': 'Обычная', 'Тип карты': 'Покемон', 'Покемон': 'Pikachu'}, sectionPath: ['series', 'scarlet-violet']),
    CatalogEntryDefinition(id: 'pokemon-002', title: 'Charizard', primaryValue: 'Scarlet & Violet', subtitle: 'Rare • Basic', attributes: {'Серия': 'Scarlet & Violet', 'Редкость': 'Редкая', 'Тип карты': 'Покемон', 'Покемон': 'Charizard'}, sectionPath: ['series', 'scarlet-violet']),
    CatalogEntryDefinition(id: 'pokemon-003', title: 'Bulbasaur', primaryValue: 'Scarlet & Violet', subtitle: 'Common • Basic', attributes: {'Серия': 'Scarlet & Violet', 'Редкость': 'Обычная', 'Тип карты': 'Покемон', 'Покемон': 'Bulbasaur'}, sectionPath: ['series', 'scarlet-violet']),
    CatalogEntryDefinition(id: 'pokemon-004', title: 'Squirtle', primaryValue: 'Scarlet & Violet', subtitle: 'Common • Basic', attributes: {'Серия': 'Scarlet & Violet', 'Редкость': 'Обычная', 'Тип карты': 'Покемон', 'Покемон': 'Squirtle'}, sectionPath: ['series', 'scarlet-violet']),
    CatalogEntryDefinition(id: 'pokemon-005', title: 'Mew ex', primaryValue: 'Scarlet & Violet', subtitle: 'Ultra Rare • Basic', attributes: {'Серия': 'Scarlet & Violet', 'Редкость': 'Ультраредкая', 'Тип карты': 'Покемон', 'Покемон': 'Mew'}, sectionPath: ['series', 'scarlet-violet']),
    CatalogEntryDefinition(id: 'pokemon-006', title: 'Gardevoir ex', primaryValue: 'Scarlet & Violet', subtitle: 'Rare • Stage 2', attributes: {'Серия': 'Scarlet & Violet', 'Редкость': 'Редкая', 'Тип карты': 'Покемон', 'Покемон': 'Gardevoir'}, sectionPath: ['series', 'scarlet-violet']),
    CatalogEntryDefinition(id: 'pokemon-007', title: 'Eevee', primaryValue: 'Sword & Shield', subtitle: 'Common • Basic', attributes: {'Серия': 'Sword & Shield', 'Редкость': 'Обычная', 'Тип карты': 'Покемон', 'Покемон': 'Eevee'}, sectionPath: ['series', 'sword-shield']),
    CatalogEntryDefinition(id: 'pokemon-008', title: 'Umbreon V', primaryValue: 'Sword & Shield', subtitle: 'Ultra Rare • Basic', attributes: {'Серия': 'Sword & Shield', 'Редкость': 'Ультраредкая', 'Тип карты': 'Покемон', 'Покемон': 'Umbreon'}, sectionPath: ['series', 'sword-shield']),
    CatalogEntryDefinition(id: 'pokemon-009', title: 'Professor’s Research', primaryValue: 'Scarlet & Violet', subtitle: 'Trainer • Supporter', attributes: {'Серия': 'Scarlet & Violet', 'Редкость': 'Обычная', 'Тип карты': 'Тренер'}, sectionPath: ['type', 'trainer']),
    CatalogEntryDefinition(id: 'pokemon-010', title: 'Nest Ball', primaryValue: 'Scarlet & Violet', subtitle: 'Trainer • Item', attributes: {'Серия': 'Scarlet & Violet', 'Редкость': 'Обычная', 'Тип карты': 'Тренер'}, sectionPath: ['type', 'trainer']),
    CatalogEntryDefinition(id: 'pokemon-011', title: 'Fire Energy', primaryValue: 'Scarlet & Violet', subtitle: 'Energy • Basic', attributes: {'Серия': 'Scarlet & Violet', 'Редкость': 'Обычная', 'Тип карты': 'Энергия'}, sectionPath: ['type', 'energy']),
    CatalogEntryDefinition(id: 'pokemon-012', title: 'Lightning Energy', primaryValue: 'Scarlet & Violet', subtitle: 'Energy • Basic', attributes: {'Серия': 'Scarlet & Violet', 'Редкость': 'Обычная', 'Тип карты': 'Энергия'}, sectionPath: ['type', 'energy']),
  ];
}
