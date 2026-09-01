import '../domain/entities/catalog_definition.dart';

/// Реалистичная демонстрационная структура каталогов.
/// Эти разделы используются одинаково в каталоге и при создании локальной коллекции.
class CatalogSectionDefaults {
  static List<CatalogSectionDefinition> forCatalog(String id) => _definitions[id] ?? _generic;

  static const _generic = <CatalogSectionDefinition>[
    CatalogSectionDefinition(id: 'series', name: 'Серии и линейки', children: [
      CatalogSectionDefinition(id: 'main', name: 'Основные серии'),
      CatalogSectionDefinition(id: 'special', name: 'Специальные серии'),
      CatalogSectionDefinition(id: 'limited', name: 'Лимитированные серии'),
    ]),
    CatalogSectionDefinition(id: 'categories', name: 'Категории', children: [
      CatalogSectionDefinition(id: 'standard', name: 'Стандартные'),
      CatalogSectionDefinition(id: 'special', name: 'Специальные'),
      CatalogSectionDefinition(id: 'collectors', name: 'Коллекционные'),
    ]),
    CatalogSectionDefinition(id: 'editions', name: 'Издания и периоды', children: [
      CatalogSectionDefinition(id: 'current', name: 'Современные'),
      CatalogSectionDefinition(id: 'classic', name: 'Классические'),
      CatalogSectionDefinition(id: 'retro', name: 'Ретро'),
    ]),
  ];

  static const _definitions = <String, List<CatalogSectionDefinition>>{
    'lego': [
      CatalogSectionDefinition(id: 'manufacturers', name: 'Производители', children: [
        CatalogSectionDefinition(id: 'lego', name: 'LEGO', children: [
          CatalogSectionDefinition(id: 'city', name: 'City', children: [CatalogSectionDefinition(id: 'buildings', name: 'Здания'), CatalogSectionDefinition(id: 'vehicles', name: 'Транспорт'), CatalogSectionDefinition(id: 'people', name: 'Персонажи')]),
          CatalogSectionDefinition(id: 'technic', name: 'Technic', children: [CatalogSectionDefinition(id: 'vehicles', name: 'Техника'), CatalogSectionDefinition(id: 'motors', name: 'Моторизированные'), CatalogSectionDefinition(id: 'machines', name: 'Механизмы')]),
          CatalogSectionDefinition(id: 'icons', name: 'Icons', children: [CatalogSectionDefinition(id: 'buildings', name: 'Здания'), CatalogSectionDefinition(id: 'vehicles', name: 'Транспорт'), CatalogSectionDefinition(id: 'decor', name: 'Декор')]),
        ]),
        CatalogSectionDefinition(id: 'cobi', name: 'COBI', children: [
          CatalogSectionDefinition(id: 'military', name: 'Военная техника'), CatalogSectionDefinition(id: 'vehicles', name: 'Транспорт'), CatalogSectionDefinition(id: 'history', name: 'Исторические серии'),
        ]),
        CatalogSectionDefinition(id: 'cada', name: 'CaDA', children: [
          CatalogSectionDefinition(id: 'cars', name: 'Автомобили'), CatalogSectionDefinition(id: 'technic', name: 'Technic'), CatalogSectionDefinition(id: 'buildings', name: 'Здания'),
        ]),
        CatalogSectionDefinition(id: 'bluebrixx', name: 'BlueBrixx', children: [
          CatalogSectionDefinition(id: 'trains', name: 'Поезда'), CatalogSectionDefinition(id: 'military', name: 'Военная техника'), CatalogSectionDefinition(id: 'buildings', name: 'Здания'),
        ]),
        CatalogSectionDefinition(id: 'mega', name: 'MEGA', children: [
          CatalogSectionDefinition(id: 'pokemon', name: 'Pokémon'), CatalogSectionDefinition(id: 'halo', name: 'Halo'), CatalogSectionDefinition(id: 'vehicles', name: 'Транспорт'),
        ]),
      ]),
      CatalogSectionDefinition(id: 'release', name: 'Тип выпуска', children: [
        CatalogSectionDefinition(id: 'regular', name: 'Регулярные наборы'), CatalogSectionDefinition(id: 'exclusive', name: 'Эксклюзивные'), CatalogSectionDefinition(id: 'limited', name: 'Лимитированные'),
      ]),
      CatalogSectionDefinition(id: 'years', name: 'Годы выпуска', children: [
        CatalogSectionDefinition(id: '2026', name: '2026'), CatalogSectionDefinition(id: '2025', name: '2025'), CatalogSectionDefinition(id: '2024-earlier', name: '2024 и ранее'),
      ]),
    ],
    'coins': [
      CatalogSectionDefinition(id: 'countries', name: 'Страны', children: [
        CatalogSectionDefinition(id: 'russia', name: '🇷🇺 Россия', children: [
          CatalogSectionDefinition(id: 'regular', name: 'Регулярный чекан', children: [CatalogSectionDefinition(id: 'denominations', name: 'Номиналы'), CatalogSectionDefinition(id: 'years', name: 'Годы'), CatalogSectionDefinition(id: 'series', name: 'Серии')]),
          CatalogSectionDefinition(id: 'commemorative', name: 'Памятные выпуски', children: [CatalogSectionDefinition(id: 'denominations', name: 'Номиналы'), CatalogSectionDefinition(id: 'years', name: 'Годы'), CatalogSectionDefinition(id: 'series', name: 'Серии')]),
          CatalogSectionDefinition(id: 'precious', name: 'Драгоценные металлы', children: [CatalogSectionDefinition(id: 'silver', name: 'Серебро'), CatalogSectionDefinition(id: 'gold', name: 'Золото'), CatalogSectionDefinition(id: 'platinum', name: 'Платина')]),
        ]),
        CatalogSectionDefinition(id: 'germany', name: '🇩🇪 Германия', children: [CatalogSectionDefinition(id: 'regular', name: 'Регулярный чекан'), CatalogSectionDefinition(id: 'commemorative', name: 'Памятные выпуски'), CatalogSectionDefinition(id: 'special', name: 'Специальные выпуски')]),
        CatalogSectionDefinition(id: 'france', name: '🇫🇷 Франция', children: [CatalogSectionDefinition(id: 'regular', name: 'Регулярный чекан'), CatalogSectionDefinition(id: 'commemorative', name: 'Памятные выпуски'), CatalogSectionDefinition(id: 'special', name: 'Специальные выпуски')]),
        CatalogSectionDefinition(id: 'italy', name: '🇮🇹 Италия', children: [CatalogSectionDefinition(id: 'regular', name: 'Регулярный чекан'), CatalogSectionDefinition(id: 'commemorative', name: 'Памятные выпуски'), CatalogSectionDefinition(id: 'special', name: 'Специальные выпуски')]),
        CatalogSectionDefinition(id: 'other', name: 'Другие страны', children: [CatalogSectionDefinition(id: 'europe', name: 'Европа'), CatalogSectionDefinition(id: 'asia', name: 'Азия'), CatalogSectionDefinition(id: 'america', name: 'Америка')]),
      ]),
    ],
    'pokemon_tcg': [
      CatalogSectionDefinition(id: 'series', name: 'Серии', children: [CatalogSectionDefinition(id: 'scarlet-violet', name: 'Scarlet & Violet'), CatalogSectionDefinition(id: 'sword-shield', name: 'Sword & Shield'), CatalogSectionDefinition(id: 'sun-moon', name: 'Sun & Moon')]),
      CatalogSectionDefinition(id: 'type', name: 'Тип карты', children: [CatalogSectionDefinition(id: 'pokemon', name: 'Покемон'), CatalogSectionDefinition(id: 'trainer', name: 'Тренер'), CatalogSectionDefinition(id: 'energy', name: 'Энергия')]),
      CatalogSectionDefinition(id: 'rarity', name: 'Редкость', children: [CatalogSectionDefinition(id: 'common', name: 'Обычные'), CatalogSectionDefinition(id: 'rare', name: 'Редкие'), CatalogSectionDefinition(id: 'ultra', name: 'Ультраредкие')]),
    ],
    'banknotes': [
      CatalogSectionDefinition(id: 'countries', name: 'Страны', children: [CatalogSectionDefinition(id: 'russia', name: '🇷🇺 Россия'), CatalogSectionDefinition(id: 'germany', name: '🇩🇪 Германия'), CatalogSectionDefinition(id: 'other', name: 'Другие страны')]),
      CatalogSectionDefinition(id: 'periods', name: 'Периоды', children: [CatalogSectionDefinition(id: 'modern', name: 'Современные'), CatalogSectionDefinition(id: 'historical', name: 'Исторические'), CatalogSectionDefinition(id: 'commemorative', name: 'Памятные')]),
      CatalogSectionDefinition(id: 'denominations', name: 'Номиналы', children: [CatalogSectionDefinition(id: 'small', name: 'Малые'), CatalogSectionDefinition(id: 'medium', name: 'Средние'), CatalogSectionDefinition(id: 'large', name: 'Крупные')]),
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
      CatalogSectionDefinition(id: 'series', name: 'Серии', children: [CatalogSectionDefinition(id: 'anime', name: 'Аниме'), CatalogSectionDefinition(id: 'games', name: 'Игры'), CatalogSectionDefinition(id: 'movies', name: 'Фильмы и сериалы')]),
      CatalogSectionDefinition(id: 'scale', name: 'Размер', children: [CatalogSectionDefinition(id: 'small', name: 'Малые'), CatalogSectionDefinition(id: 'medium', name: 'Средние'), CatalogSectionDefinition(id: 'large', name: 'Крупные')]),
      CatalogSectionDefinition(id: 'material', name: 'Материал', children: [CatalogSectionDefinition(id: 'pvc', name: 'PVC'), CatalogSectionDefinition(id: 'resin', name: 'Смола'), CatalogSectionDefinition(id: 'other', name: 'Другие')]),
    ],
    'discs': [
      CatalogSectionDefinition(id: 'platforms', name: 'Платформы', children: [CatalogSectionDefinition(id: 'playstation', name: 'PlayStation'), CatalogSectionDefinition(id: 'xbox', name: 'Xbox'), CatalogSectionDefinition(id: 'pc', name: 'PC')]),
      CatalogSectionDefinition(id: 'generation', name: 'Поколения', children: [CatalogSectionDefinition(id: 'modern', name: 'Современные'), CatalogSectionDefinition(id: 'classic', name: 'Классические'), CatalogSectionDefinition(id: 'retro', name: 'Ретро')]),
      CatalogSectionDefinition(id: 'edition', name: 'Издания', children: [CatalogSectionDefinition(id: 'standard', name: 'Стандартные'), CatalogSectionDefinition(id: 'special', name: 'Специальные'), CatalogSectionDefinition(id: 'collectors', name: 'Коллекционные')]),
    ],
  };
}
