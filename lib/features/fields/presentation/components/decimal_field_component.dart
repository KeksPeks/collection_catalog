import 'package:flutter/material.dart';

import '../../domain/entities/field_definition.dart';
import 'field_component.dart';

/// Компонент ввода дробного числа.
class DecimalFieldComponent extends FieldComponent {
  const DecimalFieldComponent();

  @override
  Widget build({
    required FieldDefinition definition,
    required String? value,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      initialValue: value,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      decoration: InputDecoration(
        labelText: definition.label,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}
