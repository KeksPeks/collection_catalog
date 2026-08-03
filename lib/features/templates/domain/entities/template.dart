import '../../../../shared/domain/entities/entity.dart';

import '../../../fields/domain/entities/field_definition.dart';



class Template extends Entity {


  // Название шаблона
  final String name;



  // Описание шаблона
  final String description;



  // Поля, которые будут создаваться
  // при создании коллекции
  final List<FieldDefinition> fields;



  const Template({

    required super.id,


    required this.name,


    required this.description,


    this.fields = const [],

  });



  Template copyWith({

    String? name,

    String? description,

    List<FieldDefinition>? fields,

  }) {


    return Template(

      id: id,


      name:
          name ?? this.name,


      description:
          description ?? this.description,


      fields:
          fields ?? this.fields,

    );

  }


}