import '../domain/entities/catalog_definition.dart';

/// Второй уровень структуры каталогов.
///
/// Ключ первого уровня: каталог -> id первого уровня -> элементы второго уровня.
class CatalogSecondLevelDefaults {
  static List<CatalogSectionDefinition> apply(
    String catalogId,
    List<CatalogSectionDefinition> sections,
  ) {
    final definitions = _definitions[catalogId];
    if (definitions == null) return sections;

    return sections.map((section) {
      final children = definitions[section.id];
      if (children == null) return section;
      return CatalogSectionDefinition(
        id: section.id,
        name: section.name,
        children: children,
      );
    }).toList(growable: false);
  }

  static const _definitions = <String, Map<String, List<CatalogSectionDefinition>>>{
    'lego': {
      'lego': _six('City', 'Technic', 'Star Wars', 'Harry Potter', 'Friends', 'Icons'),
      'mega': _six('Pokémon', 'Halo', 'Hot Wheels', 'Barbie', 'Masters of the Universe', 'Builders'),
      'knex': _six('Classic', 'Thrill Rides', 'STEM', 'Kid K\'NEX', 'Mario Kart', 'Education'),
      'meccano': _six('Classic', 'Evolution', 'Junior', 'Super Models', 'Multi Models', 'Mechanics'),
      'lincoln-logs': _six('Classic', 'Frontier', 'Western', 'Pioneer', 'Cabin', 'Collector'),
      'magformers': _six('Basic', 'Classic', 'Carnival', 'Construction', 'Designer', 'STEM'),
      'geomag': _six('Classic', 'Mechanics', 'Supercolor', 'Glow', 'E-Motion', 'Magnetic Tiles'),
    },
    'pokemon_tcg': {
      'pokemon-tcg': _six('Scarlet & Violet', 'Sword & Shield', 'Sun & Moon', 'XY', 'Black & White', 'Diamond & Pearl'),
      'magic': _six('Standard', 'Modern', 'Commander', 'Masters', 'Universes Beyond', 'Secret Lair'),
      'yugioh': _six('Main Sets', 'Booster Packs', 'Structure Decks', 'Starter Decks', 'Tins', 'Special Sets'),
      'lorcana': _six('The First Chapter', 'Rise of the Floodborn', 'Into the Inklands', 'Ursula\'s Return', 'Shimmering Skies', 'Archazia\'s Island'),
      'one-piece': _six('Romance Dawn', 'Paramount War', 'Pillars of Strength', 'Kingdoms of Intrigue', 'Wings of the Captain', 'Memorial Collection'),
      'dragon-ball': _six('Series 1', 'Series 2', 'Expansion Sets', 'Special Packs', 'Starter Decks', 'Premium Sets'),
    },
    'coins': {
      'russia': _six('РСФСР', 'СССР', 'Российская Федерация', 'Памятные', 'Инвестиционные', 'Юбилейные'),
      'germany': _six('Германская империя', 'Веймарская республика', 'Третий рейх', 'ФРГ', 'ГДР', 'Современная Германия'),
      'france': _six('Франк', 'Новый франк', 'Евро', 'Памятные', 'Золотые', 'Серебряные'),
      'uk': _six('Penny', 'Shilling', 'Pound', 'Sovereign', 'Commemorative', 'Decimal'),
      'usa': _six('Cent', 'Nickel', 'Dime', 'Quarter', 'Half Dollar', 'Dollar'),
      'euro': _six('1–2 евро', '10–50 центов', '1–5 центов', 'Памятные €2', 'Коллекционные', 'Юбилейные'),
    },
    'banknotes': {
      'russia': _six('Российская империя', 'Временное правительство', 'РСФСР', 'СССР', 'РФ', 'Региональные выпуски'),
      'germany': _six('Империя', 'Веймарская республика', 'Рейхсбанк', 'ФРГ', 'ГДР', 'Евро'),
      'usa': _six('Federal Reserve', 'Silver Certificates', 'Gold Certificates', 'United States Notes', 'National Bank Notes', 'Современные'),
      'uk': _six('Bank of England', 'Treasury Notes', 'Pounds', 'Scottish', 'Northern Irish', 'Commemorative'),
      'france': _six('Francs', 'Banque de France', 'Assignats', 'Colonial', 'Emergency', 'Euro'),
      'japan': _six('Yen', 'Sen', 'Imperial', 'Military Currency', 'Occupation', 'Modern'),
    },
    'philately': {
      'russia': _six('Российская империя', 'РСФСР', 'СССР', 'РФ', 'Регионы', 'Специальные выпуски'),
      'germany': _six('Империя', 'Веймар', 'Рейх', 'ФРГ', 'ГДР', 'Современная Германия'),
      'usa': _six('Definitives', 'Commemoratives', 'Air Mail', 'Special Delivery', 'Officials', 'Forever'),
      'uk': _six('Penny Black', 'Victorian', 'Edwardian', 'George V', 'Elizabeth II', 'Charles III'),
      'france': _six('Classic', 'Ceres', 'Napoleon', 'Sower', 'Marianne', 'Modern'),
      'japan': _six('Classic', 'Definitive', 'Commemorative', 'Airmail', 'Prefecture', 'Modern'),
    },
    'figurines': {
      'funko': _six('Pop!', 'Pop! Deluxe', 'Pop! Rides', 'Pop! Moments', 'Pop! Jumbo', 'Exclusives'),
      'lego-minifigures': _six('Collectible Minifigures', 'Marvel', 'Star Wars', 'Disney', 'Harry Potter', 'Seasonal'),
      'hasbro': _six('Marvel Legends', 'Star Wars', 'Transformers', 'G.I. Joe', 'My Little Pony', 'Power Rangers'),
      'mattel': _six('Barbie', 'Hot Wheels', 'Masters of the Universe', 'Jurassic World', 'WWE', 'Disney'),
      'bandai': _six('S.H.Figuarts', 'Figuarts Mini', 'Gundam', 'Digimon', 'Dragon Ball', 'Anime'),
      'neca': _six('Horror', 'Sci-Fi', 'Video Games', 'Movies', 'Toony Terrors', 'Ultimate'),
    },
    'designer_toys': {
      'bearbrick': _six('100%', '400%', '1000%', 'Artist Series', 'Secret', 'Collaboration'),
      'kaws': _six('Companion', 'Chum', 'BFF', 'Passing Through', 'Holiday', 'Collaboration'),
      'pop-mart': _six('DIMOO', 'MOLLY', 'SKULLPANDA', 'LABUBU', 'CRYBABY', 'HIRONO'),
      'kidrobot': _six('Dunny', 'Munny', 'Labbit', 'Phunny', 'Yummy World', 'Collaboration'),
      'mighty-jaxx': _six('XXRAY', 'Dissectables', "Freeny's", 'Bearbrick Collaboration', 'Disney', 'Marvel'),
      'medicom-toy': _six('BE@RBRICK', 'UDF', 'VCD', 'MAFEX', 'RAH', 'Collaboration'),
    },
    'models': {
      'cars': _six('Формула-1', 'Спорткары', 'Классика', 'Грузовики', 'Спецтехника', 'Ралли'),
      'aircraft': _six('Пассажирские', 'Военные', 'Транспортные', 'Исторические', 'Бизнес-джеты', 'Космические'),
      'military': _six('Танки', 'БТР', 'Артиллерия', 'Автомобили', 'Авиация', 'Флот'),
      'ships': _six('Лайнеры', 'Парусники', 'Военные', 'Грузовые', 'Подводные лодки', 'Исторические'),
      'railway': _six('Локомотивы', 'Пассажирские', 'Грузовые', 'Метро', 'Трамваи', 'Исторические'),
      'space': _six('Ракеты', 'Космические корабли', 'Станции', 'Спутники', 'Луноходы', 'Исторические миссии'),
    },
    'games': {
      'playstation': _six('PS1', 'PS2', 'PS3', 'PS4', 'PS5', 'PSP/Vita'),
      'xbox': _six('Xbox', 'Xbox 360', 'Xbox One', 'Series X/S', 'Xbox Classics', 'Digital'),
      'nintendo': _six('NES', 'SNES', 'N64', 'GameCube', 'Wii', 'Switch'),
      'pc': _six('DOS', 'Windows', 'Mac', 'Linux', 'Steam', 'GOG'),
      'sega': _six('Master System', 'Mega Drive', 'Saturn', 'Dreamcast', 'Game Gear', 'Arcade'),
      'atari': _six('2600', '5200', '7800', 'Lynx', 'Jaguar', 'Arcade'),
    },
    'consoles': {
      'playstation': _six('PS1', 'PS2', 'PS3', 'PS4', 'PS5', 'PSP/Vita'),
      'xbox': _six('Xbox', 'Xbox 360', 'Xbox One', 'Series S', 'Series X', 'Accessories'),
      'nintendo': _six('NES', 'SNES', 'N64', 'GameCube', 'Wii', 'Switch'),
      'sega': _six('Master System', 'Mega Drive', 'Saturn', 'Dreamcast', 'Game Gear', 'Accessories'),
      'valve': _six('Steam Deck', 'Steam Controller', 'Steam Link', 'Index', 'Index Controllers', 'Accessories'),
      'atari': _six('2600', '5200', '7800', 'Lynx', 'Jaguar', 'Accessories'),
    },
    'comics': {
      'marvel': _six('Spider-Man', 'X-Men', 'Avengers', 'Fantastic Four', 'Guardians of the Galaxy', 'Deadpool'),
      'dc': _six('Batman', 'Superman', 'Wonder Woman', 'Justice League', 'Flash', 'Green Lantern'),
      'image': _six('Spawn', 'Invincible', 'The Walking Dead', 'Saga', 'Savage Dragon', 'Witchblade'),
      'dark-horse': _six('Hellboy', 'Sin City', 'The Mask', 'Star Wars', 'Aliens', 'Predator'),
      'manga': _six('Shonen', 'Shojo', 'Seinen', 'Josei', 'Kodomo', 'One-shot'),
      'european': _six('Franco-Belgian', 'Italian', 'Spanish', 'German', 'British', 'Eastern European'),
    },
    'books': {
      'fiction': _six('Романы', 'Рассказы', 'Повести', 'Классика', 'Современная проза', 'Зарубежная литература'),
      'scifi': _six('Научная фантастика', 'Космоопера', 'Антиутопия', 'Киберпанк', 'Постапокалипсис', 'Time travel'),
      'fantasy': _six('High Fantasy', 'Dark Fantasy', 'Urban Fantasy', 'Epic Fantasy', 'Grimdark', 'Fairy Tale'),
      'detective': _six('Классический', 'Криминальный', 'Триллер', 'Нуар', 'Исторический', 'Шпионский'),
      'science': _six('Физика', 'Химия', 'Биология', 'Математика', 'Медицина', 'Технологии'),
      'history': _six('Древний мир', 'Средневековье', 'Новое время', 'XX век', 'Военная история', 'Биографии'),
    },
    'music': {
      'vinyl': _six('LP', 'EP', 'Singles', 'Picture Disc', 'Colored Vinyl', 'Box Sets'),
      'cd': _six('Albums', 'Singles', 'Maxi-Singles', 'Box Sets', 'Limited Editions', 'Promos'),
      'cassette': _six('Albums', 'Singles', 'Compilation', 'Promo', 'Limited', 'Mixtapes'),
      'audio-video': _six('Concerts', 'Albums', 'Box Sets', 'Live', 'Documentary', 'Special Editions'),
      'editions': _six('Ноты', 'Songbooks', 'Artbooks', 'Magazines', 'Programs', 'Catalogs'),
      'memorabilia': _six('Постеры', 'Билеты', 'Автографы', 'Backstage', 'Промо', 'Мерч'),
    },
    'movies': {
      'dvd': _six('Standard', 'Special Edition', "Collector's", 'Box Set', 'SteelBook', 'Limited'),
      'bluray': _six('Standard', '3D', 'SteelBook', "Collector's", 'Box Set', 'Limited'),
      'uhd': _six('Standard', 'SteelBook', "Collector's", 'Box Set', 'Limited', 'Premium'),
      'vhs': _six('Rental', 'Retail', 'Promo', 'Limited', "Collector's", 'Japanese'),
      'laserdisc': _six('CAV', 'CLV', 'Criterion', 'Box Set', 'Music', "Collector's"),
      'collectors': _six('SteelBook', 'Digibook', 'Mediabook', 'Box Set', 'Deluxe', 'Ultimate'),
    },
    'board_games': {
      'strategy': _six('Военные', 'Экономические', 'Политические', 'Территориальные', 'Цивилизационные', '4X'),
      'eurogames': _six('Экономические', 'Ресурсные', 'Worker placement', 'Deck building', 'Tile placement', 'Engine building'),
      'card-board': _six('Deck Building', 'Living Card Game', 'Trading Card', 'Party', 'Strategy', 'Solo'),
      'wargames': _six('Historical', 'Fantasy', 'Sci-Fi', 'Skirmish', 'Mass Battle', 'Naval'),
      'rpg': _six('Fantasy', 'Sci-Fi', 'Horror', 'Modern', 'Historical', 'Solo'),
      'miniatures': _six('Infantry', 'Vehicles', 'Monsters', 'Characters', 'Terrain', 'Dioramas'),
    },
    'sports': {
      'football': _six('Клубы', 'Сборные', 'Турниры', 'Игроки', 'Чемпионаты', 'Memorabilia'),
      'basketball': _six('NBA', 'WNBA', 'NCAA', 'Международные', 'Игроки', 'Memorabilia'),
      'hockey': _six('NHL', 'KHL', 'IIHF', 'Сборные', 'Игроки', 'Memorabilia'),
      'tennis': _six('Grand Slam', 'ATP', 'WTA', 'Игроки', 'Турниры', 'Memorabilia'),
      'formula1': _six('Команды', 'Пилоты', 'Болиды', 'Сезоны', 'Гонки', 'Memorabilia'),
      'olympics': _six('Летние', 'Зимние', 'Медали', 'Значки', 'Билеты', 'Memorabilia'),
    },
    'autographs': {
      'cinema': _six('Актёры', 'Режиссёры', 'Фильмы', 'Сериалы', 'Постеры', 'Сценарии'),
      'music': _six('Исполнители', 'Группы', 'Альбомы', 'Инструменты', 'Билеты', 'Фотографии'),
      'sports': _six('Футбол', 'Баскетбол', 'Хоккей', 'Теннис', 'Автоспорт', 'Олимпийцы'),
      'politics': _six('Президенты', 'Монархи', 'Министры', 'Дипломаты', 'Документы', 'Фотографии'),
      'science': _six('Учёные', 'Инженеры', 'Изобретатели', 'Космонавты', 'Документы', 'Фотографии'),
      'history': _six('Военные деятели', 'Государственные деятели', 'Исторические документы', 'Фотографии', 'Письма', 'Предметы'),
    },
    'pins': {
      'disney': _six('Персонажи', 'Парки', 'Фильмы', 'Юбилеи', 'Limited', 'Cast exclusive'),
      'marvel': _six('Герои', 'Команды', 'Фильмы', 'Комиксы', 'События', 'Limited'),
      'star-wars': _six('Персонажи', 'Фильмы', 'Сериалы', 'Планеты', 'Корабли', 'События'),
      'pokemon': _six('Персонажи', 'Игры', 'TCG', 'Регионы', 'События', 'Limited'),
      'nasa': _six('Миссии', 'Программы', 'Космонавты', 'Центры', 'Shuttle', 'Artemis'),
      'olympics': _six('Логотипы', 'Талисманы', 'Города', 'Виды спорта', 'Медали', 'События'),
    },
    'postcards': {
      'postcards': _six('Города', 'Страны', 'Люди', 'Транспорт', 'Искусство', 'Праздники'),
      'photographs': _six('Портреты', 'Пейзажи', 'События', 'Спорт', 'Кино', 'Исторические'),
      'movie-posters': _six('Фильмы', 'Актёры', 'Режиссёры', 'Жанры', 'Страны', 'Оригинальные постеры'),
      'music-posters': _six('Исполнители', 'Группы', 'Концерты', 'Фестивали', 'Альбомы', 'Туры'),
      'advertising-posters': _six('Напитки', 'Автомобили', 'Техника', 'Продукты', 'Магазины', 'Услуги'),
      'travel-posters': _six('Города', 'Страны', 'Курорты', 'Железные дороги', 'Авиалинии', 'Достопримечательности'),
    },
    'stickers': {
      'pokemon': _six('Персонажи', 'TCG', 'Игры', 'Фильмы', 'Промо', 'Коллекционные'),
      'panini': _six('Football', 'World Cup', 'Champions League', 'Formula 1', 'Disney', 'Marvel'),
      'disney': _six('Mickey Mouse', 'Princess', 'Pixar', 'Marvel', 'Star Wars', 'Parks'),
      'marvel': _six('Avengers', 'Spider-Man', 'X-Men', 'Guardians', 'Deadpool', 'Villains'),
      'star-wars': _six('Characters', 'Vehicles', 'Planets', 'Movies', 'Series', 'Logos'),
      'lego': _six('City', 'Technic', 'Star Wars', 'Ninjago', 'Friends', 'Minifigures'),
    },
    'playing_cards': {
      'bicycle': _six('Standard', 'Prestige', 'Rider Back', 'Collectors', 'Limited', 'Collaboration'),
      'bee': _six('Casino', 'Club Special', 'Heritage', 'Premium', 'Collectors', 'Limited'),
      'tally-ho': _six('Circle Back', 'Fan Back', 'Special Edition', 'Artist', 'Limited', 'Collaboration'),
      'copag': _six('4-Color', 'Poker', 'Bridge', 'Jumbo Index', 'Plastic', 'Tournament'),
      'fournier': _six('181', 'Poker', 'Spanish', 'Bridge', 'Tarot', 'Special'),
      'theory11': _six('Luxury', 'Artist', 'Film', 'Games', 'Gold', 'Limited'),
    },
    'beverages': {
      'coca-cola': _six('Classic', 'Vintage', 'Olympic', 'FIFA', 'Christmas', 'Promotional'),
      'pepsi': _six('Classic', 'Sports', 'Music', 'Movie', 'Vintage', 'Promotional'),
      'fanta': _six('Orange', 'World Flavors', 'Promotional', 'Vintage', 'Limited', 'Seasonal'),
      'sprite': _six('Classic', 'NBA', 'Music', 'Promotional', 'Vintage', 'Limited'),
      'dr-pepper': _six('Classic', 'Sports', 'Movie', 'Vintage', 'Promotional', 'Limited'),
      'red-bull': _six('Racing', 'Extreme Sports', 'Events', 'Aircraft', 'Promotional', 'Limited'),
    },
    'lighters_tobacco': {
      'zippo': _six('Regular', 'Slim', 'Armor', 'Replica', 'Limited', 'Collaboration'),
      'dupont': _six('Ligne 1', 'Ligne 2', 'Ligne D', 'Slim', 'Limited', 'Prestige'),
      'dunhill': _six('Rollagas', 'Unique', 'Service', 'Aquarium', 'Limited', 'Vintage'),
      'ronson': _six('Varaflame', 'Standard', 'Adonis', 'Premier', 'Vintage', 'Limited'),
      'im-corona': _six('Old Boy', 'Pipe', 'Double Corona', 'Premium', 'Vintage', 'Limited'),
      'colibri': _six('Classic', 'Quasar', 'Monza', 'Rally', 'Premium', 'Limited'),
    },
    'watches_jewelry': {
      'rolex': _six('Submariner', 'Daytona', 'Datejust', 'GMT-Master', 'Explorer', 'Oyster'),
      'omega': _six('Speedmaster', 'Seamaster', 'Constellation', 'De Ville', 'Railmaster', 'Special'),
      'patek': _six('Calatrava', 'Nautilus', 'Aquanaut', 'Complications', 'Grand Complications', 'Vintage'),
      'audemars': _six('Royal Oak', 'Royal Oak Offshore', 'Code 11.59', 'Millenary', 'Jules Audemars', 'Vintage'),
      'cartier': _six('Tank', 'Santos', 'Ballon Bleu', 'Panthère', 'Pasha', 'Vintage'),
      'seiko': _six('Prospex', 'Presage', '5 Sports', 'Astron', 'King Seiko', 'Vintage'),
    },
    'clothing': {
      'nike': _six('Air Jordan', 'Air Max', 'Dunk', 'Air Force 1', 'SB', 'ACG'),
      'adidas': _six('Originals', 'Superstar', 'Stan Smith', 'Forum', 'Yeezy', 'Spezial'),
      'levis': _six('501', '505', '511', '517', 'Trucker', 'Vintage'),
      'supreme': _six('Box Logo', 'Jackets', 'Shirts', 'Accessories', 'Skate', 'Collaborations'),
      'stone-island': _six('Jackets', 'Knitwear', 'Shirts', 'Pants', 'Footwear', 'Accessories'),
      'converse': _six('Chuck Taylor', 'Chuck 70', 'One Star', 'Run Star', 'Jack Purcell', 'Limited'),
    },
    'instruments': {
      'fender': _six('Stratocaster', 'Telecaster', 'Jazzmaster', 'Precision Bass', 'Jazz Bass', 'Custom Shop'),
      'gibson': _six('Les Paul', 'SG', 'ES', 'Flying V', 'Explorer', 'Custom Shop'),
      'yamaha': _six('Pianos', 'Keyboards', 'Guitars', 'Drums', 'Brass', 'Synthesizers'),
      'roland': _six('Synthesizers', 'Keyboards', 'Drums', 'Digital Pianos', 'Effects', 'DJ'),
      'steinway': _six('Grand Piano', 'Upright', 'Limited', 'Art Case', 'Concert', 'Vintage'),
      'martin': _six('D Series', '000 Series', 'OM Series', 'Auditorium', 'Custom', 'Vintage'),
    },
    'militaria': {
      'awards': _six('Государственные', 'Военные', 'Юбилейные', 'Памятные', 'Иностранные', 'Ведомственные'),
      'badges': _six('Военные', 'Ведомственные', 'Партийные', 'Спортивные', 'Учебные', 'Памятные'),
      'uniform': _six('Парадная', 'Полевая', 'Офицерская', 'Солдатская', 'Авиационная', 'Флотская'),
      'helmets': _six('Боевые', 'Стальные', 'Композитные', 'Авиационные', 'Пожарные', 'Исторические'),
      'documents': _six('Удостоверения', 'Письма', 'Документы', 'Фотографии', 'Карты', 'Плакаты'),
      'flags': _six('Государственные', 'Военные', 'Подразделений', 'Организаций', 'Исторические', 'Памятные'),
    },
    'antiques': {
      'furniture': _six('Столы', 'Стулья', 'Шкафы', 'Кресла', 'Комоды', 'Письменные столы'),
      'porcelain': _six('Посуда', 'Статуэтки', 'Вазы', 'Сервизы', 'Плитка', 'Декоративные изделия'),
      'glass': _six('Вазы', 'Посуда', 'Бутылки', 'Фигурки', 'Светильники', 'Художественное стекло'),
      'silver': _six('Столовые приборы', 'Посуда', 'Украшения', 'Предметы быта', 'Сервизы', 'Изделия'),
      'clocks': _six('Карманные', 'Настольные', 'Напольные', 'Каминные', 'Наручные', 'Механизмы'),
      'household': _six('Шкатулки', 'Инструменты', 'Лампы', 'Письменные принадлежности', 'Кухонные предметы', 'Декор'),
    },
    'art': {
      'painting': _six('Портрет', 'Пейзаж', 'Натюрморт', 'Жанровая сцена', 'Абстракция', 'Историческая'),
      'graphic': _six('Рисунок', 'Гравюра', 'Литография', 'Офорт', 'Шелкография', 'Иллюстрация'),
      'sculpture': _six('Бронза', 'Камень', 'Дерево', 'Керамика', 'Гипс', 'Mixed media'),
      'photography': _six('Vintage', 'Fine Art', 'Documentary', 'Portrait', 'Landscape', 'Experimental'),
      'decorative': _six('Керамика', 'Стекло', 'Текстиль', 'Металл', 'Дерево', 'Эмаль'),
      'posters': _six('Кино', 'Реклама', 'Политика', 'Спорт', 'Туризм', 'Культура'),
    },
    'advertising': {
      'posters': _six('Реклама', 'Кино', 'Спорт', 'Туризм', 'Продукты', 'Мероприятия'),
      'signs': _six('Металл', 'Эмаль', 'Неон', 'Дерево', 'Пластик', 'Световые'),
      'tin-signs': _six('Напитки', 'Автомобили', 'Топливо', 'Продукты', 'Табак', 'Техника'),
      'pos': _six('Стенды', 'Дисплеи', 'Воблеры', 'Ценники', 'Витрины', 'Рекламные конструкции'),
      'packaging': _six('Банки', 'Бутылки', 'Коробки', 'Банки жестяные', 'Пакеты', 'Контейнеры'),
      'souvenirs': _six('Брелоки', 'Ручки', 'Пепельницы', 'Кружки', 'Часы', 'Календари'),
    },
    'holiday': {
      'christmas': _six('Украшения', 'Игрушки', 'Открытки', 'Фигурки', 'Посуда', 'Упаковка'),
      'new-year': _six('Ёлочные игрушки', 'Открытки', 'Календари', 'Фигурки', 'Упаковка', 'Сувениры'),
      'easter': _six('Яйца', 'Открытки', 'Фигурки', 'Посуда', 'Декор', 'Упаковка'),
      'halloween': _six('Фигурки', 'Декор', 'Открытки', 'Костюмы', 'Упаковка', 'Сувениры'),
      'valentine': _six('Открытки', 'Сувениры', 'Упаковка', 'Фигурки', 'Декор', 'Промо'),
      'other': _six('День рождения', 'Юбилеи', 'Свадьбы', 'Фестивали', 'Национальные праздники', 'Сезонные'),
    },
    'discs': {
      'playstation': _six('PS1', 'PS2', 'PS3', 'PS4', 'PS5', 'PSP'),
      'xbox': _six('Xbox', 'Xbox 360', 'Xbox One', 'Series X', 'Classics', 'Special Editions'),
      'nintendo': _six('NES', 'SNES', 'GameCube', 'Wii', 'Wii U', 'Switch'),
      'pc': _six('CD-ROM', 'DVD-ROM', 'Blu-ray', 'Big Box', 'Jewel Case', "Collector's"),
      'sega': _six('Mega Drive', 'Saturn', 'Dreamcast', 'Game Gear', 'Master System', 'Arcade'),
      'retro': _six('CD', 'DVD', 'Cartridge', 'Floppy', 'Big Box', 'Special Editions'),
    },
  };

  static List<CatalogSectionDefinition> _six(
    String a,
    String b,
    String c,
    String d,
    String e,
    String f,
  ) => [
        CatalogSectionDefinition(id: _id(a), name: a),
        CatalogSectionDefinition(id: _id(b), name: b),
        CatalogSectionDefinition(id: _id(c), name: c),
        CatalogSectionDefinition(id: _id(d), name: d),
        CatalogSectionDefinition(id: _id(e), name: e),
        CatalogSectionDefinition(id: _id(f), name: f),
      ];

  static String _id(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9а-яё]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}
