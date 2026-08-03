import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/factories/collection_factory.dart';
import '../../domain/services/collection_service.dart';

import 'collection_repository_provider.dart';



final collectionServiceProvider =
    Provider<CollectionService>((ref) {



  final repository =
      ref.watch(
        collectionRepositoryProvider,
      );



  return CollectionService(

    repository:
        repository,

    factory:
        CollectionFactory(),

  );


});