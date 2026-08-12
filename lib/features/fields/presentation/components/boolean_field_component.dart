import 'package:flutter/material.dart';

import '../../domain/entities/field_definition.dart';
import 'field_component.dart';

/// Компонент логического значения.
class BooleanFieldComponent implements FieldComponent {
  const BooleanFieldComponent();

  @override
  Widget build({
    required FieldDefinition definition,
    required String? value,
    required ValueChanged<String> onChanged,
  }) {
    final checked = value == 'true';

    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(definition.label),
      value: checked,
      onChanged: (nextValue) {
        onChanged((nextValue ?? false).toString());
      },
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
