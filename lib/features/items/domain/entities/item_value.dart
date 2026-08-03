/// Значение пользовательского поля предмета.
///
/// Каждый предмет содержит произвольное количество значений.
///
/// Пример:
/// fieldId = country
/// value = Germany
///
/// fieldId = year
/// value = 1905
///
/// fieldId = material
/// value = Silver
class ItemValue {
  /// Идентификатор значения.
  final String id;

  /// Идентификатор предмета.
  final String itemId;

  /// Идентификатор поля.
  final String fieldId;

  /// Значение поля.
  ///
  /// Независимо от типа поля хранится как строка.
  /// Тип определяется FieldDefinition и преобразуется
  /// при отображении и редактировании.
  final String value;

  const ItemValue({
    required this.id,
    required this.itemId,
    required this.fieldId,
    required this.value,
  });

  ItemValue copyWith({
    String? itemId,
    String? fieldId,
    String? value,
  }) {
    return ItemValue(
      id: id,
      itemId: itemId ?? this.itemId,
      fieldId: fieldId ?? this.fieldId,
      value: value ?? this.value,
    );
  }
}