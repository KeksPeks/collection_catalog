import 'package:flutter/material.dart';

/// Локализованные названия 31 основных направлений каталога.
///
/// Структура каталога остаётся централизованной: локализация меняет только
/// отображаемый текст и не влияет на идентификаторы данных.
class CatalogDirectionLocalization {
  CatalogDirectionLocalization._();

  static const _names = <String, Map<String, String>>{
    'constructors': {'ru':'Конструкторы','en':'Construction sets','de':'Konstruktionssets','fr':'Sets de construction','es':'Sets de construcción','it':'Set da costruzione','pt':'Conjuntos de construção','zh':'积木套装','ja':'ブロックセット','ko':'블록 세트','ar':'مجموعات البناء'},
    'cards': {'ru':'Коллекционные карточки','en':'Collectible cards','de':'Sammelkarten','fr':'Cartes à collectionner','es':'Cartas coleccionables','it':'Carte da collezione','pt':'Cartas colecionáveis','zh':'收藏卡牌','ja':'コレクションカード','ko':'컬렉터 카드','ar':'بطاقات المقتنيات'},
    'numismatics': {'ru':'Нумизматика','en':'Numismatics','de':'Numismatik','fr':'Numismatique','es':'Numismática','it':'Numismatica','pt':'Numismática','zh':'钱币收藏','ja':'貨幣収集','ko':'화폐 수집','ar':'علم العملات'},
    'banknotes': {'ru':'Бонистика','en':'Banknotes','de':'Banknoten','fr':'Billets de banque','es':'Billetes','it':'Banconote','pt':'Notas','zh':'纸币收藏','ja':'紙幣収集','ko':'지폐 수집','ar':'الأوراق النقدية'},
    'philately': {'ru':'Филателия','en':'Philately','de':'Philatelie','fr':'Philatélie','es':'Filatelia','it':'Filatelia','pt':'Filatelia','zh':'集邮','ja':'切手収集','ko':'우표 수집','ar':'جمع الطوابع'},
    'figurines': {'ru':'Фигурки и игрушки','en':'Figurines and toys','de':'Figuren und Spielzeug','fr':'Figurines et jouets','es':'Figuras y juguetes','it':'Figure e giocattoli','pt':'Figuras e brinquedos','zh':'手办与玩具','ja':'フィギュア・玩具','ko':'피규어와 장난감','ar':'مجسمات وألعاب'},
    'designer_toys': {'ru':'Art Toys / Designer Toys','en':'Art Toys / Designer Toys','de':'Art Toys / Designer Toys','fr':'Art Toys / Designer Toys','es':'Art Toys / Designer Toys','it':'Art Toys / Designer Toys','pt':'Art Toys / Designer Toys','zh':'艺术玩具 / 设计师玩具','ja':'アートトイ / デザイナーズトイ','ko':'아트 토이 / 디자이너 토이','ar':'ألعاب فنية / ألعاب المصممين'},
    'models': {'ru':'Модели','en':'Models','de':'Modelle','fr':'Modèles','es':'Modelos','it':'Modelli','pt':'Modelos','zh':'模型','ja':'模型','ko':'모형','ar':'نماذج'},
    'video_games': {'ru':'Видеоигры','en':'Video games','de':'Videospiele','fr':'Jeux vidéo','es':'Videojuegos','it':'Videogiochi','pt':'Videojogos','zh':'电子游戏','ja':'ビデオゲーム','ko':'비디오 게임','ar':'ألعاب الفيديو'},
    'consoles': {'ru':'Игровые консоли и оборудование','en':'Game consoles and hardware','de':'Spielkonsolen und Hardware','fr':'Consoles et matériel de jeu','es':'Consolas y hardware','it':'Console e hardware','pt':'Consolas e hardware','zh':'游戏主机与设备','ja':'ゲーム機・周辺機器','ko':'게임 콘솔 및 장비','ar':'أجهزة الألعاب والمعدات'},
    'comics': {'ru':'Комиксы, манга и графические издания','en':'Comics, manga and graphic editions','de':'Comics, Manga und Graphic Novels','fr':'Bandes dessinées, manga et éditions graphiques','es':'Cómics, manga y ediciones gráficas','it':'Fumetti, manga ed edizioni grafiche','pt':'Quadrinhos, manga e edições gráficas','zh':'漫画、日漫与图像出版物','ja':'コミック・マンガ・グラフィック出版物','ko':'코믹스·망가·그래픽 출판물','ar':'القصص المصورة والمانغا والمنشورات الرسومية'},
    'books': {'ru':'Книги','en':'Books','de':'Bücher','fr':'Livres','es':'Libros','it':'Libri','pt':'Livros','zh':'书籍','ja':'書籍','ko':'도서','ar':'كتب'},
    'music': {'ru':'Музыка и аудио','en':'Music and audio','de':'Musik und Audio','fr':'Musique et audio','es':'Música y audio','it':'Musica e audio','pt':'Música e áudio','zh':'音乐与音频','ja':'音楽・オーディオ','ko':'음악 및 오디오','ar':'الموسيقى والصوت'},
    'movies': {'ru':'Фильмы и видео','en':'Movies and video','de':'Filme und Video','fr':'Films et vidéo','es':'Películas y vídeo','it':'Film e video','pt':'Filmes e vídeo','zh':'电影与视频','ja':'映画・動画','ko':'영화 및 비디오','ar':'الأفلام والفيديو'},
    'board_games': {'ru':'Настольные игры и миниатюры','en':'Board games and miniatures','de':'Brettspiele und Miniaturen','fr':'Jeux de société et miniatures','es':'Juegos de mesa y miniaturas','it':'Giochi da tavolo e miniature','pt':'Jogos de tabuleiro e miniaturas','zh':'桌游与微缩模型','ja':'ボードゲーム・ミニチュア','ko':'보드게임 및 미니어처','ar':'ألعاب الطاولة والمجسمات المصغرة'},
    'sports': {'ru':'Спортивные коллекции','en':'Sports collections','de':'Sport-Sammlungen','fr':'Collections sportives','es':'Colecciones deportivas','it':'Collezioni sportive','pt':'Coleções desportivas','zh':'体育收藏','ja':'スポーツコレクション','ko':'스포츠 컬렉션','ar':'المقتنيات الرياضية'},
    'autographs': {'ru':'Автографы и Memorabilia','en':'Autographs and memorabilia','de':'Autogramme und Memorabilia','fr':'Autographes et memorabilia','es':'Autógrafos y memorabilia','it':'Autografi e memorabilia','pt':'Autógrafos e memorabilia','zh':'签名与纪念品','ja':'サイン・メモラビリア','ko':'사인 및 메모러빌리아','ar':'التوقيعات والتذكارات'},
    'pins': {'ru':'Значки, Pins и эмблемы','en':'Badges, pins and emblems','de':'Abzeichen, Pins und Embleme','fr':'Badges, pins et emblèmes','es':'Insignias, pins y emblemas','it':'Distintivi, pin ed emblemi','pt':'Distintivos, pins e emblemas','zh':'徽章、Pins与标志','ja':'バッジ・ピンズ・エンブレム','ko':'배지·핀·엠블럼','ar':'الشارات والدبابيس والشعارات'},
    'postcards': {'ru':'Открытки, фотографии и постеры','en':'Postcards, photographs and posters','de':'Postkarten, Fotos und Poster','fr':'Cartes postales, photos et posters','es':'Postales, fotografías y pósteres','it':'Cartoline, fotografie e poster','pt':'Postais, fotografias e posters','zh':'明信片、照片与海报','ja':'ポストカード・写真・ポスター','ko':'엽서·사진·포스터','ar':'البطاقات البريدية والصور والملصقات'},
    'stickers': {'ru':'Стикеры и наклейки','en':'Stickers and decals','de':'Sticker und Aufkleber','fr':'Stickers et autocollants','es':'Stickers y pegatinas','it':'Sticker e adesivi','pt':'Stickers e autocolantes','zh':'贴纸与不干胶','ja':'ステッカー・シール','ko':'스티커 및 데칼','ar':'ملصقات ولاصقات'},
    'playing_cards': {'ru':'Игральные карты','en':'Playing cards','de':'Spielkarten','fr':'Cartes à jouer','es':'Naipes','it':'Carte da gioco','pt':'Cartas de jogar','zh':'扑克牌','ja':'トランプ','ko':'플레잉 카드','ar':'أوراق اللعب'},
    'beverages': {'ru':'Напитки и промо-коллекции','en':'Beverages and promotional collections','de':'Getränke und Werbesammlungen','fr':'Boissons et collections promotionnelles','es':'Bebidas y colecciones promocionales','it':'Bevande e collezioni promozionali','pt':'Bebidas e coleções promocionais','zh':'饮料与促销收藏','ja':'飲料・プロモーションコレクション','ko':'음료 및 프로모션 컬렉션','ar':'المشروبات والمقتنيات الترويجية'},
    'lighters_tobacco': {'ru':'Зажигалки и табачные предметы','en':'Lighters and tobacco items','de':'Feuerzeuge und Tabakwaren','fr':'Briquets et objets du tabac','es':'Mecheros y artículos de tabaco','it':'Accendini e articoli da tabacco','pt':'Isqueiros e artigos de tabaco','zh':'打火机与烟草收藏','ja':'ライター・喫煙具','ko':'라이터 및 담배 관련 수집품','ar':'الولاعات ومقتنيات التبغ'},
    'watches_jewelry': {'ru':'Часы и ювелирные изделия','en':'Watches and jewelry','de':'Uhren und Schmuck','fr':'Montres et bijoux','es':'Relojes y joyería','it':'Orologi e gioielli','pt':'Relógios e joias','zh':'钟表与珠宝','ja':'時計・ジュエリー','ko':'시계 및 주얼리','ar':'الساعات والمجوهرات'},
    'clothing': {'ru':'Одежда, обувь и аксессуары','en':'Clothing, footwear and accessories','de':'Kleidung, Schuhe und Accessoires','fr':'Vêtements, chaussures et accessoires','es':'Ropa, calzado y accesorios','it':'Abbigliamento, calzature e accessori','pt':'Roupas, calçados e acessórios','zh':'服装、鞋类与配饰','ja':'衣類・靴・アクセサリー','ko':'의류·신발·액세서리','ar':'الملابس والأحذية والإكسسوارات'},
    'instruments': {'ru':'Музыкальные инструменты','en':'Musical instruments','de':'Musikinstrumente','fr':'Instruments de musique','es':'Instrumentos musicales','it':'Strumenti musicali','pt':'Instrumentos musicais','zh':'乐器','ja':'楽器','ko':'악기','ar':'الآلات الموسيقية'},
    'militaria': {'ru':'Военные, исторические и наградные предметы','en':'Military, historical and award items','de':'Militärische, historische und Auszeichnungsobjekte','fr':'Objets militaires, historiques et décorations','es':'Objetos militares, históricos y condecoraciones','it':'Oggetti militari, storici e decorazioni','pt':'Objetos militares, históricos e condecorações','zh':'军事、历史与勋章收藏','ja':'軍事・歴史・勲章コレクション','ko':'군사·역사·훈장 수집품','ar':'المقتنيات العسكرية والتاريخية والأوسمة'},
    'antiques': {'ru':'Антиквариат','en':'Antiques','de':'Antiquitäten','fr':'Antiquités','es':'Antigüedades','it':'Antiquariato','pt':'Antiguidades','zh':'古董','ja':'アンティーク','ko':'골동품','ar':'التحف'},
    'art': {'ru':'Искусство','en':'Art','de':'Kunst','fr':'Art','es':'Arte','it':'Arte','pt':'Arte','zh':'艺术','ja':'美術','ko':'미술','ar':'الفن'},
    'advertising': {'ru':'Реклама и промо','en':'Advertising and promo','de':'Werbung und Promo','fr':'Publicité et promotion','es':'Publicidad y promoción','it':'Pubblicità e promo','pt':'Publicidade e promo','zh':'广告与促销','ja':'広告・プロモーション','ko':'광고 및 프로모션','ar':'الإعلانات والترويج'},
    'holiday': {'ru':'Праздничные коллекции','en':'Holiday collections','de':'Festtagskollektionen','fr':'Collections de fêtes','es':'Colecciones festivas','it':'Collezioni festive','pt':'Coleções festivas','zh':'节日收藏','ja':'ホリデーコレクション','ko':'기념일 컬렉션','ar':'المقتنيات الاحتفالية'},
  };

  static String name(BuildContext context, String id) {
    final language = Localizations.localeOf(context).languageCode;
    return _names[id]?[language] ?? _names[id]?['en'] ?? id;
  }

  static String description(BuildContext context, String id) {
    final nameValue = name(context, id);
    switch (Localizations.localeOf(context).languageCode) {
      case 'ru': return 'Централизованный каталог: $nameValue.';
      case 'de': return 'Zentraler Katalog: $nameValue.';
      case 'fr': return 'Catalogue centralisé : $nameValue.';
      case 'es': return 'Catálogo centralizado: $nameValue.';
      case 'it': return 'Catalogo centralizzato: $nameValue.';
      case 'pt': return 'Catálogo centralizado: $nameValue.';
      case 'zh': return '集中式目录：$nameValue。';
      case 'ja': return '中央カタログ：$nameValue。';
      case 'ko': return '중앙 카탈로그: $nameValue.';
      case 'ar': return 'فهرس مركزي: $nameValue.';
      default: return 'Centralized catalog: $nameValue.';
    }
  }
}
