import '../../domain/types/field_type.dart';

import 'boolean_field_component.dart';
import 'condition_field_component.dart';
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

  /// Возвращает специализированный компонент с учётом семантики поля.
  ///
  /// Это позволяет старым каталогам, где «Состояние» было обычным текстом,
  /// автоматически получить новую шкалу без миграции пользовательских данных.
  FieldComponent componentForField({required FieldType type, required String id, required String label}) {
    final normalizedId = id.toLowerCase();
    final normalizedLabel = label.trim().toLowerCase();
    if (type == FieldType.text &&
        (normalizedId.endsWith('_condition') ||
            normalizedId == 'condition' ||
            normalizedLabel == 'состояние' ||
            normalizedLabel == 'condition')) {
      return const ConditionFieldComponent();
    }
    return component(type);
  }
}
