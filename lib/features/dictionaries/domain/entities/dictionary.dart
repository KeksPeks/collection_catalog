import '../../../../shared/domain/entities/entity.dart';
import 'dictionary_entry.dart';



class Dictionary extends Entity {


  final String name;


  final String? description;


  final List<DictionaryEntry> entries;



  const Dictionary({

    required super.id,

    required this.name,

    this.description,

    this.entries = const [],

  });



  Dictionary copyWith({

    String? name,

    String? description,

    List<DictionaryEntry>? entries,

  }) {


    return Dictionary(

      id:id,

      name:
          name ?? this.name,

      description:
          description ?? this.description,

      entries:
          entries ?? this.entries,

    );

  }



}