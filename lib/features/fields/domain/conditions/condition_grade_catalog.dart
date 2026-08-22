import 'condition_grade.dart';

/// Профиль шкалы состояния для конкретного направления.
class ConditionGradeCatalog {
  const ConditionGradeCatalog._();

  static const coins = <ConditionGrade>[
    ConditionGrade.unc,
    ConditionGrade.bunc,
    ConditionGrade.vf,
    ConditionGrade.xf,
    ConditionGrade.au,
    ConditionGrade.proof,
    ConditionGrade.bu,
    ConditionGrade.circulated,
    ConditionGrade.damaged,
  ];

  static const cards = <ConditionGrade>[
    ConditionGrade.sealed,
    ConditionGrade.nm,
    ConditionGrade.lp,
    ConditionGrade.mp,
    ConditionGrade.hp,
    ConditionGrade.dmg,
  ];

  static const games = <ConditionGrade>[
    ConditionGrade.sealed,
    ConditionGrade.cib,
    ConditionGrade.complete,
    ConditionGrade.discOnly,
    ConditionGrade.boxOnly,
    ConditionGrade.manualOnly,
    ConditionGrade.missingParts,
    ConditionGrade.opened,
  ];

  static const general = <ConditionGrade>[
    ConditionGrade.mint,
    ConditionGrade.excellent,
    ConditionGrade.veryGood,
    ConditionGrade.good,
    ConditionGrade.fair,
    ConditionGrade.poor,
    ConditionGrade.damaged,
  ];

  /// Возвращает шкалу по ID коллекции.
  ///
  /// Каталоги, созданные из шаблона, имеют ID вида `<template>_<timestamp>`.
  /// Для старых/пользовательских каталогов используется универсальная шкала.
  static List<ConditionGrade> forCollection(String collectionId) {
    final id = collectionId.toLowerCase();
    if (id.startsWith('coins_') || id == 'coins') return coins;
    if (id.startsWith('pokemon_tcg_') || id.startsWith('pokemon_cards_') || id == 'pokemon_tcg') return cards;
    if (id.startsWith('games_') || id.startsWith('discs_') || id == 'games' || id == 'discs') return games;
    return general;
  }
}
