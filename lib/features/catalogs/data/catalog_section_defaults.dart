import '../domain/entities/catalog_definition.dart';

/// Стандартная структура разделов для направлений, у которых пока нет
/// наполненного сервером дерева. Она используется и в каталоге, и при
/// создании локальной коллекции, поэтому интерфейс и загруженные данные
/// имеют одинаковую структуру.
class CatalogSectionDefaults {
  static List<CatalogSectionDefinition> forCatalog(String id) {
    final sections = _definitions[id];
    return sections ?? const [
      CatalogSectionDefinition(id: 'main', name: 'Основное', children: [
        CatalogSectionDefinition(id: 'new', name: 'Новые поступления'),
        CatalogSectionDefinition(id: 'popular', name: 'Популярное'),
        CatalogSectionDefinition(id: 'other', name: 'Другое'),
      ]),
      CatalogSectionDefinition(id: 'editions', name: 'Издания и серии', children: [
        CatalogSectionDefinition(id: 'standard', name: 'Стандартные'),
        CatalogSectionDefinition(id: 'special', name: 'Специальные'),
        CatalogSectionDefinition(id: 'limited', name: 'Лимитированные'),
      ]),
      CatalogSectionDefinition(id: 'status', name: 'Статус коллекции', children: [
        CatalogSectionDefinition(id: 'owned', name: 'В наличии'),
        CatalogSectionDefinition(id: 'wanted', name: 'Желаемые'),
        CatalogSectionDefinition(id: 'missing', name: 'Отсутствующие'),
      ]),
    ];
  }

  static const _definitions = <String, List<CatalogSectionDefinition>>{
    'lego': [
      CatalogSectionDefinition(id: 'themes', name: 'Серии', children: [CatalogSectionDefinition(id: 'city', name: 'City'), CatalogSectionDefinition(id: 'technic', name: 'Technic'), CatalogSectionDefinition(id: 'icons', name: 'Icons')]),
      CatalogSectionDefinition(id: 'types', name: 'Типы наборов', children: [CatalogSectionDefinition(id: 'sets', name: 'Наборы'), CatalogSectionDefinition(id: 'exclusive', name: 'Эксклюзивные'), CatalogSectionDefinition(id: 'limited', name: 'Лимитированные')]),
      CatalogSectionDefinition(id: 'years', name: 'Годы выпуска', children: [CatalogSectionDefinition(id: '2026', name: '2026'), CatalogSectionDefinition(id: '2025', name: '2025'), CatalogSectionDefinition(id: '2024', name: '2024 и ранее')]),
    ],
    'pokemon_tcg': [
      CatalogSectionDefinition(id: 'series', name: 'Серии', children: [CatalogSectionDefinition(id: 'scarlet-violet', name: 'Scarlet & Violet'), CatalogSectionDefinition(id: 'sword-shield', name: 'Sword & Shield'), CatalogSectionDefinition(id: 'other-series', name: 'Другие серии')]),
      CatalogSectionDefinition(id: 'rarity', name: 'Редкость', children: [CatalogSectionDefinition(id: 'common', name: 'Обычные'), CatalogSectionDefinition(id: 'rare', name: 'Редкие'), CatalogSectionDefinition(id: 'ultra', name: 'Ультраредкие')]),
      CatalogSectionDefinition(id: 'card-type', name: 'Тип карты', children: [CatalogSectionDefinition(id: 'pokemon', name: 'Покемон'), CatalogSectionDefinition(id: 'trainer', name: 'Тренер'), CatalogSectionDefinition(id: 'energy', name: 'Энергия')]),
    ],
    'banknotes': [
      CatalogSectionDefinition(id: 'countries', name: 'Страны', children: [CatalogSectionDefinition(id: 'russia', name: 'Россия'), CatalogSectionDefinition(id: 'germany', name: 'Германия'), CatalogSectionDefinition(id: 'other', name: 'Другие страны')]),
      CatalogSectionDefinition(id: 'denominations', name: 'Номиналы', children: [CatalogSectionDefinition(id: 'small', name: 'Малые номиналы'), CatalogSectionDefinition(id: 'medium', name: 'Средние номиналы'), CatalogSectionDefinition(id: 'large', name: 'Крупные номиналы')]),
      CatalogSectionDefinition(id: 'periods', name: 'Периоды', children: [CatalogSectionDefinition(id: 'modern', name: 'Современные'), CatalogSectionDefinition(id: 'historical', name: 'Исторические'), CatalogSectionDefinition(id: 'commemorative', name: 'Памятные')]),
    ],
    'games': [
      CatalogSectionDefinition(id: 'platforms', name: 'Платформы', children: [CatalogSectionDefinition(id: 'playstation', name: 'PlayStation'), CatalogSectionDefinition(id: 'xbox', name: 'Xbox'), CatalogSectionDefinition(id: 'nintendo', name: 'Nintendo')]),
      CatalogSectionDefinition(id: 'genres', name: 'Жанры', children: [CatalogSectionDefinition(id: 'action', name: 'Экшен'), CatalogSectionDefinition(id: 'rpg', name: 'RPG'), CatalogSectionDefinition(id: 'strategy', name: 'Стратегии')]),
      CatalogSectionDefinition(id: 'editions', name: 'Издания', children: [CatalogSectionDefinition(id: 'standard', name: 'Стандартные'), CatalogSectionDefinition(id: 'special', name: 'Специальные'), CatalogSectionDefinition(id: 'collectors', name: 'Коллекционные')]),
    ],
    'movies': [
      CatalogSectionDefinition(id: 'genres', name: 'Жанры', children: [CatalogSectionDefinition(id: 'action', name: 'Боевики'), CatalogSectionDefinition(id: 'drama', name: 'Драмы'), CatalogSectionDefinition(id: 'fantasy', name: 'Фэнтези и фантастика')]),
      CatalogSectionDefinition(id: 'formats', name: 'Форматы', children: [CatalogSectionDefinition(id: 'bluray', name: 'Blu-ray'), CatalogSectionDefinition(id: 'dvd', name: 'DVD'), CatalogSectionDefinition(id: 'digital', name: 'Цифровые')]),
      CatalogSectionDefinition(id: 'years', name: 'Годы', children: [CatalogSectionDefinition(id: '2020s', name: '2020-е'), CatalogSectionDefinition(id: '2010s', name: '2010-е'), CatalogSectionDefinition(id: 'older', name: 'Ранее')]),
    ],
    'figurines': [
      CatalogSectionDefinition(id: 'series', name: 'Серии', children: [CatalogSectionDefinition(id: 'characters', name: 'Персонажи'), CatalogSectionDefinition(id: 'anime', name: 'Аниме'), CatalogSectionDefinition(id: 'games', name: 'Игровые серии')]),
      CatalogSectionDefinition(id: 'scale', name: 'Масштаб и размер', children: [CatalogSectionDefinition(id: 'small', name: 'Малые'), CatalogSectionDefinition(id: 'medium', name: 'Средние'), CatalogSectionDefinition(id: 'large', name: 'Крупные')]),
      CatalogSectionDefinition(id: 'material', name: 'Материалы', children: [CatalogSectionDefinition(id: 'pvc', name: 'PVC'), CatalogSectionDefinition(id: 'resin', name: 'Смола'), CatalogSectionDefinition(id: 'other', name: 'Другие')]),
    ],
    'discs': [
      CatalogSectionDefinition(id: 'platforms', name: 'Платформы', children: [CatalogSectionDefinition(id: 'playstation', name: 'PlayStation'), CatalogSectionDefinition(id: 'xbox', name: 'Xbox'), CatalogSectionDefinition(id: 'pc', name: 'PC')]),
      CatalogSectionDefinition(id: 'generation', name: 'Поколения', children: [CatalogSectionDefinition(id: 'modern', name: 'Современные'), CatalogSectionDefinition(id: 'classic', name: 'Классические'), CatalogSectionDefinition(id: 'retro', name: 'Ретро')]),
      CatalogSectionDefinition(id: 'edition', name: 'Издания', children: [CatalogSectionDefinition(id: 'standard', name: 'Стандартные'), CatalogSectionDefinition(id: 'special', name: 'Специальные'), CatalogSectionDefinition(id: 'collectors', name: 'Коллекционные')]),
    ],
  };
}
