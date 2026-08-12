import '../entities/collection.dart';
import '../factories/collection_factory.dart';
import '../repositories/collection_repository.dart';
import '../../../fields/domain/services/field_service.dart';

/// Сервис управления коллекциями.
///
/// Создание коллекции и сохранение её структуры выполняются как одна
/// логическая операция, чтобы каталог не появлялся пустым после создания.
class CollectionService {
  final CollectionRepository repository;
  final CollectionFactory factory;
  final FieldService fieldService;

  CollectionService({
    required this.repository,
    required this.factory,
    required this.fieldService,
  });

  Future<List<Collection>> getCollections() {
    return repository.getCollections();
  }

  Future<Collection?> getCollection(String id) {
    return repository.getById(id);
  }

  Future<void> createCollection(Collection collection) async {
    final name = collection.name.trim();
    if (name.isEmpty) {
      throw Exception('Название коллекции пустое');
    }

    final normalized = collection.copyWith(name: name);
    await repository.saveCollection(normalized);

    for (final field in normalized.fields) {
      await fieldService.addField(field);
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
}
