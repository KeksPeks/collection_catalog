import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/collection_catalog_app.dart';

void main() {
  runApp(
    const ProviderScope(
      child: CollectionCatalogApp(),
    ),
  );
}
