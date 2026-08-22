import 'package:flutter/material.dart';
import 'catalog_direction_localization.dart';

class CatalogUiLocalization {
  CatalogUiLocalization._();

  static String categoryName(BuildContext context, String id) =>
      CatalogDirectionLocalization.name(context, id);

  static String catalogName(BuildContext context, String id) {
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
    return CatalogDirectionLocalization.name(context, aliases[id] ?? id);
  }

  static String catalogDescription(BuildContext context, String id) =>
      CatalogDirectionLocalization.description(context, id);
}
