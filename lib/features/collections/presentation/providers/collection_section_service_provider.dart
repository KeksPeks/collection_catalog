import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/collection_section_service.dart';

import 'collection_section_repository_provider.dart';



final collectionSectionServiceProvider =
    FutureProvider<CollectionSectionService>(
  (ref) async {

    final repository =
        await ref.watch(
          collectionSectionRepositoryProvider.future,
        );


    return CollectionSectionService(
      repository,
    );

  },
);