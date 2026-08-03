import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';

import '../../data/repositories/item_repository_drift.dart';

import '../../domain/repositories/item_repository.dart';
import '../../domain/services/item_service.dart';

/// Провайдер репозитория предметов.
///
/// Использует Drift-хранилище.
/// UI не зависит от способа хранения.
final itemRepositoryProvider = Provider<ItemRepository>(
  (ref) {
    final databaseAsync = ref.watch(
      databaseProvider,
    );

    return databaseAsync.when(
      data: (database) {
        return ItemRepositoryDrift(
          database,
        );
      },
      loading: () {
        throw Exception(
          'Database loading',
        );
      },
      error: (error, stack) {
        throw error;
      },
    );
  },
);

/// Провайдер сервиса предметов.
final itemServiceProvider = Provider<ItemService>(
  (ref) {
    return ItemService(
      ref.watch(
        itemRepositoryProvider,
      ),
    );
  },
);