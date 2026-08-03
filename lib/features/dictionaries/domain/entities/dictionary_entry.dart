import '../../../../shared/domain/entities/entity.dart';


class DictionaryEntry extends Entity {


  final String value;


  final String? code;


  final String? description;


  final String? icon;


  final Map<String, dynamic>? metadata;



  const DictionaryEntry({

    required super.id,

    required this.value,

    this.code,

    this.description,

    this.icon,

    this.metadata,

  });



  DictionaryEntry copyWith({

    String? value,

    String? code,

    String? description,

    String? icon,

    Map<String,dynamic>? metadata,

  }) {

    return DictionaryEntry(

      id: id,

      value:
          value ?? this.value,

      code:
          code ?? this.code,

      description:
          description ?? this.description,

      icon:
          icon ?? this.icon,

      metadata:
          metadata ?? this.metadata,

    );

  }

}