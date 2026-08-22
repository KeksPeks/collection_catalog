import 'package:flutter/material.dart';

import '../../domain/conditions/condition_grade.dart';
import '../../domain/entities/field_definition.dart';
import '../../domain/types/field_type.dart';
import 'field_component.dart';

/// Компонент выбора состояния предмета из профильного набора градаций.
class ConditionFieldComponent extends FieldComponent {
  const ConditionFieldComponent();

  @override
  Widget build({
    required FieldDefinition definition,
    required String? value,
    required ValueChanged<String> onChanged,
  }) {
    final profile = _profileFor(definition.type);
    final grades = profile.grades;

    return DropdownButtonFormField<String>(
      value: grades.any((grade) => grade.code == value) ? value : null,
      decoration: InputDecoration(
        labelText: definition.label,
        border: const OutlineInputBorder(),
      ),
      items: grades
          .map(
            (grade) => DropdownMenuItem<String>(
              value: grade.code,
              child: Text(grade.label),
            ),
          )
          .toList(),
      onChanged: (nextValue) {
        if (nextValue != null) {
          onChanged(nextValue);
        }
      },
    );
  }

  ConditionProfile _profileFor(FieldType type) {
    switch (type) {
      case FieldType.conditionNumismatic:
        return ConditionProfile.numismatic;
      case FieldType.conditionBanknote:
        return ConditionProfile.banknote;
      case FieldType.conditionTradingCard:
        return ConditionProfile.tradingCard;
      case FieldType.conditionGame:
        return ConditionProfile.game;
      case FieldType.conditionGeneric:
        return ConditionProfile.generic;
      default:
        return ConditionProfile.generic;
    }
  }
}
