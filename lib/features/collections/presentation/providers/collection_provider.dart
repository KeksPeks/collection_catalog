import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../domain/entities/collection.dart';

import 'collection_service_provider.dart';




final collectionsProvider =
    FutureProvider<List<Collection>>(
        (ref) async {



  final service =
      ref.watch(
        collectionServiceProvider,
      );



  return service.getCollections();


});






final collectionProvider =
    FutureProvider.family<Collection?, String>(
        (ref,id) async {



  final service =
      ref.watch(
        collectionServiceProvider,
      );



  return service.getCollection(
    id,
  );


});