import '../../../fields/domain/entities/field_definition.dart';
import '../../../fields/domain/repositories/field_repository.dart';
import '../entities/collection.dart';
import '../factories/collection_factory.dart';
import '../repositories/collection_repository.dart';

/// Сервис управления коллекциями.
///
/// Коллекция хранит метаданные отдельно от таблицы полей, поэтому сервис
/// объединяет их перед передачей в интерфейс. Благодаря этому после
/// перезапуска приложения каталог не становится пустым.
class CollectionService {
  final CollectionRepository repository;
  final CollectionFactory factory;
  final FieldRepository fieldRepository;

  CollectionService({
    required this.repository,
    required this.factory,
    required this.fieldRepository,
  });

  Future<List<Collection>> getCollections() async {
    final collections = await repository.getCollections();
    return _attachFields(collections);
  }

  Future<Collection?> getCollection(String id) async {
    final collection = await repository.getById(id);
    if (collection == null) return null;
    final fields = await fieldRepository.getFields(id);
    return collection.copyWith(fields: fields);
  }

  Future<void> createCollection(Collection collection) async {
    final name = collection.name.trim();
    if (name.isEmpty) {
      throw Exception('Название коллекции пустое');
    }

    final normalized = collection.copyWith(name: name);
    await repository.saveCollection(normalized);

    for (final FieldDefinition field in normalized.fields) {
      await fieldRepository.saveField(field);
    }
  }

  Future<void> createNewCollection(String name) async {
    final collection = factory.create(name: name);
    await createCollection(collection);
  }

  Future<void> updateCollection(Collection collection) {
    return repository.saveCollection(collection);
  }

  Future<void> deleteCollection(String id) async {
    await repository.deleteCollection(id);
  }

  Future<List<Collection>> _attachFields(
    List<Collection> collections,
  ) async {
    final result = <Collection>[];

    for (final collection in collections) {
      final fields = await fieldRepository.getFields(collection.id);
      result.add(collection.copyWith(fields: fields));
    }

    return result;
  }
}
