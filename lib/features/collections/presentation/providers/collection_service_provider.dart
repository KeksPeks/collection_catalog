import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/factories/collection_factory.dart';
import '../../domain/services/collection_service.dart';
import '../../../fields/presentation/providers/field_service_provider.dart';
import 'collection_repository_provider.dart';

/// Провайдер сервиса коллекций.
final collectionServiceProvider = Provider<CollectionService>((ref) {
  final repository = ref.watch(collectionRepositoryProvider);
  final fieldService = ref.watch(fieldServiceProvider).requireValue;

  return CollectionService(
    repository: repository,
    factory: CollectionFactory(),
    fieldService: fieldService,
  );
});
