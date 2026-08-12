import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../fields/data/repositories/field_repository_drift.dart';
import '../../domain/factories/collection_factory.dart';
import '../../domain/services/collection_service.dart';
import 'collection_repository_provider.dart';

/// Провайдер сервиса коллекций.
final collectionServiceProvider = Provider<CollectionService>((ref) {
  final repository = ref.watch(collectionRepositoryProvider);
  final database = ref.watch(databaseProvider).requireValue;
  final fieldRepository = FieldRepositoryDrift(database);

  return CollectionService(
    repository: repository,
    factory: CollectionFactory(),
    fieldRepository: fieldRepository,
  );
});
