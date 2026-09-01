import '../../../../core/network/api_client.dart';
import '../../domain/entities/collection.dart';
import '../../domain/repositories/collection_repository.dart';
import 'collection_repository_drift.dart';

/// Репозиторий каталога: сервер даёт централизованные данные,
/// а Drift хранит пользовательские загруженные коллекции.
///
/// Оба источника объединяются, чтобы скачанные каталоги всегда
/// отображались в разделе «Мои коллекции».
class CollectionRepositoryApi implements CollectionRepository {
  final CollectionApiClient api;
  final CollectionRepositoryDrift local;

  CollectionRepositoryApi({required this.api, required this.local});

  @override
  Future<List<Collection>> getCollections() async {
    final localCollections = await local.getCollections();

    try {
      final data = await api.getCollections();
      final rawItems = data['items'];
      if (rawItems is! List) {
        return localCollections;
      }

      final serverCollections = rawItems
          .whereType<Map>()
          .map((json) => _fromJson(Map<String, dynamic>.from(json)))
          .toList(growable: false);

      final result = <String, Collection>{
        for (final collection in serverCollections) collection.id: collection,
      };
      // Локальные записи имеют приоритет: именно они содержат templateId,
      // поля, разделы и пользовательские данные скачанного каталога.
      for (final collection in localCollections) {
        result[collection.id] = collection;
      }
      return result.values.toList(growable: false);
    } catch (_) {
      // Каталог пользователя должен оставаться доступным даже без API.
      return localCollections;
    }
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
