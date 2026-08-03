import '../../domain/types/field_type.dart';

import 'field_component.dart';
import 'integer_field_component.dart';
import 'text_field_component.dart';

class FieldComponentRegistry {

  FieldComponent component(FieldType type) {

    switch (type) {

      case FieldType.integer:
        return const IntegerFieldComponent();

      case FieldType.text:
        return const TextFieldComponent();

      default:
        return const TextFieldComponent();

    }

  }

}