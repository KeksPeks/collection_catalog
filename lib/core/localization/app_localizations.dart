import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Локализация основного интерфейса приложения.
/// Поддерживаются основные языки и автоматический fallback на английский.
class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static const delegate = _AppLocalizationsDelegate();

  static const supportedLocales = <Locale>[
    Locale('ru'),
    Locale('en'),
    Locale('de'),
    Locale('fr'),
    Locale('es'),
    Locale('it'),
    Locale('pt'),
    Locale('zh'),
    Locale('ja'),
    Locale('ko'),
    Locale('ar'),
  ];

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ??
      const AppLocalizations(Locale('en'));

  String get languageName => _languageNames[locale.languageCode] ?? 'English';

  String get catalog => _t('catalog');
  String get myCollections => _t('myCollections');
  String get settings => _t('settings');
  String get favorites => _t('favorites');
  String get categories => _t('categories');
  String get search => _t('search');
  String get searchHint => _t('searchHint');
  String get noResults => _t('noResults');
  String get all => _t('all');
  String get sort => _t('sort');
  String get byName => _t('byName');
  String get byType => _t('byType');
  String get byPrimary => _t('byPrimary');
  String get reverse => _t('reverse');
  String get back => _t('back');
  String get open => _t('open');
  String get download => _t('download');
  String get downloaded => _t('downloaded');
  String get favorite => _t('favorite');
  String get removeFavorite => _t('removeFavorite');
  String get primaryAttribute => _t('primaryAttribute');
  String get records => _t('records');
  String get demoRecords => _t('demoRecords');
  String get chooseCategory => _t('chooseCategory');
  String get chooseCatalog => _t('chooseCatalog');
  String get automaticSorting => _t('automaticSorting');
  String get constructors => _t('constructors');
  String get coins => _t('coins');
  String get banknotes => _t('banknotes');
  String get cards => _t('cards');
  String get games => _t('games');
  String get discs => _t('discs');
  String get movies => _t('movies');
  String get figurines => _t('figurines');
  String get language => _t('language');
  String get languageDescription => _t('languageDescription');
  String get appearance => _t('appearance');
  String get languageSystem => _t('languageSystem');
  String get noFavorites => _t('noFavorites');
  String get noFavoritesDescription => _t('noFavoritesDescription');
  String get catalogDescription => _t('catalogDescription');

  String categoryName(String id) => _t('category_$id');
  String catalogName(String id) => _t('catalog_$id');
  String catalogDescriptionFor(String id) => _t('description_$id');

  String recordsCount(int count) => '$count ${_plural(count, 'record', 'records')}';

  String _plural(int count, String one, String many) {
    if (locale.languageCode == 'ru') {
      final n = count.abs();
      if (n % 10 == 1 && n % 100 != 11) return 'запись';
      if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)) {
        return 'записи';
      }
      return 'записей';
    }
    return count == 1 ? one : many;
  }

  String _t(String key) {
    final language = _values[locale.languageCode] ?? _values['en']!;
    return language[key] ?? _values['en']![key] ?? key;
  }

  static const _languageNames = <String, String>{
    'ru': 'Русский',
    'en': 'English',
    'de': 'Deutsch',
    'fr': 'Français',
    'es': 'Español',
    'it': 'Italiano',
    'pt': 'Português',
    'zh': '中文',
    'ja': '日本語',
    'ko': '한국어',
    'ar': 'العربية',
  };

  static const Map<String, Map<String, String>> _values = {
    'ru': {
      'catalog': 'Каталог', 'myCollections': 'Мои коллекции', 'settings': 'Настройки',
      'favorites': 'Избранные коллекции', 'categories': 'Категории', 'search': 'Поиск',
      'searchHint': 'Например: конструкторы, монеты, LEGO...', 'noResults': 'Ничего не найдено',
      'all': 'Все', 'sort': 'Сортировка', 'byName': 'По названию', 'byType': 'По типу',
      'byPrimary': 'По основному признаку', 'reverse': 'Обратный порядок', 'back': 'Назад',
      'open': 'Открыть', 'download': 'Скачать', 'downloaded': 'Загружено', 'favorite': 'В избранное',
      'removeFavorite': 'Убрать из избранного', 'primaryAttribute': 'Основной признак',
      'records': 'Записи', 'demoRecords': 'Примеры записей', 'chooseCategory': 'Выберите категорию',
      'chooseCatalog': 'Выберите каталог', 'automaticSorting': 'Записи автоматически отсортированы по основному признаку.',
      'constructors': 'Конструкторы', 'coins': 'Монеты', 'banknotes': 'Банкноты', 'cards': 'Карточки',
      'games': 'Игры', 'discs': 'Диски', 'movies': 'Фильмы', 'figurines': 'Фигурки', 'language': 'Язык',
      'languageDescription': 'Язык интерфейса приложения', 'appearance': 'Оформление',
      'languageSystem': 'Язык устройства', 'noFavorites': 'Избранных коллекций пока нет',
      'noFavoritesDescription': 'Добавляйте каталоги в избранное звездой, чтобы вести отдельный список.',
      'catalogDescription': 'Универсальный каталог коллекционных объектов.',
      'category_constructors': 'Конструкторы и наборы', 'category_coins': 'Нумизматика',
      'category_banknotes': 'Бонистика', 'category_cards': 'Коллекционные карточки',
      'category_games': 'Видеоигры', 'category_discs': 'Игровые и музыкальные диски',
      'category_movies': 'Фильмы и видео', 'category_figurines': 'Фигурки и миниатюры',
      'catalog_lego': 'LEGO', 'catalog_coins': 'Монеты', 'catalog_banknotes': 'Банкноты',
      'catalog_pokemon_tcg': 'Pokémon TCG', 'catalog_games': 'Игры', 'catalog_discs': 'Диски',
      'catalog_movies': 'Фильмы', 'catalog_figurines': 'Фигурки',
      'description_lego': 'Каталог конструкторов LEGO по сериям и моделям.',
      'description_coins': 'Каталог монет по странам, типам чеканки и годам.',
      'description_banknotes': 'Каталог банкнот по странам, валютам и сериям.',
      'description_pokemon_tcg': 'Каталог коллекционных карточек Pokémon TCG.',
      'description_games': 'Каталог игр по платформам, поколениям и регионам.',
      'description_discs': 'Каталог игровых и музыкальных дисков.',
      'description_movies': 'Каталог фильмов по году, стране и жанру.',
      'description_figurines': 'Каталог фигурок по сериям, персонажам и производителям.',
    },
    'en': {
      'catalog': 'Catalog', 'myCollections': 'My collections', 'settings': 'Settings',
      'favorites': 'Favorite collections', 'categories': 'Categories', 'search': 'Search',
      'searchHint': 'For example: constructors, coins, LEGO...', 'noResults': 'Nothing found',
      'all': 'All', 'sort': 'Sort', 'byName': 'By name', 'byType': 'By type',
      'byPrimary': 'By primary attribute', 'reverse': 'Reverse order', 'back': 'Back',
      'open': 'Open', 'download': 'Download', 'downloaded': 'Downloaded', 'favorite': 'Add to favorites',
      'removeFavorite': 'Remove from favorites', 'primaryAttribute': 'Primary attribute',
      'records': 'Records', 'demoRecords': 'Example records', 'chooseCategory': 'Choose a category',
      'chooseCatalog': 'Choose a catalog', 'automaticSorting': 'Records are automatically sorted by the primary attribute.',
      'constructors': 'Constructors', 'coins': 'Coins', 'banknotes': 'Banknotes', 'cards': 'Cards',
      'games': 'Games', 'discs': 'Discs', 'movies': 'Movies', 'figurines': 'Figurines', 'language': 'Language',
      'languageDescription': 'Application interface language', 'appearance': 'Appearance',
      'languageSystem': 'Device language', 'noFavorites': 'No favorite collections yet',
      'noFavoritesDescription': 'Star catalogs to keep a separate favorites list.',
      'catalogDescription': 'Universal catalog of collectible objects.',
      'category_constructors': 'Constructors and sets', 'category_coins': 'Numismatics',
      'category_banknotes': 'Bonistics', 'category_cards': 'Trading cards', 'category_games': 'Video games',
      'category_discs': 'Game and music discs', 'category_movies': 'Movies and video', 'category_figurines': 'Figurines and miniatures',
      'catalog_lego': 'LEGO', 'catalog_coins': 'Coins', 'catalog_banknotes': 'Banknotes',
      'catalog_pokemon_tcg': 'Pokémon TCG', 'catalog_games': 'Games', 'catalog_discs': 'Discs',
      'catalog_movies': 'Movies', 'catalog_figurines': 'Figurines',
      'description_lego': 'LEGO construction sets organized by theme and model.',
      'description_coins': 'Coins organized by country, minting type and year.',
      'description_banknotes': 'Banknotes organized by country, currency and series.',
      'description_pokemon_tcg': 'Pokémon TCG collectible card catalog.',
      'description_games': 'Games organized by platform, generation and region.',
      'description_discs': 'Game and music disc catalog.', 'description_movies': 'Movies organized by year, country and genre.',
      'description_figurines': 'Figurines organized by series, character and manufacturer.',
    },
    'de': {'catalog':'Katalog','myCollections':'Meine Sammlungen','settings':'Einstellungen','favorites':'Favoriten','categories':'Kategorien','search':'Suche','searchHint':'Zum Beispiel: Konstrukteure, Münzen, LEGO...','noResults':'Nichts gefunden','all':'Alle','sort':'Sortieren','byName':'Nach Name','byType':'Nach Typ','byPrimary':'Nach Hauptmerkmal','reverse':'Umgekehrte Reihenfolge','back':'Zurück','open':'Öffnen','download':'Herunterladen','downloaded':'Heruntergeladen','favorite':'Zu Favoriten','removeFavorite':'Aus Favoriten entfernen','primaryAttribute':'Hauptmerkmal','records':'Einträge','demoRecords':'Beispiele','chooseCategory':'Kategorie auswählen','chooseCatalog':'Katalog auswählen','automaticSorting':'Einträge werden automatisch nach dem Hauptmerkmal sortiert.','constructors':'Konstrukteure','coins':'Münzen','banknotes':'Banknoten','cards':'Sammelkarten','games':'Spiele','discs':'Discs','movies':'Filme','figurines':'Figuren','language':'Sprache','languageDescription':'Sprache der Benutzeroberfläche','appearance':'Darstellung','languageSystem':'Gerätesprache','noFavorites':'Noch keine Favoriten','noFavoritesDescription':'Stern antippen, um Kataloge separat zu speichern.','catalogDescription':'Universeller Katalog für Sammlerstücke.','category_constructors':'Konstrukteure und Sets','category_coins':'Numismatik','category_banknotes':'Banknoten','category_cards':'Sammelkarten','category_games':'Videospiele','category_discs':'Spiel- und Musikdiscs','category_movies':'Filme und Video','category_figurines':'Figuren und Miniaturen','catalog_lego':'LEGO','catalog_coins':'Münzen','catalog_banknotes':'Banknoten','catalog_pokemon_tcg':'Pokémon TCG','catalog_games':'Spiele','catalog_discs':'Discs','catalog_movies':'Filme','catalog_figurines':'Figuren','description_lego':'LEGO-Sets nach Themen und Modellen.','description_coins':'Münzen nach Land, Prägeart und Jahr.','description_banknotes':'Banknoten nach Land, Währung und Serie.','description_pokemon_tcg':'Katalog für Pokémon TCG-Sammelkarten.','description_games':'Spiele nach Plattform, Generation und Region.','description_discs':'Katalog für Spiel- und Musikdiscs.','description_movies':'Filme nach Jahr, Land und Genre.','description_figurines':'Figuren nach Serie, Charakter und Hersteller.'},
    'fr': {'catalog':'Catalogue','myCollections':'Mes collections','settings':'Paramètres','favorites':'Collections favorites','categories':'Catégories','search':'Rechercher','searchHint':'Par exemple : constructeurs, pièces, LEGO...','noResults':'Aucun résultat','all':'Tous','sort':'Trier','byName':'Par nom','byType':'Par type','byPrimary':'Par attribut principal','reverse':'Ordre inverse','back':'Retour','open':'Ouvrir','download':'Télécharger','downloaded':'Téléchargé','favorite':'Ajouter aux favoris','removeFavorite':'Retirer des favoris','primaryAttribute':'Attribut principal','records':'Entrées','demoRecords':'Exemples','chooseCategory':'Choisir une catégorie','chooseCatalog':'Choisir un catalogue','automaticSorting':'Les entrées sont triées automatiquement selon l’attribut principal.','constructors':'Constructeurs','coins':'Pièces','banknotes':'Billets','cards':'Cartes','games':'Jeux','discs':'Disques','movies':'Films','figurines':'Figurines','language':'Langue','languageDescription':'Langue de l’interface','appearance':'Apparence','languageSystem':'Langue de l’appareil','noFavorites':'Aucune collection favorite','noFavoritesDescription':'Ajoutez des catalogues aux favoris avec l’étoile.','catalogDescription':'Catalogue universel d’objets de collection.','category_constructors':'Constructeurs et ensembles','category_coins':'Numismatique','category_banknotes':'Billets de banque','category_cards':'Cartes à collectionner','category_games':'Jeux vidéo','category_discs':'Disques de jeux et musique','category_movies':'Films et vidéo','category_figurines':'Figurines et miniatures','catalog_lego':'LEGO','catalog_coins':'Pièces','catalog_banknotes':'Billets','catalog_pokemon_tcg':'Pokémon TCG','catalog_games':'Jeux','catalog_discs':'Disques','catalog_movies':'Films','catalog_figurines':'Figurines','description_lego':'Sets LEGO classés par thème et modèle.','description_coins':'Pièces classées par pays, type de frappe et année.','description_banknotes':'Billets classés par pays, devise et série.','description_pokemon_tcg':'Catalogue de cartes Pokémon TCG.','description_games':'Jeux classés par plateforme, génération et région.','description_discs':'Catalogue de disques de jeux et de musique.','description_movies':'Films classés par année, pays et genre.','description_figurines':'Figurines classées par série, personnage et fabricant.'},
    'es': {'catalog':'Catálogo','myCollections':'Mis colecciones','settings':'Ajustes','favorites':'Colecciones favoritas','categories':'Categorías','search':'Buscar','searchHint':'Por ejemplo: constructores, monedas, LEGO...','noResults':'No se encontraron resultados','all':'Todos','sort':'Ordenar','byName':'Por nombre','byType':'Por tipo','byPrimary':'Por atributo principal','reverse':'Orden inverso','back':'Atrás','open':'Abrir','download':'Descargar','downloaded':'Descargado','favorite':'Añadir a favoritos','removeFavorite':'Quitar de favoritos','primaryAttribute':'Atributo principal','records':'Registros','demoRecords':'Ejemplos','chooseCategory':'Elige una categoría','chooseCatalog':'Elige un catálogo','automaticSorting':'Los registros se ordenan automáticamente por el atributo principal.','constructors':'Constructores','coins':'Monedas','banknotes':'Billetes','cards':'Cartas','games':'Juegos','discs':'Discos','movies':'Películas','figurines':'Figuras','language':'Idioma','languageDescription':'Idioma de la interfaz','appearance':'Apariencia','languageSystem':'Idioma del dispositivo','noFavorites':'No hay favoritos','noFavoritesDescription':'Marca catálogos con una estrella para mantener una lista separada.','catalogDescription':'Catálogo universal de objetos coleccionables.','category_constructors':'Constructores y sets','category_coins':'Numismática','category_banknotes':'Billetes','category_cards':'Cartas coleccionables','category_games':'Videojuegos','category_discs':'Discos de juegos y música','category_movies':'Películas y vídeo','category_figurines':'Figuras y miniaturas','catalog_lego':'LEGO','catalog_coins':'Monedas','catalog_banknotes':'Billetes','catalog_pokemon_tcg':'Pokémon TCG','catalog_games':'Juegos','catalog_discs':'Discos','catalog_movies':'Películas','catalog_figurines':'Figuras','description_lego':'Sets LEGO organizados por tema y modelo.','description_coins':'Monedas organizadas por país, tipo de acuñación y año.','description_banknotes':'Billetes organizados por país, moneda y serie.','description_pokemon_tcg':'Catálogo de cartas coleccionables Pokémon TCG.','description_games':'Juegos organizados por plataforma, generación y región.','description_discs':'Catálogo de discos de juegos y música.','description_movies':'Películas organizadas por año, país y género.','description_figurines':'Figuras organizadas por serie, personaje y fabricante.'},
    'it': {'catalog':'Catalogo','myCollections':'Le mie collezioni','settings':'Impostazioni','favorites':'Collezioni preferite','categories':'Categorie','search':'Cerca','searchHint':'Ad esempio: costruzioni, monete, LEGO...','noResults':'Nessun risultato','all':'Tutti','sort':'Ordina','byName':'Per nome','byType':'Per tipo','byPrimary':'Per attributo principale','reverse':'Ordine inverso','back':'Indietro','open':'Apri','download':'Scarica','downloaded':'Scaricato','favorite':'Aggiungi ai preferiti','removeFavorite':'Rimuovi dai preferiti','primaryAttribute':'Attributo principale','records':'Record','demoRecords':'Esempi','chooseCategory':'Scegli una categoria','chooseCatalog':'Scegli un catalogo','automaticSorting':'I record sono ordinati automaticamente per attributo principale.','constructors':'Costruzioni','coins':'Monete','banknotes':'Banconote','cards':'Carte','games':'Giochi','discs':'Dischi','movies':'Film','figurines':'Figure','language':'Lingua','languageDescription':'Lingua dell’interfaccia','appearance':'Aspetto','languageSystem':'Lingua del dispositivo','noFavorites':'Nessuna preferita','noFavoritesDescription':'Usa la stella per aggiungere cataloghi ai preferiti.','catalogDescription':'Catalogo universale di oggetti da collezione.','category_constructors':'Costruzioni e set','category_coins':'Numismatica','category_banknotes':'Banconote','category_cards':'Carte collezionabili','category_games':'Videogiochi','category_discs':'Dischi giochi e musica','category_movies':'Film e video','category_figurines':'Figure e miniature','catalog_lego':'LEGO','catalog_coins':'Monete','catalog_banknotes':'Banconote','catalog_pokemon_tcg':'Pokémon TCG','catalog_games':'Giochi','catalog_discs':'Dischi','catalog_movies':'Film','catalog_figurines':'Figure','description_lego':'Set LEGO organizzati per tema e modello.','description_coins':'Monete organizzate per paese, tipo di conio e anno.','description_banknotes':'Banconote organizzate per paese, valuta e serie.','description_pokemon_tcg':'Catalogo di carte Pokémon TCG.','description_games':'Giochi organizzati per piattaforma, generazione e regione.','description_discs':'Catalogo di dischi di giochi e musica.','description_movies':'Film organizzati per anno, paese e genere.','description_figurines':'Figure organizzate per serie, personaggio e produttore.'},
    'pt': {'catalog':'Catálogo','myCollections':'Minhas coleções','settings':'Definições','favorites':'Coleções favoritas','categories':'Categorias','search':'Pesquisar','searchHint':'Por exemplo: construtores, moedas, LEGO...','noResults':'Nada encontrado','all':'Todos','sort':'Ordenar','byName':'Por nome','byType':'Por tipo','byPrimary':'Por atributo principal','reverse':'Ordem inversa','back':'Voltar','open':'Abrir','download':'Transferir','downloaded':'Transferido','favorite':'Adicionar aos favoritos','removeFavorite':'Remover dos favoritos','primaryAttribute':'Atributo principal','records':'Registos','demoRecords':'Exemplos','chooseCategory':'Escolha uma categoria','chooseCatalog':'Escolha um catálogo','automaticSorting':'Os registos são ordenados automaticamente pelo atributo principal.','constructors':'Construções','coins':'Moedas','banknotes':'Notas','cards':'Cartas','games':'Jogos','discs':'Discos','movies':'Filmes','figurines':'Figuras','language':'Idioma','languageDescription':'Idioma da interface','appearance':'Aparência','languageSystem':'Idioma do dispositivo','noFavorites':'Sem favoritos','noFavoritesDescription':'Use a estrela para guardar catálogos numa lista separada.','catalogDescription':'Catálogo universal de objetos colecionáveis.','category_constructors':'Construções e conjuntos','category_coins':'Numismática','category_banknotes':'Notas','category_cards':'Cartas colecionáveis','category_games':'Jogos de vídeo','category_discs':'Discos de jogos e música','category_movies':'Filmes e vídeo','category_figurines':'Figuras e miniaturas','catalog_lego':'LEGO','catalog_coins':'Moedas','catalog_banknotes':'Notas','catalog_pokemon_tcg':'Pokémon TCG','catalog_games':'Jogos','catalog_discs':'Discos','catalog_movies':'Filmes','catalog_figurines':'Figuras','description_lego':'Conjuntos LEGO organizados por tema e modelo.','description_coins':'Moedas organizadas por país, tipo de cunhagem e ano.','description_banknotes':'Notas organizadas por país, moeda e série.','description_pokemon_tcg':'Catálogo de cartas Pokémon TCG.','description_games':'Jogos organizados por plataforma, geração e região.','description_discs':'Catálogo de discos de jogos e música.','description_movies':'Filmes organizados por ano, país e género.','description_figurines':'Figuras organizadas por série, personagem e fabricante.'},
    'zh': {'catalog':'目录','myCollections':'我的收藏','settings':'设置','favorites':'收藏夹','categories':'分类','search':'搜索','searchHint':'例如：积木、硬币、LEGO...','noResults':'没有找到内容','all':'全部','sort':'排序','byName':'按名称','byType':'按类型','byPrimary':'按主要属性','reverse':'倒序','back':'返回','open':'打开','download':'下载','downloaded':'已下载','favorite':'加入收藏','removeFavorite':'取消收藏','primaryAttribute':'主要属性','records':'记录','demoRecords':'示例记录','chooseCategory':'选择分类','chooseCatalog':'选择目录','automaticSorting':'记录会自动按主要属性排序。','constructors':'积木','coins':'硬币','banknotes':'纸币','cards':'卡牌','games':'游戏','discs':'光盘','movies':'电影','figurines':'模型','language':'语言','languageDescription':'应用界面语言','appearance':'外观','languageSystem':'设备语言','noFavorites':'暂无收藏','noFavoritesDescription':'点击星标，将目录加入单独的收藏列表。','catalogDescription':'通用收藏品目录。','category_constructors':'积木与套装','category_coins':'钱币收藏','category_banknotes':'纸币收藏','category_cards':'集换式卡牌','category_games':'电子游戏','category_discs':'游戏与音乐光盘','category_movies':'电影与视频','category_figurines':'模型与手办','catalog_lego':'LEGO','catalog_coins':'硬币','catalog_banknotes':'纸币','catalog_pokemon_tcg':'Pokémon TCG','catalog_games':'游戏','catalog_discs':'光盘','catalog_movies':'电影','catalog_figurines':'模型','description_lego':'按主题和型号整理的 LEGO 套装目录。','description_coins':'按国家、铸造类型和年份整理的硬币目录。','description_banknotes':'按国家、货币和系列整理的纸币目录。','description_pokemon_tcg':'Pokémon TCG 收藏卡牌目录。','description_games':'按平台、世代和地区整理的游戏目录。','description_discs':'游戏和音乐光盘目录。','description_movies':'按年份、国家和类型整理的电影目录。','description_figurines':'按系列、角色和制造商整理的模型目录。'},
    'ja': {'catalog':'カタログ','myCollections':'マイコレクション','settings':'設定','favorites':'お気に入りコレクション','categories':'カテゴリー','search':'検索','searchHint':'例：コンストラクター、コイン、LEGO...','noResults':'見つかりません','all':'すべて','sort':'並べ替え','byName':'名前順','byType':'種類順','byPrimary':'主要属性順','reverse':'逆順','back':'戻る','open':'開く','download':'ダウンロード','downloaded':'ダウンロード済み','favorite':'お気に入りに追加','removeFavorite':'お気に入りから削除','primaryAttribute':'主要属性','records':'記録','demoRecords':'サンプル記録','chooseCategory':'カテゴリーを選択','chooseCatalog':'カタログを選択','automaticSorting':'記録は主要属性で自動的に並べ替えられます。','constructors':'ブロック玩具','coins':'コイン','banknotes':'紙幣','cards':'カード','games':'ゲーム','discs':'ディスク','movies':'映画','figurines':'フィギュア','language':'言語','languageDescription':'アプリの表示言語','appearance':'外観','languageSystem':'端末の言語','noFavorites':'お気に入りはありません','noFavoritesDescription':'星をタップしてカタログをお気に入りに追加します。','catalogDescription':'コレクション品のための汎用カタログ。','category_constructors':'ブロックとセット','category_coins':'コイン収集','category_banknotes':'紙幣収集','category_cards':'トレーディングカード','category_games':'ビデオゲーム','category_discs':'ゲーム・音楽ディスク','category_movies':'映画・動画','category_figurines':'フィギュア・ミニチュア','catalog_lego':'LEGO','catalog_coins':'コイン','catalog_banknotes':'紙幣','catalog_pokemon_tcg':'Pokémon TCG','catalog_games':'ゲーム','catalog_discs':'ディスク','catalog_movies':'映画','catalog_figurines':'フィギュア','description_lego':'テーマとモデル別の LEGO セットカタログ。','description_coins':'国、鋳造種別、年別のコインカタログ。','description_banknotes':'国、通貨、シリーズ別の紙幣カタログ。','description_pokemon_tcg':'Pokémon TCG カードカタログ。','description_games':'プラットフォーム、世代、地域別のゲームカタログ。','description_discs':'ゲーム・音楽ディスクカタログ。','description_movies':'年、国、ジャンル別の映画カタログ。','description_figurines':'シリーズ、キャラクター、メーカー別のフィギュアカタログ。'},
    'ko': {'catalog':'카탈로그','myCollections':'내 컬렉션','settings':'설정','favorites':'즐겨찾기 컬렉션','categories':'카테고리','search':'검색','searchHint':'예: 블록, 동전, LEGO...','noResults':'검색 결과가 없습니다','all':'전체','sort':'정렬','byName':'이름순','byType':'유형순','byPrimary':'주요 속성순','reverse':'역순','back':'뒤로','open':'열기','download':'다운로드','downloaded':'다운로드됨','favorite':'즐겨찾기에 추가','removeFavorite':'즐겨찾기에서 제거','primaryAttribute':'주요 속성','records':'항목','demoRecords':'예시 항목','chooseCategory':'카테고리 선택','chooseCatalog':'카탈로그 선택','automaticSorting':'항목은 주요 속성을 기준으로 자동 정렬됩니다.','constructors':'블록','coins':'동전','banknotes':'지폐','cards':'카드','games':'게임','discs':'디스크','movies':'영화','figurines':'피규어','language':'언어','languageDescription':'앱 인터페이스 언어','appearance':'화면','languageSystem':'기기 언어','noFavorites':'즐겨찾기가 없습니다','noFavoritesDescription':'별표를 눌러 카탈로그를 별도 목록에 저장하세요.','catalogDescription':'수집품을 위한 범용 카탈로그.','category_constructors':'블록과 세트','category_coins':'화폐 수집','category_banknotes':'지폐 수집','category_cards':'트레이딩 카드','category_games':'비디오 게임','category_discs':'게임 및 음악 디스크','category_movies':'영화 및 비디오','category_figurines':'피규어 및 미니어처','catalog_lego':'LEGO','catalog_coins':'동전','catalog_banknotes':'지폐','catalog_pokemon_tcg':'Pokémon TCG','catalog_games':'게임','catalog_discs':'디스크','catalog_movies':'영화','catalog_figurines':'피규어','description_lego':'테마와 모델별 LEGO 세트 카탈로그.','description_coins':'국가, 주조 유형, 연도별 동전 카탈로그.','description_banknotes':'국가, 통화, 시리즈별 지폐 카탈로그.','description_pokemon_tcg':'Pokémon TCG 카드 카탈로그.','description_games':'플랫폼, 세대, 지역별 게임 카탈로그.','description_discs':'게임 및 음악 디스크 카탈로그.','description_movies':'연도, 국가, 장르별 영화 카탈로그.','description_figurines':'시리즈, 캐릭터, 제조사별 피규어 카탈로그.'},
    'ar': {'catalog':'الفهرس','myCollections':'مجموعاتي','settings':'الإعدادات','favorites':'المجموعات المفضلة','categories':'الفئات','search':'بحث','searchHint':'مثال: المكعبات، العملات، LEGO...','noResults':'لم يتم العثور على نتائج','all':'الكل','sort':'فرز','byName':'حسب الاسم','byType':'حسب النوع','byPrimary':'حسب السمة الرئيسية','reverse':'ترتيب عكسي','back':'رجوع','open':'فتح','download':'تنزيل','downloaded':'تم التنزيل','favorite':'إضافة للمفضلة','removeFavorite':'إزالة من المفضلة','primaryAttribute':'السمة الرئيسية','records':'السجلات','demoRecords':'سجلات نموذجية','chooseCategory':'اختر فئة','chooseCatalog':'اختر فهرساً','automaticSorting':'يتم ترتيب السجلات تلقائياً حسب السمة الرئيسية.','constructors':'مكعبات البناء','coins':'عملات','banknotes':'أوراق نقدية','cards':'بطاقات','games':'ألعاب','discs':'أقراص','movies':'أفلام','figurines':'مجسمات','language':'اللغة','languageDescription':'لغة واجهة التطبيق','appearance':'المظهر','languageSystem':'لغة الجهاز','noFavorites':'لا توجد مجموعات مفضلة','noFavoritesDescription':'اضغط على النجمة لإضافة الفهارس إلى قائمة منفصلة.','catalogDescription':'فهرس عام للمقتنيات.','category_constructors':'مكعبات ومجموعات','category_coins':'علم العملات','category_banknotes':'الأوراق النقدية','category_cards':'بطاقات التداول','category_games':'ألعاب الفيديو','category_discs':'أقراص الألعاب والموسيقى','category_movies':'الأفلام والفيديو','category_figurines':'المجسمات والمنمنمات','catalog_lego':'LEGO','catalog_coins':'عملات','catalog_banknotes':'أوراق نقدية','catalog_pokemon_tcg':'Pokémon TCG','catalog_games':'ألعاب','catalog_discs':'أقراص','catalog_movies':'أفلام','catalog_figurines':'مجسمات','description_lego':'فهرس مجموعات LEGO حسب السلسلة والطراز.','description_coins':'فهرس العملات حسب الدولة ونوع السك والسنة.','description_banknotes':'فهرس الأوراق النقدية حسب الدولة والعملة والسلسلة.','description_pokemon_tcg':'فهرس بطاقات Pokémon TCG.','description_games':'فهرس الألعاب حسب المنصة والجيل والمنطقة.','description_discs':'فهرس أقراص الألعاب والموسيقى.','description_movies':'فهرس الأفلام حسب السنة والدولة والنوع.','description_figurines':'فهرس المجسمات حسب السلسلة والشخصية والشركة المصنعة.'},
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((item) => item.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
