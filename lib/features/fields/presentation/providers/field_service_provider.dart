import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../core/database/database_provider.dart';


import '../../domain/services/field_service.dart';

import '../../data/repositories/field_repository_drift.dart';



final fieldServiceProvider =

    FutureProvider<FieldService>(


  (ref) async {


    final database =

        await ref.watch(

          databaseProvider.future,

        );



    final repository =

        FieldRepositoryDrift(

          database,

        );



    return FieldService(

      repository,

    );


  },


);