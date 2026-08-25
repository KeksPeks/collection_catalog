import '../entities/storage_location.dart';

abstract interface class StorageLocationRepository {
  Future<List<StorageLocation>> getAll();
  Future<List<StorageLocation>> getChildren(String? parentId);
  Future<StorageLocation?> getById(String id);
  Future<String> getPath(String id);
  Future<void> save(StorageLocation location);
  Future<void> delete(String id);
  Future<void> assignItem(String itemId, String locationId);
  Future<void> removeItem(String itemId);
  Future<StorageLocation?> getItemLocation(String itemId);
}
