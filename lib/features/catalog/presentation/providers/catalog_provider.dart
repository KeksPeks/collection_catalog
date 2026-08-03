import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/catalog_item_model.dart';
import '../../data/sources/catalog_local_source.dart';

final catalogProvider = Provider<List<CatalogItemModel>>((ref) {
  final source = CatalogLocalSource();

  return source.getItems();
});