import '../domain/entities/catalog_entry_definition.dart';

/// Демонстрационные записи первого уровня для направлений каталога.
/// Ровно шесть разных наименований на каждое направление.
class CatalogSampleEntries {
  static List<CatalogEntryDefinition> forCatalog(String id) {
    final names = _names[id] ?? const <String>[];
    return [
      for (var i = 0; i < names.length; i++)
        CatalogEntryDefinition(
          id: '$id-sample-${i + 1}',
          title: names[i],
          primaryValue: names[i],
          subtitle: 'Демонстрационный образец • уровень 1',
          attributes: const {},
        ),
    ];
  }

  static const Map<String, List<String>> _names = {
    'banknotes': [
      '10 рублей — Россия', '20 марок — Германия', '50 долларов — США',
      '100 евро — Европейский союз', '500 рублей — Россия', '1000 иен — Япония',
    ],
    'pokemon_tcg': [
      'Pikachu', 'Charizard', 'Bulbasaur', 'Squirtle', 'Eevee', 'Mew',
    ],
    'games': [
      'The Last of Us Part II', 'Red Dead Redemption 2', 'The Legend of Zelda: Breath of the Wild',
      'Halo Infinite', 'Elden Ring', 'God of War Ragnarök',
    ],
    'movies': [
      'The Godfather', 'The Shawshank Redemption', 'The Dark Knight',
      'Pulp Fiction', 'The Lord of the Rings: The Return of the King', 'Interstellar',
    ],
    'figurines': [
      'Spider-Man', 'Batman', 'Darth Vader', 'Goku', 'Mario', 'Pikachu',
    ],
    'discs': [
      'Gran Turismo 7', 'Forza Horizon 5', 'Super Mario Odyssey',
      'Halo Infinite', 'Cyberpunk 2077', 'The Last of Us Part II',
    ],
    'philately': [
      'Первый человек в космосе', 'Олимпийские игры', 'Животный мир',
      'Архитектура Европы', 'История железных дорог', 'Рождественский выпуск',
    ],
    'designer_toys': [
      'Bearbrick 100%', 'KAWS Companion', 'Mighty Jaxx Skullpanda',
      'Medicom Toy R@BBRICK', 'Pop Mart Dimoo', 'Kidrobot Dunny',
    ],
    'models': [
      'Porsche 911', 'Ferrari F40', 'Ford Mustang', 'Boeing 747', 'Spitfire Mk.IX', 'Titanic',
    ],
    'consoles': [
      'PlayStation 5', 'Xbox Series X', 'Nintendo Switch OLED',
      'Steam Deck', 'PlayStation 2', 'Game Boy Advance',
    ],
    'comics': [
      'Amazing Fantasy #15', 'Batman: The Killing Joke', 'Watchmen',
      'The Walking Dead #1', 'Akira Vol. 1', 'One Piece Vol. 1',
    ],
    'books': [
      'Война и мир', '1984', 'Мастер и Маргарита', 'Гарри Поттер и философский камень',
      'Улисс', 'Дюна',
    ],
    'music': [
      'The Beatles — Abbey Road', 'Pink Floyd — The Dark Side of the Moon',
      'Michael Jackson — Thriller', 'David Bowie — The Rise and Fall of Ziggy Stardust',
      'Nirvana — Nevermind', 'Queen — A Night at the Opera',
    ],
    'board_games': [
      'Catan', 'Carcassonne', 'Ticket to Ride', 'Gloomhaven', 'Warhammer 40,000', 'Monopoly',
    ],
    'sports': [
      'Футбол', 'Баскетбол', 'Теннис', 'Формула-1', 'Хоккей', 'Бейсбол',
    ],
    'autographs': [
      'Albert Einstein', 'Marilyn Monroe', 'Elvis Presley', 'Stan Lee', 'Pelé', 'Neil Armstrong',
    ],
    'pins': [
      'Disney Mickey Mouse', 'NASA Mission Pin', 'Star Wars Logo',
      'Olympic Rings', 'Pokémon Pikachu', 'LEGO Logo',
    ],
    'postcards': [
      'Берлинская открытка', 'Парижская открытка', 'Венецианская открытка',
      'Москва — Красная площадь', 'Нью-Йорк — Манхэттен', 'Лондон — Биг-Бен',
    ],
    'stickers': [
      'Panini Football', 'Pokémon', 'Disney', 'Star Wars', 'NASA', 'LEGO',
    ],
    'playing_cards': [
      'Bicycle Rider Back', 'Bee No. 92', 'Tally-Ho Circle Back',
      'Copag 310', 'Theory11 Monarchs', 'Fournier 818',
    ],
    'beverages': [
      'Coca-Cola Classic', 'Pepsi-Cola', 'Fanta Orange', 'Sprite', 'Red Bull', 'Dr Pepper',
    ],
    'lighters_tobacco': [
      'Zippo Classic', 'Zippo Armor', 'Ronson Varaflame', 'Dunhill Rollagas',
      'S.T. Dupont Ligne 2', 'Colibri Monza',
    ],
    'watches_jewelry': [
      'Rolex Submariner', 'Omega Speedmaster', 'Patek Philippe Nautilus',
      'Audemars Piguet Royal Oak', 'Cartier Tank', 'Seiko 6139',
    ],
    'clothing': [
      'Nike Air Jordan 1', 'Levi’s 501', 'Adidas Superstar',
      'Supreme Box Logo T-Shirt', 'Stone Island Jacket', 'Converse Chuck Taylor',
    ],
    'instruments': [
      'Fender Stratocaster', 'Gibson Les Paul', 'Stradivarius Violin',
      'Yamaha DX7', 'Roland TR-808', 'Steinway Model D',
    ],
    'militaria': [
      'Орден Победы', 'Железный крест', 'Военная каска M35',
      'Знак отличия легиона', 'Полевая фляга', 'Пехотный штык',
    ],
    'antiques': [
      'Фарфоровая ваза XIX века', 'Бронзовые часы', 'Серебряный подсвечник',
      'Старинная шкатулка', 'Антикварное зеркало', 'Медная гравюра',
    ],
    'art': [
      'Звёздная ночь', 'Мона Лиза', 'Крик', 'Девушка с жемчужной серёжкой',
      'Подсолнухи', 'Постоянство памяти',
    ],
    'advertising': [
      'Coca-Cola Vintage Poster', 'Pepsi Vintage Sign', 'Kodak Advertisement',
      'Shell Enamel Sign', 'McDonald’s Vintage Poster', 'Apple Think Different Poster',
    ],
    'holiday': [
      'Рождественские украшения', 'Новогодние открытки', 'Пасхальные сувениры',
      'Хэллоуинские предметы', 'Декор ко Дню святого Валентина', 'Праздничные снежные шары',
    ],
  };
}
