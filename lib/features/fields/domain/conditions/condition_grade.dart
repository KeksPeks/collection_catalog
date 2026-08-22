/// Описание градации состояния коллекционного предмета.
class ConditionGrade {
  final String code;
  final String label;
  final int order;

  const ConditionGrade({
    required this.code,
    required this.label,
    required this.order,
  });
}

/// Наборы градаций состояния для разных типов коллекций.
class ConditionGrades {
  const ConditionGrades._();

  static const numismatic = <ConditionGrade>[
    ConditionGrade(code: 'PROOF', label: 'Proof', order: 0),
    ConditionGrade(code: 'BU', label: 'Brilliant Uncirculated (BU)', order: 1),
    ConditionGrade(code: 'BUNC', label: 'Brilliant Uncirculated (BUNC)', order: 2),
    ConditionGrade(code: 'UNC', label: 'Uncirculated (UNC)', order: 3),
    ConditionGrade(code: 'AU', label: 'About Uncirculated (AU)', order: 4),
    ConditionGrade(code: 'XF', label: 'Extremely Fine (XF/EF)', order: 5),
    ConditionGrade(code: 'VF', label: 'Very Fine (VF)', order: 6),
    ConditionGrade(code: 'F', label: 'Fine (F)', order: 7),
    ConditionGrade(code: 'VG', label: 'Very Good (VG)', order: 8),
    ConditionGrade(code: 'G', label: 'Good (G)', order: 9),
    ConditionGrade(code: 'FAIR', label: 'Fair', order: 10),
    ConditionGrade(code: 'POOR', label: 'Poor', order: 11),
  ];

  static const banknote = <ConditionGrade>[
    ConditionGrade(code: 'UNC', label: 'Uncirculated (UNC)', order: 0),
    ConditionGrade(code: 'AU', label: 'About Uncirculated (AU)', order: 1),
    ConditionGrade(code: 'XF', label: 'Extremely Fine (XF)', order: 2),
    ConditionGrade(code: 'VF', label: 'Very Fine (VF)', order: 3),
    ConditionGrade(code: 'F', label: 'Fine (F)', order: 4),
    ConditionGrade(code: 'VG', label: 'Very Good (VG)', order: 5),
    ConditionGrade(code: 'G', label: 'Good (G)', order: 6),
    ConditionGrade(code: 'FAIR', label: 'Fair', order: 7),
    ConditionGrade(code: 'POOR', label: 'Poor', order: 8),
  ];

  static const tradingCard = <ConditionGrade>[
    ConditionGrade(code: 'NM', label: 'Near Mint (NM)', order: 0),
    ConditionGrade(code: 'NM_PLUS', label: 'Near Mint+ (NM+)', order: 1),
    ConditionGrade(code: 'LP', label: 'Lightly Played (LP)', order: 2),
    ConditionGrade(code: 'MP', label: 'Moderately Played (MP)', order: 3),
    ConditionGrade(code: 'HP', label: 'Heavily Played (HP)', order: 4),
    ConditionGrade(code: 'DMG', label: 'Damaged (DMG)', order: 5),
  ];

  static const game = <ConditionGrade>[
    ConditionGrade(code: 'SEALED', label: 'Sealed', order: 0),
    ConditionGrade(code: 'CIB', label: 'Complete in Box (CIB)', order: 1),
    ConditionGrade(code: 'COMPLETE', label: 'Complete', order: 2),
    ConditionGrade(code: 'BOXED', label: 'Boxed', order: 3),
    ConditionGrade(code: 'LOOSE', label: 'Loose', order: 4),
    ConditionGrade(code: 'DISC_ONLY', label: 'Disc Only', order: 5),
    ConditionGrade(code: 'CARTRIDGE_ONLY', label: 'Cartridge Only', order: 6),
    ConditionGrade(code: 'BOX_ONLY', label: 'Box Only', order: 7),
    ConditionGrade(code: 'MANUAL_ONLY', label: 'Manual Only', order: 8),
    ConditionGrade(code: 'DAMAGED', label: 'Damaged', order: 9),
  ];

  static const generic = <ConditionGrade>[
    ConditionGrade(code: 'NEW', label: 'New', order: 0),
    ConditionGrade(code: 'MINT', label: 'Mint', order: 1),
    ConditionGrade(code: 'EXCELLENT', label: 'Excellent', order: 2),
    ConditionGrade(code: 'GOOD', label: 'Good', order: 3),
    ConditionGrade(code: 'FAIR', label: 'Fair', order: 4),
    ConditionGrade(code: 'POOR', label: 'Poor', order: 5),
    ConditionGrade(code: 'DAMAGED', label: 'Damaged', order: 6),
  ];
}

/// Профиль градаций состояния, используемый типом поля.
enum ConditionProfile {
  numismatic,
  banknote,
  tradingCard,
  game,
  generic,
}

extension ConditionProfileX on ConditionProfile {
  List<ConditionGrade> get grades {
    switch (this) {
      case ConditionProfile.numismatic:
        return ConditionGrades.numismatic;
      case ConditionProfile.banknote:
        return ConditionGrades.banknote;
      case ConditionProfile.tradingCard:
        return ConditionGrades.tradingCard;
      case ConditionProfile.game:
        return ConditionGrades.game;
      case ConditionProfile.generic:
        return ConditionGrades.generic;
    }
  }
}
