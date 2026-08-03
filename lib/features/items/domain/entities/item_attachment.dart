/// Файл, прикреплённый к предмету коллекции.
///
/// Может содержать:
/// - фотографию;
/// - PDF-документ;
/// - видео;
/// - архив;
/// - любой другой пользовательский файл.
class ItemAttachment {
  /// Идентификатор файла.
  final String id;

  /// Идентификатор предмета.
  final String itemId;

  /// Путь хранения файла.
  final String path;

  /// Тип файла.
///
/// Примеры:
/// - image
/// - pdf
/// - video
/// - archive
  final String type;

  const ItemAttachment({
    required this.id,
    required this.itemId,
    required this.path,
    required this.type,
  });

  ItemAttachment copyWith({
    String? itemId,
    String? path,
    String? type,
  }) {
    return ItemAttachment(
      id: id,
      itemId: itemId ?? this.itemId,
      path: path ?? this.path,
      type: type ?? this.type,
    );
  }
}