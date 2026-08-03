import '../../../../shared/domain/entities/entity.dart';

/// Значение конкретного поля элемента коллекции.
class FieldValue extends Entity {
  /// Элемент коллекции.
  final String itemId;

  /// Поле, которому принадлежит значение.
  final String fieldId;

  /// Текстовое значение.
  final String? textValue;

  /// Целое число.
  final int? intValue;

  /// Дробное число.
  final double? doubleValue;

  /// Логическое значение.
  final bool? boolValue;

  /// Дата.
  final DateTime? dateValue;

  /// Ссылка на запись справочника.
  final String? dictionaryId;

  /// Ссылка на другой объект.
  final String? referenceId;

  const FieldValue({
    required super.id,
    required this.itemId,
    required this.fieldId,
    this.textValue,
    this.intValue,
    this.doubleValue,
    this.boolValue,
    this.dateValue,
    this.dictionaryId,
    this.referenceId,
  });

  FieldValue copyWith({
    String? itemId,
    String? fieldId,
    String? textValue,
    int? intValue,
    double? doubleValue,
    bool? boolValue,
    DateTime? dateValue,
    String? dictionaryId,
    String? referenceId,
  }) {
    return FieldValue(
      id: id,
      itemId: itemId ?? this.itemId,
      fieldId: fieldId ?? this.fieldId,
      textValue: textValue ?? this.textValue,
      intValue: intValue ?? this.intValue,
      doubleValue: doubleValue ?? this.doubleValue,
      boolValue: boolValue ?? this.boolValue,
      dateValue: dateValue ?? this.dateValue,
      dictionaryId: dictionaryId ?? this.dictionaryId,
      referenceId: referenceId ?? this.referenceId,
    );
  }
}