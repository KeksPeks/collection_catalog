import '../domain/entities/catalog_definition.dart';

/// Третий уровень структуры каталогов.
///
/// Каждый элемент второго уровня получает набор уточняющих подкатегорий.
/// Четвёртый уровень оставляется для конкретных предметов коллекции.
class CatalogThirdLevelDefaults {
  static List<CatalogSectionDefinition> apply(
    String catalogId,
    List<CatalogSectionDefinition> sections,
  ) {
    final names = _definitions[catalogId] ?? _generic;

    return sections.map((section) {
      if (section.children.isEmpty) return section;

      return CatalogSectionDefinition(
        id: section.id,
        name: section.name,
        children: section.children.map((child) {
          if (child.children.isNotEmpty) return child;
          return CatalogSectionDefinition(
            id: child.id,
            name: child.name,
            children: names
                .map((name) => CatalogSectionDefinition(id: '${child.id}-${_id(name)}', name: name))
                .toList(growable: false),
          );
        }).toList(growable: false),
      );
    }).toList(growable: false);
  }

  static String _id(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9а-яё]+', caseSensitive: false), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  static const _generic = <String>[
    'Стандартные',
    'Специальные',
    'Лимитированные',
    'Эксклюзивные',
    'Коллекционные',
    'Винтажные',
  ];

  static const _definitions = <String, List<String>>{
    'lego': ['Buildings', 'Vehicles', 'Characters', 'Accessories', 'Limited Editions', 'Collector Sets'],
    'pokemon_tcg': ['Base Set', 'Booster', 'Trainer', 'Energy', 'Special Rarity', 'Promotional'],
    'coins': ['Circulation', 'Commemorative', 'Proof', 'Uncirculated', 'Precious Metals', 'Mint Sets'],
    'banknotes': ['Regular Issue', 'Commemorative', 'Specimen', 'Replacement', 'Error Notes', 'Special Issue'],
    'philately': ['Definitive', 'Commemorative', 'Airmail', 'Official', 'Postage Due', 'Special Issue'],
    'figurines': ['Standard', 'Deluxe', 'Exclusive', 'Chase', 'Limited Edition', 'Convention'],
    'designer_toys': ['Standard', 'Artist Series', 'Collaboration', 'Exclusive', 'Limited', 'Secret'],
    'models': ['Civilian', 'Military', 'Racing', 'Historical', 'Limited Edition', 'Display'],
    'games': ['Action', 'Adventure', 'RPG', 'Strategy', 'Racing', 'Sports'],
    'consoles': ['Standard', 'Slim', 'Pro', 'Limited Edition', 'Special Edition', 'Bundle'],
    'comics': ['Regular Series', 'Limited Series', 'Annuals', 'Specials', 'Variants', 'Collected Editions'],
    'books': ['Hardcover', 'Paperback', 'First Edition', 'Limited Edition', 'Signed', 'Box Set'],
    'music': ['Studio Album', 'Live', 'Compilation', 'Single', 'Limited Edition', 'Promo'],
    'movies': ['Standard', 'Special Edition', 'Collector', 'SteelBook', 'Box Set', 'Limited'],
    'board_games': ['Base Game', 'Expansion', 'Promo', 'Deluxe', 'Collector', 'Limited'],
    'sports': ['Regular Issue', 'Rookie', 'All-Star', 'Championship', 'Limited', 'Memorabilia'],
    'autographs': ['Signed Photo', 'Signed Poster', 'Signed Document', 'Signed Card', 'Personalized', 'Authentic Memorabilia'],
    'pins': ['Standard', 'Limited', 'Exclusive', 'Event', 'Artist Series', 'Set'],
    'postcards': ['Standard', 'Real Photo', 'Chromolithograph', 'Artist Signed', 'Limited', 'Vintage'],
    'stickers': ['Standard', 'Holographic', 'Foil', 'Promo', 'Limited', 'Rare'],
    'playing_cards': ['Standard Deck', 'Luxury', 'Limited', 'Artist Edition', 'Casino', 'Collector'],
    'beverages': ['Bottle', 'Can', 'Glass', 'Promo', 'Seasonal', 'Limited Edition'],
    'lighters_tobacco': ['Regular', 'Limited', 'Anniversary', 'Artist Edition', 'Vintage', 'Collector'],
    'watches_jewelry': ['Standard', 'Limited Edition', 'Anniversary', 'Professional', 'Vintage', 'Collector'],
    'clothing': ['Standard', 'Limited', 'Collaboration', 'Vintage', 'Seasonal', 'Exclusive'],
    'instruments': ['Standard', 'Signature', 'Custom Shop', 'Limited Edition', 'Vintage', 'Artist Edition'],
    'militaria': ['Original', 'Reproduction', 'Award', 'Field Issue', 'Presentation', 'Historical'],
    'antiques': ['Original', 'Period', 'Restored', 'Signed', 'Rare', 'Museum Quality'],
    'art': ['Original', 'Limited Edition', 'Artist Proof', 'Signed', 'Numbered', 'Unique'],
    'advertising': ['Original', 'Promotional', 'Point of Sale', 'Limited', 'Vintage', 'Collector'],
    'holiday': ['Original', 'Limited', 'Vintage', 'Handmade', 'Promotional', 'Collector'],
    'discs': ['Standard', 'Limited Edition', 'Platinum', 'Special Edition', 'Collector', 'Promo'],
  };
}
