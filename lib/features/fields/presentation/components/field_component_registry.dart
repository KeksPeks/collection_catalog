import '../../domain/types/field_type.dart';

import 'boolean_field_component.dart';
import 'date_field_component.dart';
import 'decimal_field_component.dart';
import 'field_component.dart';
import 'integer_field_component.dart';
import 'text_field_component.dart';

/// Реестр компонентов ввода для типов полей.
class FieldComponentRegistry {
  const FieldComponentRegistry();

  FieldComponent component(FieldType type) {
    switch (type) {
      case FieldType.integer:
        return const IntegerFieldComponent();
      case FieldType.decimal:
        return const DecimalFieldComponent();
      case FieldType.date:
        return const DateFieldComponent();
      case FieldType.boolean:
        return const BooleanFieldComponent();
      case FieldType.text:
      default:
        return const TextFieldComponent();
    }
  }
}
