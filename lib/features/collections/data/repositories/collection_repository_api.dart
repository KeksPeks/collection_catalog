import '../../../../core/network/api_client.dart';
import '../../domain/entities/collection.dart';
import '../../domain/repositories/collection_repository.dart';
import 'collection_repository_drift.dart';

/// Репозиторий каталога: чтение каталога идёт с сервера,
/// локальные операции записи пока сохраняются через Drift.
///
/// Это позволяет подключить существующий API без потери уже
/// реализованного локального редактирования коллекций.
class CollectionRepositoryApi implements CollectionRepository {
  final CollectionApiClient api;
  final CollectionRepositoryDrift local;

  CollectionRepositoryApi({required this.api, required this.local});

  @override
  Future<List<Collection>> getCollections() async {
    final data = await api.getCollections();
    final rawItems = data['items'];

    if (rawItems is! List) {
      throw const FormatException('API /api/collections не содержит items');
    }

    return rawItems
        .whereType<Map>()
        .map((json) => _fromJson(Map<String, dynamic>.from(json)))
        .toList(growable: false);
  }

  @override
  Future<Collection?> getById(String id) async {
    final collections = await getCollections();
    for (final collection in collections) {
      if (collection.id == id) return collection;
    }
    return null;
  }

  @override
  Future<void> saveCollection(Collection collection) {
    return local.saveCollection(collection);
  }

  @override
  Future<void> deleteCollection(String id) {
    return local.deleteCollection(id);
  }

  Collection _fromJson(Map<String, dynamic> json) {
    final id = json['id'].toString();
    final name = json['name']?.toString() ?? '';

    return Collection(
      id: id,
      name: name,
      templateId: null,
      fields: const [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}
