import '../../templates/data/catalog_template_registry.dart';
import '../../templates/domain/entities/template.dart';
import '../domain/entities/catalog_category_definition.dart';
import '../domain/entities/catalog_definition.dart';
import '../domain/entities/catalog_entry_definition.dart';

/// Единый централизованный реестр направлений каталога.
class CatalogRegistry {
  static List<CatalogCategoryDefinition> get categories => const [
        CatalogCategoryDefinition(id:'constructors',name:'Конструкторы',description:'Конструкторы и наборы.',catalogIds:['lego']),
        CatalogCategoryDefinition(id:'cards',name:'Коллекционные карточки',description:'Коллекционные карточки.',catalogIds:['pokemon_tcg']),
        CatalogCategoryDefinition(id:'numismatics',name:'Нумизматика',description:'Монеты и медали.',catalogIds:['coins']),
        CatalogCategoryDefinition(id:'banknotes',name:'Бонистика',description:'Банкноты и денежные знаки.',catalogIds:['banknotes']),
        CatalogCategoryDefinition(id:'philately',name:'Филателия',description:'Почтовые марки и связанные материалы.',catalogIds:['philately']),
        CatalogCategoryDefinition(id:'figurines',name:'Фигурки и игрушки',description:'Фигурки, игрушки и персонажи.',catalogIds:['figurines']),
        CatalogCategoryDefinition(id:'designer_toys',name:'Art Toys / Designer Toys',description:'Авторские и дизайнерские игрушки.',catalogIds:['designer_toys']),
        CatalogCategoryDefinition(id:'models',name:'Модели',description:'Масштабные и коллекционные модели.',catalogIds:['models']),
        CatalogCategoryDefinition(id:'video_games',name:'Видеоигры',description:'Видеоигры разных платформ.',catalogIds:['games']),
        CatalogCategoryDefinition(id:'consoles',name:'Игровые консоли и оборудование',description:'Консоли, аксессуары и оборудование.',catalogIds:['consoles']),
        CatalogCategoryDefinition(id:'comics',name:'Комиксы, манга и графические издания',description:'Комиксы, манга и графические издания.',catalogIds:['comics']),
        CatalogCategoryDefinition(id:'books',name:'Книги',description:'Книги и печатные издания.',catalogIds:['books']),
        CatalogCategoryDefinition(id:'music',name:'Музыка и аудио',description:'Музыкальные и аудиозаписи.',catalogIds:['music']),
        CatalogCategoryDefinition(id:'movies',name:'Фильмы и видео',description:'Фильмы и видеоматериалы.',catalogIds:['movies']),
        CatalogCategoryDefinition(id:'board_games',name:'Настольные игры и миниатюры',description:'Настольные игры и миниатюры.',catalogIds:['board_games']),
        CatalogCategoryDefinition(id:'sports',name:'Спортивные коллекции',description:'Спортивные карточки, памятные предметы и memorabilia.',catalogIds:['sports']),
        CatalogCategoryDefinition(id:'autographs',name:'Автографы и Memorabilia',description:'Автографы и памятные предметы.',catalogIds:['autographs']),
        CatalogCategoryDefinition(id:'pins',name:'Значки, Pins и эмблемы',description:'Значки, pins и эмблемы.',catalogIds:['pins']),
        CatalogCategoryDefinition(id:'postcards',name:'Открытки, фотографии и постеры',description:'Открытки, фотографии и постеры.',catalogIds:['postcards']),
        CatalogCategoryDefinition(id:'stickers',name:'Стикеры и наклейки',description:'Стикеры, наклейки и коллекционные листы.',catalogIds:['stickers']),
        CatalogCategoryDefinition(id:'playing_cards',name:'Игральные карты',description:'Колоды и отдельные игральные карты.',catalogIds:['playing_cards']),
        CatalogCategoryDefinition(id:'beverages',name:'Напитки и промо-коллекции',description:'Бутылки, банки и промо-материалы.',catalogIds:['beverages']),
        CatalogCategoryDefinition(id:'lighters_tobacco',name:'Зажигалки и табачные предметы',description:'Зажигалки и исторические табачные предметы.',catalogIds:['lighters_tobacco']),
        CatalogCategoryDefinition(id:'watches_jewelry',name:'Часы и ювелирные изделия',description:'Часы, украшения и ювелирные предметы.',catalogIds:['watches_jewelry']),
        CatalogCategoryDefinition(id:'clothing',name:'Одежда, обувь и аксессуары',description:'Коллекционная одежда, обувь и аксессуары.',catalogIds:['clothing']),
        CatalogCategoryDefinition(id:'instruments',name:'Музыкальные инструменты',description:'Коллекционные музыкальные инструменты.',catalogIds:['instruments']),
        CatalogCategoryDefinition(id:'militaria',name:'Военные, исторические и наградные предметы',description:'Военные, исторические предметы и награды.',catalogIds:['militaria']),
        CatalogCategoryDefinition(id:'antiques',name:'Антиквариат',description:'Антикварные предметы.',catalogIds:['antiques']),
        CatalogCategoryDefinition(id:'art',name:'Искусство',description:'Произведения искусства.',catalogIds:['art']),
        CatalogCategoryDefinition(id:'advertising',name:'Реклама и промо',description:'Рекламные и промо-материалы.',catalogIds:['advertising']),
        CatalogCategoryDefinition(id:'holiday',name:'Праздничные коллекции',description:'Праздничные и сезонные коллекции.',catalogIds:['holiday']),
      ];

  static List<CatalogDefinition> get all {
    final templates = CatalogTemplateRegistry.all;
    return [
      _lego(templates), _coins(templates),
      _sample(templates,'banknotes','Бонистика','country'),
      _sample(templates,'pokemon_tcg','Коллекционные карточки','series'),
      _sample(templates,'games','Видеоигры','platform'),
      _sample(templates,'movies','Фильмы и видео','year'),
      _sample(templates,'figurines','Фигурки и игрушки','series'),
      _sample(templates,'discs','Игровые диски','platform'),
      ..._emptyDirections(templates),
    ];
  }

  static List<CatalogDefinition> _emptyDirections(List<Template> templates) {
    const ids = ['philately','designer_toys','models','consoles','comics','books','music','board_games','sports','autographs','pins','postcards','stickers','playing_cards','beverages','lighters_tobacco','watches_jewelry','clothing','instruments','militaria','antiques','art','advertising','holiday'];
    return ids.map((id) {
      final template = templates.firstWhere((item) => item.id == id);
      final primary = template.fields.isEmpty ? '' : template.fields.first.id;
      return CatalogDefinition(id:id,name:template.name,description:template.description,templateId:id,template:template,primaryField:primary,totalItems:0,version:2,changes:const ['Добавлено направление в централизованный каталог.']);
    }).toList(growable:false);
  }

  static CatalogDefinition? byId(String id) => all.where((item) => item.id == id).firstOrNull;
  static CatalogCategoryDefinition? categoryById(String id) => categories.where((item) => item.id == id).firstOrNull;
  static List<CatalogDefinition> catalogsForCategory(String categoryId) => categoryById(categoryId)?.catalogIds.map(byId).whereType<CatalogDefinition>().toList(growable:false) ?? const [];

  static CatalogDefinition _lego(List<Template> templates) {
    final template = templates.firstWhere((item) => item.id == 'constructors');
    return CatalogDefinition(id:'lego',name:'LEGO',description:'Каталог конструкторов LEGO по сериям и моделям.',templateId:template.id,template:template,primaryField:'series',totalItems:8,version:2,changes:const ['Обновлена структура каталога и сохранена совместимость с локальными коллекциями.'],entries:const [
      CatalogEntryDefinition(id:'lego-1',title:'LEGO City Пожарная станция',primaryValue:'City',subtitle:'60414 • 2025',attributes:{'Серия':'City','Модель':'60414','Год':'2025','Деталей':'843'}),
      CatalogEntryDefinition(id:'lego-2',title:'LEGO Technic Ferrari SF-24',primaryValue:'Technic',subtitle:'42207 • 2025',attributes:{'Серия':'Technic','Модель':'42207','Год':'2025','Деталей':'1361'}),
      CatalogEntryDefinition(id:'lego-3',title:'LEGO Icons Букет цветов',primaryValue:'Icons',subtitle:'10280 • 2021',attributes:{'Серия':'Icons','Модель':'10280','Год':'2021','Деталей':'756'}),
      CatalogEntryDefinition(id:'lego-4',title:'LEGO Star Wars Millennium Falcon',primaryValue:'Star Wars',subtitle:'75375 • 2024',attributes:{'Серия':'Star Wars','Модель':'75375','Год':'2024','Деталей':'921'}),
      CatalogEntryDefinition(id:'lego-5',title:'LEGO Friends Дом на озере',primaryValue:'Friends',subtitle:'42625 • 2024',attributes:{'Серия':'Friends','Модель':'42625','Год':'2024','Деталей':'326'}),
      CatalogEntryDefinition(id:'lego-6',title:'LEGO Harry Potter Хогвартс',primaryValue:'Harry Potter',subtitle:'76435 • 2024',attributes:{'Серия':'Harry Potter','Модель':'76435','Год':'2024','Деталей':'1732'}),
      CatalogEntryDefinition(id:'lego-7',title:'LEGO NINJAGO Храм',primaryValue:'NINJAGO',subtitle:'71814 • 2024',attributes:{'Серия':'NINJAGO','Модель':'71814','Год':'2024','Деталей':'1192'}),
      CatalogEntryDefinition(id:'lego-8',title:'LEGO DUPLO Семейный дом',primaryValue:'DUPLO',subtitle:'10983 • 2023',attributes:{'Серия':'DUPLO','Модель':'10983','Год':'2023','Деталей':'40'}),
    ]);
  }

  static CatalogDefinition _coins(List<Template> templates) {
    final template = templates.firstWhere((item) => item.id == 'coins');
    return CatalogDefinition(id:'coins',name:'Монеты',description:'Каталог монет по странам, типам чеканки и годам.',templateId:template.id,template:template,primaryField:'country',totalItems:8,version:2,changes:const ['Страны показываются сразу при входе в каталог; убрана лишняя группа «Страны».'],entries:const [
      CatalogEntryDefinition(id:'coin-1',title:'2 евро Германия',primaryValue:'Германия',subtitle:'2024 • регулярный чекан',attributes:{'Страна':'Германия','Категория чеканки':'Регулярный чекан','Год':'2024','Серия':'Регулярные выпуски','Номинал':'2 EUR','Редкость':'Обычная'},sectionPath:['germany','regular']),
      CatalogEntryDefinition(id:'coin-2',title:'1 евро Италия',primaryValue:'Италия',subtitle:'2023 • регулярный чекан',attributes:{'Страна':'Италия','Категория чеканки':'Регулярный чекан','Год':'2023','Серия':'Регулярные выпуски','Номинал':'1 EUR','Редкость':'Обычная'},sectionPath:['italy','regular']),
      CatalogEntryDefinition(id:'coin-3',title:'2 евро Франция',primaryValue:'Франция',subtitle:'2022 • юбилейная',attributes:{'Страна':'Франция','Категория чеканки':'Юбилейная','Год':'2022','Серия':'Юбилейные выпуски','Номинал':'2 EUR','Редкость':'Обычная'},sectionPath:['france','commemorative']),
      CatalogEntryDefinition(id:'coin-4',title:'10 рублей Россия',primaryValue:'Россия',subtitle:'2020 • памятная',attributes:{'Страна':'Россия','Категория чеканки':'Памятная','Год':'2020','Серия':'Города воинской славы','Номинал':'10 RUB','Редкость':'Обычная'},sectionPath:['russia','commemorative']),
      CatalogEntryDefinition(id:'coin-5',title:'1 рубль Россия',primaryValue:'Россия',subtitle:'2021 • регулярный чекан',attributes:{'Страна':'Россия','Категория чеканки':'Регулярный чекан','Год':'2021','Серия':'Регулярные выпуски','Номинал':'1 RUB','Редкость':'Обычная'},sectionPath:['russia','regular']),
      CatalogEntryDefinition(id:'coin-6',title:'2 рубля Россия',primaryValue:'Россия',subtitle:'2022 • регулярный чекан',attributes:{'Страна':'Россия','Категория чеканки':'Регулярный чекан','Год':'2022','Серия':'Регулярные выпуски','Номинал':'2 RUB','Редкость':'Обычная'},sectionPath:['russia','regular']),
      CatalogEntryDefinition(id:'coin-7',title:'5 рублей Россия',primaryValue:'Россия',subtitle:'2023 • регулярный чекан',attributes:{'Страна':'Россия','Категория чеканки':'Регулярный чекан','Год':'2023','Серия':'Регулярные выпуски','Номинал':'5 RUB','Редкость':'Редкая'},sectionPath:['russia','regular']),
      CatalogEntryDefinition(id:'coin-8',title:'3 рубля Россия',primaryValue:'Россия',subtitle:'2024 • серебро',attributes:{'Страна':'Россия','Категория чеканки':'Драгоценные металлы','Год':'2024','Серия':'Памятные серебряные','Номинал':'3 RUB','Редкость':'Редкая'},sectionPath:['russia','precious']),
    ],sections:const [
      CatalogSectionDefinition(id:'russia',name:'Россия',children:[CatalogSectionDefinition(id:'regular',name:'Регулярный чекан'),CatalogSectionDefinition(id:'commemorative',name:'Памятные и юбилейные'),CatalogSectionDefinition(id:'precious',name:'Драгоценные металлы')]),
      CatalogSectionDefinition(id:'germany',name:'Германия',children:[CatalogSectionDefinition(id:'regular',name:'Регулярный чекан')]),
      CatalogSectionDefinition(id:'italy',name:'Италия',children:[CatalogSectionDefinition(id:'regular',name:'Регулярный чекан')]),
      CatalogSectionDefinition(id:'france',name:'Франция',children:[CatalogSectionDefinition(id:'commemorative',name:'Памятные и юбилейные')]),
    ]);
  }

  static CatalogDefinition _sample(List<Template> templates,String id,String name,String primary) {
    final template = templates.firstWhere((item) => item.id == id);
    return CatalogDefinition(id:id,name:name,description:template.description,templateId:id,template:template,primaryField:primary,totalItems:0,version:2,changes:const ['Структура направления обновлена; данные каталога остаются централизованными.']);
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
