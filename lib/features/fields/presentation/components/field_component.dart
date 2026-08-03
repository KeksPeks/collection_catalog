import 'package:flutter/widgets.dart';

import '../../domain/entities/field_definition.dart';

abstract class FieldComponent {

  const FieldComponent();

  Widget build({

    required FieldDefinition definition,

    required String? value,

    required ValueChanged<String> onChanged,

  });

}