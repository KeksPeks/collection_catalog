import '../entities/template.dart';

import '../../../collections/domain/entities/collection.dart';



class TemplateFactory {


  Collection createCollection({


    required Template template,


    required String name,


  }) {


    final now = DateTime.now();



    return Collection(


      id:
          now.microsecondsSinceEpoch.toString(),



      name:
          name,



      templateId:
          template.id,



      fields:
          template.fields,



      createdAt:
          now,



      updatedAt:
          now,


    );


  }


}