import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../data/wishlist_repository.dart';
import '../domain/entities/wishlist_item.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  final database = ref.watch(databaseProvider).requireValue;
  return WishlistRepository(database);
});

final wishlistProvider = FutureProvider<List<WishlistItem>>((ref) {
  return ref.watch(wishlistRepositoryProvider).getAll();
});
