import 'package:flutter/material.dart';

import '../../domain/entities/field_definition.dart';
import 'field_component.dart';

class TextFieldComponent extends FieldComponent {

  const TextFieldComponent();

  @override
  Widget build({

    required FieldDefinition definition,

    required String? value,

    required ValueChanged<String> onChanged,

  }) {

    return TextFormField(

      initialValue: value,

      decoration: InputDecoration(

        labelText: definition.label,

        border: const OutlineInputBorder(),

      ),

      onChanged: onChanged,

    );

  }

}