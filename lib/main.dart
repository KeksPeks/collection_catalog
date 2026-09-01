import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/collection_catalog_app.dart';
import 'core/database/database_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  try {
    await container.read(databaseProvider.future);
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const CollectionCatalogApp(),
      ),
    );
  } catch (_) {
    container.dispose();
    rethrow;
  }
}
