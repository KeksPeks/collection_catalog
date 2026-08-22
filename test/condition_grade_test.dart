import 'package:collection_catalog/features/fields/domain/conditions/condition_grade.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('нумизматический профиль содержит основные градации', () {
    final codes = ConditionProfile.numismatic.grades.map((grade) => grade.code).toList();

    expect(codes, containsAll(<String>['UNC', 'BUNC', 'VF', 'PROOF']));
  });

  test('карточки используют NM, LP, HP и DMG', () {
    final codes = ConditionProfile.tradingCard.grades.map((grade) => grade.code).toList();

    expect(codes, containsAll(<String>['NM', 'LP', 'HP', 'DMG']));
  });

  test('игры используют Sealed, CIB, Complete и Disc Only', () {
    final codes = ConditionProfile.game.grades.map((grade) => grade.code).toList();

    expect(codes, containsAll(<String>['SEALED', 'CIB', 'COMPLETE', 'DISC_ONLY']));
  });
}
