import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../data/repositories/collection_repository_drift.dart';

import '../../domain/repositories/collection_repository.dart';


import '../../../../core/database/database_provider.dart';




final collectionRepositoryProvider =


    Provider<CollectionRepository>((ref) {



  final databaseAsync =

      ref.watch(
        databaseProvider,
      );



  return databaseAsync.when(



    data: (database){


      return CollectionRepositoryDrift(
        database,
      );


    },



    loading: (){


      throw Exception(
        'Database loading',
      );


    },



    error: (error,stack){


      throw error;


    },


  );


});