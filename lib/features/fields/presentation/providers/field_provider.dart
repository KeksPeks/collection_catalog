import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'field_service_provider.dart';

import '../../domain/entities/field_definition.dart';



final fieldsProvider =

    FutureProvider.family<List<FieldDefinition>, String>(


  (ref, collectionId) async {


    final service =

        await ref.watch(
          fieldServiceProvider.future,
        );



    return service.getFields(
      collectionId,
    );


  },

);