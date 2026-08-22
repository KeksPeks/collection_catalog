import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../features/catalogs/data/catalog_ui_localization.dart';

/// Локализация интерфейса Collection Catalog.
class AppLocalizations {
  final Locale locale;
  const AppLocalizations(this.locale);

  static const delegate = _AppLocalizationsDelegate();
  static const supportedLocales = <Locale>[Locale('ru'),Locale('en'),Locale('de'),Locale('fr'),Locale('es'),Locale('it'),Locale('pt'),Locale('zh'),Locale('ja'),Locale('ko'),Locale('ar')];

  static AppLocalizations of(BuildContext context) => Localizations.of<AppLocalizations>(context, AppLocalizations) ?? const AppLocalizations(Locale('en'));
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

  String categoryName(String id) => CatalogUiLocalization.categoryNameForLocale(locale, id);
  String catalogName(String id) => CatalogUiLocalization.catalogNameForLocale(locale, id);
  String catalogDescriptionFor(String id) => CatalogUiLocalization.catalogDescriptionForLocale(locale, id);
  String recordsCount(int count) => '$count ${_plural(count, 'record', 'records')}';

  String _plural(int count, String one, String many) {
    if (locale.languageCode == 'ru') {
      final n = count.abs();
      if (n % 10 == 1 && n % 100 != 11) return 'запись';
      if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)) return 'записи';
      return 'записей';
    }
    return count == 1 ? one : many;
  }

  String _t(String key) {
    final values = _values[locale.languageCode] ?? _values['en']!;
    return values[key] ?? _values['en']![key] ?? key;
  }

  static const _languageNames = <String,String>{'ru':'Русский','en':'English','de':'Deutsch','fr':'Français','es':'Español','it':'Italiano','pt':'Português','zh':'中文','ja':'日本語','ko':'한국어','ar':'العربية'};

  static const _values = <String,Map<String,String>>{
    'ru': {'catalog':'Каталог','myCollections':'Мои коллекции','settings':'Настройки','favorites':'Избранное','categories':'Категории','search':'Поиск','searchHint':'Например: конструкторы, монеты, LEGO...','noResults':'Ничего не найдено','all':'Все','sort':'Сортировка','byName':'По названию','byType':'По типу','byPrimary':'По основному признаку','reverse':'Обратный порядок','back':'Назад','open':'Открыть','download':'Скачать','downloaded':'Загружено','favorite':'В избранное','removeFavorite':'Убрать из избранного','primaryAttribute':'Основной признак','records':'Записи','demoRecords':'Примеры записей','chooseCategory':'Выберите категорию','chooseCatalog':'Выберите каталог','automaticSorting':'Записи автоматически отсортированы по основному признаку.','constructors':'Конструкторы','coins':'Монеты','banknotes':'Банкноты','cards':'Карточки','games':'Игры','discs':'Диски','movies':'Фильмы','figurines':'Фигурки','language':'Язык','languageDescription':'Язык интерфейса приложения','appearance':'Оформление','languageSystem':'Язык устройства','noFavorites':'Избранного пока нет','noFavoritesDescription':'Добавляйте каталоги в избранное звездой.','catalogDescription':'Универсальный каталог коллекционных объектов.'},
    'en': {'catalog':'Catalog','myCollections':'My collections','settings':'Settings','favorites':'Favorites','categories':'Categories','search':'Search','searchHint':'For example: constructors, coins, LEGO...','noResults':'Nothing found','all':'All','sort':'Sort','byName':'By name','byType':'By type','byPrimary':'By primary attribute','reverse':'Reverse order','back':'Back','open':'Open','download':'Download','downloaded':'Downloaded','favorite':'Add to favorites','removeFavorite':'Remove from favorites','primaryAttribute':'Primary attribute','records':'Records','demoRecords':'Example records','chooseCategory':'Choose a category','chooseCatalog':'Choose a catalog','automaticSorting':'Records are automatically sorted by the primary attribute.','constructors':'Constructors','coins':'Coins','banknotes':'Banknotes','cards':'Cards','games':'Games','discs':'Discs','movies':'Movies','figurines':'Figurines','language':'Language','languageDescription':'Application interface language','appearance':'Appearance','languageSystem':'Device language','noFavorites':'No favorites yet','noFavoritesDescription':'Star catalogs to keep them in favorites.','catalogDescription':'Universal catalog of collectible objects.'},
    'de': {'catalog':'Katalog','myCollections':'Meine Sammlungen','settings':'Einstellungen','favorites':'Favoriten','categories':'Kategorien','search':'Suche','searchHint':'Zum Beispiel: Konstrukteure, Münzen, LEGO...','noResults':'Nichts gefunden','all':'Alle','sort':'Sortieren','byName':'Nach Name','byType':'Nach Typ','byPrimary':'Nach Hauptmerkmal','reverse':'Umgekehrte Reihenfolge','back':'Zurück','open':'Öffnen','download':'Herunterladen','downloaded':'Heruntergeladen','favorite':'Zu Favoriten','removeFavorite':'Aus Favoriten entfernen','primaryAttribute':'Hauptmerkmal','records':'Einträge','demoRecords':'Beispiele','chooseCategory':'Kategorie auswählen','chooseCatalog':'Katalog auswählen','automaticSorting':'Automatische Sortierung nach Hauptmerkmal.','language':'Sprache','languageDescription':'Sprache der Benutzeroberfläche','appearance':'Darstellung','languageSystem':'Gerätesprache','noFavorites':'Noch keine Favoriten','noFavoritesDescription':'Kataloge mit dem Stern speichern.','catalogDescription':'Universeller Katalog für Sammlerstücke.'},
    'fr': {'catalog':'Catalogue','myCollections':'Mes collections','settings':'Paramètres','favorites':'Favoris','categories':'Catégories','search':'Rechercher','searchHint':'Par exemple : constructeurs, pièces, LEGO...','noResults':'Aucun résultat','all':'Tous','sort':'Trier','byName':'Par nom','byType':'Par type','byPrimary':'Par attribut principal','reverse':'Ordre inverse','back':'Retour','open':'Ouvrir','download':'Télécharger','downloaded':'Téléchargé','favorite':'Ajouter aux favoris','removeFavorite':'Retirer des favoris','primaryAttribute':'Attribut principal','records':'Entrées','demoRecords':'Exemples','chooseCategory':'Choisir une catégorie','chooseCatalog':'Choisir un catalogue','automaticSorting':'Tri automatique par attribut principal.','language':'Langue','languageDescription':'Langue de l’interface','appearance':'Apparence','languageSystem':'Langue de l’appareil','noFavorites':'Aucun favori','noFavoritesDescription':'Ajoutez des catalogues avec l’étoile.','catalogDescription':'Catalogue universel d’objets de collection.'},
    'es': {'catalog':'Catálogo','myCollections':'Mis colecciones','settings':'Ajustes','favorites':'Favoritos','categories':'Categorías','search':'Buscar','searchHint':'Por ejemplo: constructores, monedas, LEGO...','noResults':'No se encontraron resultados','all':'Todos','sort':'Ordenar','byName':'Por nombre','byType':'Por tipo','byPrimary':'Por atributo principal','reverse':'Orden inverso','back':'Atrás','open':'Abrir','download':'Descargar','downloaded':'Descargado','favorite':'Añadir a favoritos','removeFavorite':'Quitar de favoritos','primaryAttribute':'Atributo principal','records':'Registros','demoRecords':'Ejemplos','chooseCategory':'Elige una categoría','chooseCatalog':'Elige un catálogo','automaticSorting':'Orden automático por atributo principal.','language':'Idioma','languageDescription':'Idioma de la interfaz','appearance':'Apariencia','languageSystem':'Idioma del dispositivo','noFavorites':'No hay favoritos','noFavoritesDescription':'Marca catálogos con una estrella.','catalogDescription':'Catálogo universal de objetos coleccionables.'},
    'it': {'catalog':'Catalogo','myCollections':'Le mie collezioni','settings':'Impostazioni','favorites':'Preferiti','categories':'Categorie','search':'Cerca','searchHint':'Ad esempio: costruzioni, monete, LEGO...','noResults':'Nessun risultato','all':'Tutti','sort':'Ordina','byName':'Per nome','byType':'Per tipo','byPrimary':'Per attributo principale','reverse':'Ordine inverso','back':'Indietro','open':'Apri','download':'Scarica','downloaded':'Scaricato','favorite':'Aggiungi ai preferiti','removeFavorite':'Rimuovi dai preferiti','primaryAttribute':'Attributo principale','records':'Record','demoRecords':'Esempi','chooseCategory':'Scegli una categoria','chooseCatalog':'Scegli un catalogo','automaticSorting':'Ordinamento automatico per attributo principale.','language':'Lingua','languageDescription':'Lingua dell’interfaccia','appearance':'Aspetto','languageSystem':'Lingua del dispositivo','noFavorites':'Nessun preferito','noFavoritesDescription':'Usa la stella per aggiungere cataloghi.','catalogDescription':'Catalogo universale di oggetti da collezione.'},
    'pt': {'catalog':'Catálogo','myCollections':'Minhas coleções','settings':'Definições','favorites':'Favoritos','categories':'Categorias','search':'Pesquisar','searchHint':'Por exemplo: construtores, moedas, LEGO...','noResults':'Nada encontrado','all':'Todos','sort':'Ordenar','byName':'Por nome','byType':'Por tipo','byPrimary':'Por atributo principal','reverse':'Ordem inversa','back':'Voltar','open':'Abrir','download':'Transferir','downloaded':'Transferido','favorite':'Adicionar aos favoritos','removeFavorite':'Remover dos favoritos','primaryAttribute':'Atributo principal','records':'Registos','demoRecords':'Exemplos','chooseCategory':'Escolha uma categoria','chooseCatalog':'Escolha um catálogo','automaticSorting':'Ordenação automática pelo atributo principal.','language':'Idioma','languageDescription':'Idioma da interface','appearance':'Aparência','languageSystem':'Idioma do dispositivo','noFavorites':'Sem favoritos','noFavoritesDescription':'Use a estrela para guardar catálogos.','catalogDescription':'Catálogo universal de objetos colecionáveis.'},
    'zh': {'catalog':'目录','myCollections':'我的收藏','settings':'设置','favorites':'收藏','categories':'分类','search':'搜索','searchHint':'例如：积木、硬币、LEGO...','noResults':'没有找到内容','all':'全部','sort':'排序','byName':'按名称','byType':'按类型','byPrimary':'按主要属性','reverse':'倒序','back':'返回','open':'打开','download':'下载','downloaded':'已下载','favorite':'加入收藏','removeFavorite':'取消收藏','primaryAttribute':'主要属性','records':'记录','demoRecords':'示例记录','chooseCategory':'选择分类','chooseCatalog':'选择目录','automaticSorting':'按主要属性自动排序。','language':'语言','languageDescription':'应用界面语言','appearance':'外观','languageSystem':'设备语言','noFavorites':'暂无收藏','noFavoritesDescription':'点击星标加入收藏。','catalogDescription':'通用收藏品目录。'},
    'ja': {'catalog':'カタログ','myCollections':'マイコレクション','settings':'設定','favorites':'お気に入り','categories':'カテゴリー','search':'検索','searchHint':'例：ブロック、コイン、LEGO...','noResults':'見つかりません','all':'すべて','sort':'並べ替え','byName':'名前順','byType':'種類順','byPrimary':'主要属性順','reverse':'逆順','back':'戻る','open':'開く','download':'ダウンロード','downloaded':'ダウンロード済み','favorite':'お気に入りに追加','removeFavorite':'お気に入りから削除','primaryAttribute':'主要属性','records':'記録','demoRecords':'サンプル記録','chooseCategory':'カテゴリーを選択','chooseCatalog':'カタログを選択','automaticSorting':'主要属性で自動並べ替え。','language':'言語','languageDescription':'アプリの表示言語','appearance':'外観','languageSystem':'端末の言語','noFavorites':'お気に入りはありません','noFavoritesDescription':'星をタップして追加します。','catalogDescription':'コレクション品のための汎用カタログ。'},
    'ko': {'catalog':'카탈로그','myCollections':'내 컬렉션','settings':'설정','favorites':'즐겨찾기','categories':'카테고리','search':'검색','searchHint':'예: 블록, 동전, LEGO...','noResults':'검색 결과가 없습니다','all':'전체','sort':'정렬','byName':'이름순','byType':'유형순','byPrimary':'주요 속성순','reverse':'역순','back':'뒤로','open':'열기','download':'다운로드','downloaded':'다운로드됨','favorite':'즐겨찾기에 추가','removeFavorite':'즐겨찾기에서 제거','primaryAttribute':'주요 속성','records':'항목','demoRecords':'예시 항목','chooseCategory':'카테고리 선택','chooseCatalog':'카탈로그 선택','automaticSorting':'주요 속성 기준 자동 정렬.','language':'언어','languageDescription':'앱 인터페이스 언어','appearance':'화면','languageSystem':'기기 언어','noFavorites':'즐겨찾기가 없습니다','noFavoritesDescription':'별표를 눌러 추가하세요.','catalogDescription':'수집품을 위한 범용 카탈로그.'},
    'ar': {'catalog':'الفهرس','myCollections':'مجموعاتي','settings':'الإعدادات','favorites':'المفضلة','categories':'الفئات','search':'بحث','searchHint':'مثال: المكعبات، العملات، LEGO...','noResults':'لم يتم العثور على نتائج','all':'الكل','sort':'فرز','byName':'حسب الاسم','byType':'حسب النوع','byPrimary':'حسب السمة الرئيسية','reverse':'ترتيب عكسي','back':'رجوع','open':'فتح','download':'تنزيل','downloaded':'تم التنزيل','favorite':'إضافة للمفضلة','removeFavorite':'إزالة من المفضلة','primaryAttribute':'السمة الرئيسية','records':'السجلات','demoRecords':'سجلات نموذجية','chooseCategory':'اختر فئة','chooseCatalog':'اختر فهرساً','automaticSorting':'ترتيب تلقائي حسب السمة الرئيسية.','language':'اللغة','languageDescription':'لغة واجهة التطبيق','appearance':'المظهر','languageSystem':'لغة الجهاز','noFavorites':'لا توجد مفضلات','noFavoritesDescription':'اضغط على النجمة لإضافة فهرس.','catalogDescription':'فهرس عام للمقتنيات.'},
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any((item) => item.languageCode == locale.languageCode);
  @override Future<AppLocalizations> load(Locale locale) => SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  @override bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
