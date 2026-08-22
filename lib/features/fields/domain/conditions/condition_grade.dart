/// Градация состояния предмета коллекции.
///
/// Значения хранятся стабильными кодами, а пользовательский интерфейс
/// отображает локализованные названия. Каталог остаётся централизованным:
/// пользователь выбирает состояние, но не изменяет сам справочник.
enum ConditionGrade {
  /// Универсальное состояние без специализированной шкалы.
  unknown,

  // Нумизматика.
  unc,
  bunc,
  vf,
  xf,
  au,
  proof,
  bu,
  circulated,
  damaged,

  // Коллекционные карточки.
  nm,
  lp,
  mp,
  hp,
  dmg,
  sealed,

  // Игры / диски / издания.
  cib,
  complete,
  discOnly,
  boxOnly,
  manualOnly,
  missingParts,
  opened,

  // Общие коллекционные состояния.
  mint,
  excellent,
  veryGood,
  good,
  fair,
  poor,
}

extension ConditionGradeCode on ConditionGrade {
  String get code => name;
}
