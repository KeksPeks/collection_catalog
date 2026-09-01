import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/collection_repository_api.dart';
import '../../data/repositories/collection_repository_drift.dart';
import '../../domain/repositories/collection_repository.dart';

/// Репозиторий коллекций.
///
/// Каталог читается с существующего Collection Catalog API.
/// Запись пока остаётся локальной через Drift, чтобы не ломать
/// существующие сценарии редактирования до появления API-команд записи.
final collectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  final database = ref.watch(databaseProvider).requireValue;
  final localRepository = CollectionRepositoryDrift(database);

  return CollectionRepositoryApi(
    api: CollectionApiClient(),
    local: localRepository,
  );
});
