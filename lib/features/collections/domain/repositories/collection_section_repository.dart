import '../entities/collection_section.dart';

/// Репозиторий разделов коллекции.
abstract class CollectionSectionRepository {
  /// Получить все разделы коллекции.
  Future<List<CollectionSection>> getSections(
    String collectionId,
  );

  /// Получить раздел по id.
  Future<CollectionSection?> getSection(
    String id,
  );

  /// Сохранить раздел.
  Future<void> saveSection(
    CollectionSection section,
  );

  /// Обновить раздел.
  Future<void> updateSection(
    CollectionSection section,
  );

  /// Удалить раздел.
  Future<void> deleteSection(
    String id,
  );
}