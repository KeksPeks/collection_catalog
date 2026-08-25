import 'package:flutter/material.dart';
import 'catalog_direction_localization.dart';

class CatalogUiLocalization {
  CatalogUiLocalization._();

  static String categoryName(BuildContext context, String id) =>
      categoryNameForLocale(Localizations.localeOf(context), id);

  static String categoryNameForLocale(Locale locale, String id) =>
      CatalogDirectionLocalization.nameForLocale(locale, id);

  static String catalogName(BuildContext context, String id) =>
      catalogNameForLocale(Localizations.localeOf(context), id);

  static String catalogNameForLocale(Locale locale, String id) {
    // Внутри конкретного каталога показываем его название, а не название
    // более общего направления. Например, для LEGO должно быть «LEGO»,
    // а не «Конструкторы».
    const directNames = <String, String>{
      'lego': 'LEGO',
      'pokemon_tcg': 'Pokémon TCG',
    };
    final directName = directNames[id];
    if (directName != null) return directName;

    const aliases = <String, String>{
      'games': 'video_games',
      'discs': 'video_games',
      'movies': 'movies',
      'figurines': 'figurines',
      'coins': 'numismatics',
      'banknotes': 'banknotes',
    };
    return CatalogDirectionLocalization.nameForLocale(locale, aliases[id] ?? id);
  }

  static String catalogDescription(BuildContext context, String id) =>
      catalogDescriptionForLocale(Localizations.localeOf(context), id);

  static String catalogDescriptionForLocale(Locale locale, String id) {
    const aliases = <String, String>{
      'lego': 'constructors',
      'pokemon_tcg': 'cards',
      'games': 'video_games',
      'discs': 'video_games',
      'movies': 'movies',
      'figurines': 'figurines',
      'coins': 'numismatics',
      'banknotes': 'banknotes',
    };
    return CatalogDirectionLocalization.descriptionForLocale(locale, aliases[id] ?? id);
  }
}
