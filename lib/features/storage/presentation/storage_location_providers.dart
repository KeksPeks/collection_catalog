import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../data/repositories/storage_location_repository_drift.dart';
import '../domain/entities/storage_location.dart';

final storageLocationRepositoryProvider = Provider<StorageLocationRepositoryDrift>((ref) {
  final database = ref.watch(databaseProvider).requireValue;
  return StorageLocationRepositoryDrift(database);
});

final storageLocationsProvider = FutureProvider<List<StorageLocation>>((ref) async {
  final database = await ref.watch(databaseProvider.future);
  return StorageLocationRepositoryDrift(database).getAll();
});

final itemStorageLocationProvider = FutureProvider.family<String, String>((ref, itemId) async {
  final database = await ref.watch(databaseProvider.future);
  final repository = StorageLocationRepositoryDrift(database);
  final location = await repository.getItemLocation(itemId);
  if (location == null) return '';
  return repository.getPath(location.id);
});
