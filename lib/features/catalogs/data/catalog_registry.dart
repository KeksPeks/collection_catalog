import '../../templates/data/catalog_template_registry.dart';
import '../../templates/domain/entities/template.dart';
import '../domain/entities/catalog_category_definition.dart';
import '../domain/entities/catalog_definition.dart';
import '../domain/entities/catalog_entry_definition.dart';

/// Реестр готовых каталогов и их верхнеуровневых категорий.
///
/// Структура универсальна: категория -> каталог -> записи.
class CatalogRegistry {
  static List<CatalogCategoryDefinition> get categories => const [
        CatalogCategoryDefinition(
          id: 'constructors',
          name: 'Конструкторы',
          description: 'Конструкторы и наборы разных производителей.',
          catalogIds: ['lego'],
        ),
        CatalogCategoryDefinition(
          id: 'coins',
          name: 'Монеты',
          description: 'Нумизматические каталоги.',
          catalogIds: ['coins'],
        ),
        CatalogCategoryDefinition(
          id: 'banknotes',
          name: 'Банкноты',
          description: 'Бонистические каталоги.',
          catalogIds: ['banknotes'],
        ),
        CatalogCategoryDefinition(
          id: 'cards',
          name: 'Карточки',
          description: 'Коллекционные карточки.',
          catalogIds: ['pokemon_tcg'],
        ),
        CatalogCategoryDefinition(
          id: 'games',
          name: 'Игры',
          description: 'Видеоигры разных платформ.',
          catalogIds: ['games'],
        ),
        CatalogCategoryDefinition(
          id: 'discs',
          name: 'Диски',
          description: 'Игровые и музыкальные диски.',
          catalogIds: ['discs'],
        ),
        CatalogCategoryDefinition(
          id: 'movies',
          name: 'Фильмы',
          description: 'Фильмы и видео.',
          catalogIds: ['movies'],
        ),
        CatalogCategoryDefinition(
          id: 'figurines',
          name: 'Фигурки',
          description: 'Фигурки и миниатюры.',
          catalogIds: ['figurines'],
        ),
      ];

  static List<CatalogDefinition> get all {
    final templates = CatalogTemplateRegistry.all;
    return [
      _lego(templates),
      _coins(templates),
      _simple(templates, 'banknotes', 'country'),
      _simple(templates, 'pokemon_tcg', 'series'),
      _simple(templates, 'games', 'platform'),
      _simple(templates, 'discs', 'platform'),
      _simple(templates, 'movies', 'year'),
      _simple(templates, 'figurines', 'series'),
    ];
  }

  static CatalogDefinition? byId(String id) {
    for (final catalog in all) {
      if (catalog.id == id) return catalog;
    }
    return null;
  }

  static CatalogCategoryDefinition? categoryById(String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  static List<CatalogDefinition> catalogsForCategory(String categoryId) {
    final category = categoryById(categoryId);
    if (category == null) return const [];
    return category.catalogIds
        .map(byId)
        .whereType<CatalogDefinition>()
        .toList(growable: false);
  }

  static CatalogDefinition _lego(List<Template> templates) {
    final template = templates.firstWhere((item) => item.id == 'constructors');
    return CatalogDefinition(
      id: 'lego',
      name: 'LEGO',
      description: 'Каталог конструкторов LEGO по сериям и моделям.',
      templateId: template.id,
      template: template,
      primaryField: 'series',
      totalItems: 8,
      entries: const [
        CatalogEntryDefinition(id: 'lego-1', title: 'LEGO City Пожарная станция', primaryValue: 'City', subtitle: '60414 • 2025', attributes: {'Серия': 'City', 'Модель': '60414', 'Год': '2025', 'Деталей': '843'}),
        CatalogEntryDefinition(id: 'lego-2', title: 'LEGO Technic Ferrari SF-24', primaryValue: 'Technic', subtitle: '42207 • 2025', attributes: {'Серия': 'Technic', 'Модель': '42207', 'Год': '2025', 'Деталей': '1361'}),
        CatalogEntryDefinition(id: 'lego-3', title: 'LEGO Icons Букет цветов', primaryValue: 'Icons', subtitle: '10280 • 2021', attributes: {'Серия': 'Icons', 'Модель': '10280', 'Год': '2021', 'Деталей': '756'}),
        CatalogEntryDefinition(id: 'lego-4', title: 'LEGO Star Wars Millennium Falcon', primaryValue: 'Star Wars', subtitle: '75375 • 2024', attributes: {'Серия': 'Star Wars', 'Модель': '75375', 'Год': '2024', 'Деталей': '921'}),
        CatalogEntryDefinition(id: 'lego-5', title: 'LEGO Friends Дом на озере', primaryValue: 'Friends', subtitle: '42625 • 2024', attributes: {'Серия': 'Friends', 'Модель': '42625', 'Год': '2024', 'Деталей': '326'}),
        CatalogEntryDefinition(id: 'lego-6', title: 'LEGO Harry Potter Хогвартс', primaryValue: 'Harry Potter', subtitle: '76435 • 2024', attributes: {'Серия': 'Harry Potter', 'Модель': '76435', 'Год': '2024', 'Деталей': '1732'}),
        CatalogEntryDefinition(id: 'lego-7', title: 'LEGO NINJAGO Храм', primaryValue: 'NINJAGO', subtitle: '71814 • 2024', attributes: {'Серия': 'NINJAGO', 'Модель': '71814', 'Год': '2024', 'Деталей': '1192'}),
        CatalogEntryDefinition(id: 'lego-8', title: 'LEGO DUPLO Семейный дом', primaryValue: 'DUPLO', subtitle: '10983 • 2023', attributes: {'Серия': 'DUPLO', 'Модель': '10983', 'Год': '2023', 'Деталей': '40'}),
      ],
    );
  }

  static CatalogDefinition _coins(List<Template> templates) {
    final template = templates.firstWhere((item) => item.id == 'coins');
    return CatalogDefinition(
      id: 'coins',
      name: 'Монеты',
      description: 'Каталог монет по странам, типам чеканки и годам.',
      templateId: template.id,
      template: template,
      primaryField: 'country',
      totalItems: 6,
      entries: const [
        CatalogEntryDefinition(id: 'coin-1', title: '2 евро Германия', primaryValue: 'Германия', subtitle: '2024 • регулярный чекан', attributes: {'Страна': 'Германия', 'Год': '2024', 'Номинал': '2 EUR'}),
        CatalogEntryDefinition(id: 'coin-2', title: '1 евро Италия', primaryValue: 'Италия', subtitle: '2023 • регулярный чекан', attributes: {'Страна': 'Италия', 'Год': '2023', 'Номинал': '1 EUR'}),
        CatalogEntryDefinition(id: 'coin-3', title: '2 евро Франция', primaryValue: 'Франция', subtitle: '2022 • юбилейная', attributes: {'Страна': 'Франция', 'Год': '2022', 'Номинал': '2 EUR'}),
        CatalogEntryDefinition(id: 'coin-4', title: '10 рублей Россия', primaryValue: 'Россия', subtitle: '2020 • памятная', attributes: {'Страна': 'Россия', 'Год': '2020', 'Номинал': '10 RUB'}),
        CatalogEntryDefinition(id: 'coin-5', title: '1 евро Испания', primaryValue: 'Испания', subtitle: '2021 • регулярный чекан', attributes: {'Страна': 'Испания', 'Год': '2021', 'Номинал': '1 EUR'}),
        CatalogEntryDefinition(id: 'coin-6', title: '5 долларов Канада', primaryValue: 'Канада', subtitle: '2023 • серебро', attributes: {'Страна': 'Канада', 'Год': '2023', 'Номинал': '5 CAD'}),
      ],
      sections: const [
        CatalogSectionDefinition(id: 'countries', name: 'Страны', children: [
          CatalogSectionDefinition(id: 'commemorative', name: 'Юбилейные'),
          CatalogSectionDefinition(id: 'regular', name: 'Регулярный чекан'),
          CatalogSectionDefinition(id: 'precious', name: 'Драгоценные металлы'),
        ]),
      ],
    );
  }

  static CatalogDefinition _simple(
    List<Template> templates,
    String templateId,
    String primaryField,
  ) {
    final template = templates.firstWhere((item) => item.id == templateId);
    final entries = _sampleEntries(templateId);
    return CatalogDefinition(
      id: template.id,
      name: template.name,
      description: template.description,
      templateId: template.id,
      template: template,
      primaryField: primaryField,
      totalItems: entries.length,
      entries: entries,
    );
  }

  static List<CatalogEntryDefinition> _sampleEntries(String id) {
    switch (id) {
      case 'banknotes':
        return const [
          CatalogEntryDefinition(id: 'bank-1', title: '10 евро', primaryValue: 'Еврозона', subtitle: '2014 • серия Europa', attributes: {'Страна': 'Еврозона', 'Валюта': 'EUR', 'Год': '2014'}),
          CatalogEntryDefinition(id: 'bank-2', title: '100 рублей', primaryValue: 'Россия', subtitle: '2018 • серия 2017', attributes: {'Страна': 'Россия', 'Валюта': 'RUB', 'Год': '2018'}),
          CatalogEntryDefinition(id: 'bank-3', title: '20 долларов', primaryValue: 'Канада', subtitle: '2015 • polymer', attributes: {'Страна': 'Канада', 'Валюта': 'CAD', 'Год': '2015'}),
        ];
      case 'pokemon_tcg':
        return const [
          CatalogEntryDefinition(id: 'card-1', title: 'Pikachu', primaryValue: 'Base Set', subtitle: '#58 • Rare', attributes: {'Серия': 'Base Set', 'Номер': '58', 'Редкость': 'Rare'}),
          CatalogEntryDefinition(id: 'card-2', title: 'Charizard', primaryValue: 'Base Set', subtitle: '#4 • Holo Rare', attributes: {'Серия': 'Base Set', 'Номер': '4', 'Редкость': 'Holo Rare'}),
          CatalogEntryDefinition(id: 'card-3', title: 'Mew ex', primaryValue: '151', subtitle: '#193 • Double Rare', attributes: {'Серия': '151', 'Номер': '193', 'Редкость': 'Double Rare'}),
        ];
      case 'games':
        return const [
          CatalogEntryDefinition(id: 'game-1', title: 'The Legend of Zelda: Breath of the Wild', primaryValue: 'Nintendo Switch', subtitle: '2017 • Nintendo', attributes: {'Платформа': 'Nintendo Switch', 'Год': '2017'}),
          CatalogEntryDefinition(id: 'game-2', title: 'Gran Turismo 7', primaryValue: 'PlayStation 5', subtitle: '2022 • Sony', attributes: {'Платформа': 'PlayStation 5', 'Год': '2022'}),
          CatalogEntryDefinition(id: 'game-3', title: 'Forza Horizon 5', primaryValue: 'Xbox Series', subtitle: '2021 • Xbox', attributes: {'Платформа': 'Xbox Series', 'Год': '2021'}),
        ];
      case 'discs':
        return const [
          CatalogEntryDefinition(id: 'disc-1', title: 'Gran Turismo 7', primaryValue: 'PlayStation 5', subtitle: 'Blu-ray • 2022', attributes: {'Платформа': 'PlayStation 5', 'Год': '2022'}),
          CatalogEntryDefinition(id: 'disc-2', title: 'The Last of Us Part II', primaryValue: 'PlayStation 4', subtitle: 'Blu-ray • 2020', attributes: {'Платформа': 'PlayStation 4', 'Год': '2020'}),
          CatalogEntryDefinition(id: 'disc-3', title: 'Random Access Memories', primaryValue: 'Music CD', subtitle: '2013 • Daft Punk', attributes: {'Тип': 'Music CD', 'Год': '2013'}),
        ];
      case 'movies':
        return const [
          CatalogEntryDefinition(id: 'movie-1', title: 'Interstellar', primaryValue: '2014', subtitle: 'USA • Sci-Fi', attributes: {'Год': '2014', 'Страна': 'USA', 'Жанр': 'Sci-Fi'}),
          CatalogEntryDefinition(id: 'movie-2', title: 'Spirited Away', primaryValue: '2001', subtitle: 'Japan • Animation', attributes: {'Год': '2001', 'Страна': 'Japan', 'Жанр': 'Animation'}),
          CatalogEntryDefinition(id: 'movie-3', title: 'The Matrix', primaryValue: '1999', subtitle: 'USA • Sci-Fi', attributes: {'Год': '1999', 'Страна': 'USA', 'Жанр': 'Sci-Fi'}),
        ];
      case 'figurines':
        return const [
          CatalogEntryDefinition(id: 'fig-1', title: 'Spider-Man', primaryValue: 'Marvel', subtitle: '1:12 • PVC', attributes: {'Серия': 'Marvel', 'Персонаж': 'Spider-Man'}),
          CatalogEntryDefinition(id: 'fig-2', title: 'Batman', primaryValue: 'DC', subtitle: '1:12 • PVC', attributes: {'Серия': 'DC', 'Персонаж': 'Batman'}),
          CatalogEntryDefinition(id: 'fig-3', title: 'Geralt of Rivia', primaryValue: 'The Witcher', subtitle: '1:10 • PVC', attributes: {'Серия': 'The Witcher', 'Персонаж': 'Geralt'}),
        ];
      default:
        return const [];
    }
  }
}
