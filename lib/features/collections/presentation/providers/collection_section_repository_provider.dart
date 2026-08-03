import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';

import '../../data/repositories/collection_section_repository_drift.dart';
import '../../domain/repositories/collection_section_repository.dart';



final collectionSectionRepositoryProvider =
    FutureProvider<CollectionSectionRepository>(
  (ref) async {

    final database =
        await ref.watch(
          databaseProvider.future,
        );


    return CollectionSectionRepositoryDrift(
      database,
    );

  },
);