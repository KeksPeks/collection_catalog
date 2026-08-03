import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/collection_section.dart';

import 'collection_section_service_provider.dart';



final collectionSectionsProvider =
    FutureProvider.family<List<CollectionSection>, String>(
  (
    ref,
    collectionId,
  ) async {


    final service =
        await ref.watch(
          collectionSectionServiceProvider.future,
        );


    return service.getSections(
      collectionId,
    );

  },
);
