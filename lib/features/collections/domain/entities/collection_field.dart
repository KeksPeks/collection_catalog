import '../../../../shared/domain/entities/entity.dart';

/// Поле, принадлежащее конкретной коллекции.
///
/// Именно эта сущность связывает коллекцию
/// и описание поля.
class CollectionField extends Entity {
  /// Коллекция.
  final String collectionId;

  /// Описание поля.
  final String fieldDefinitionId;

  /// Порядок отображения.
  final int order;

  /// Обязательное поле.
  final bool required;

  /// Показывать пользователю.
  final bool visible;

  /// Только чтение.
  final bool readOnly;

  /// Группа.
  final String? group;

  /// Вкладка.
  final String? tab;

  const CollectionField({
    required super.id,
    required this.collectionId,
    required this.fieldDefinitionId,
    this.order = 0,
    this.required = false,
    this.visible = true,
    this.readOnly = false,
    this.group,
    this.tab,
  });

  CollectionField copyWith({
    String? collectionId,
    String? fieldDefinitionId,
    int? order,
    bool? required,
    bool? visible,
    bool? readOnly,
    String? group,
    String? tab,
  }) {
    return CollectionField(
      id: id,
      collectionId: collectionId ?? this.collectionId,
      fieldDefinitionId:
          fieldDefinitionId ?? this.fieldDefinitionId,
      order: order ?? this.order,
      required: required ?? this.required,
      visible: visible ?? this.visible,
      readOnly: readOnly ?? this.readOnly,
      group: group ?? this.group,
      tab: tab ?? this.tab,
    );
  }
}