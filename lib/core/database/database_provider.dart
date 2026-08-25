import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import 'database_connection.dart';

final databaseProvider = FutureProvider<AppDatabase>((ref) async {
  ref.keepAlive();

  final connection = await openDatabaseConnection();
  final database = AppDatabase(connection);

  // Восстанавливаем дополнительные таблицы даже в базе, где schemaVersion
  // уже была записана промежуточной версией приложения.
  await database.ensureCatalogItemTables();
  await database.ensureStorageTables();

  return database;
});
