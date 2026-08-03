import '../entities/collection_field.dart';

/// Репозиторий работы с полями коллекции.
///
/// Пока используется временная память.
/// После подключения Drift реализация будет заменена
/// на database repository.
abstract class CollectionFieldRepository {


  /// Получить все поля коллекции.
  Future<List<CollectionField>> getByCollection(
    String collectionId,
  );


  /// Добавить поле в коллекцию.
  Future<void> add(
    CollectionField field,
  );


  /// Обновить поле.
  Future<void> update(
    CollectionField field,
  );


  /// Удалить поле.
  Future<void> delete(
    String id,
  );

}