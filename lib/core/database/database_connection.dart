import 'dart:developer' as developer;
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';


/// Открытие подключения к базе данных Drift.
Future<QueryExecutor> openDatabaseConnection() async {
  final directory =
      await getApplicationDocumentsDirectory();

  final databaseFolder =
      Directory(
        p.join(
          directory.path,
          'database',
        ),
      );

  if (!databaseFolder.existsSync()) {
    databaseFolder.createSync(
      recursive: true,
    );
  }

  final file = File(
    p.join(
      databaseFolder.path,
      'collection_catalog.sqlite',
    ),
  );

  developer.log(
    'DATABASE PATH: ${file.path}',
    name: 'Database',
  );

  return NativeDatabase(
    file,
  );
}