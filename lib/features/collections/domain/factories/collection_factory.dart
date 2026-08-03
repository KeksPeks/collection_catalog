import '../entities/collection.dart';



/// Фабрика создания коллекций.
///
/// Здесь будет находиться вся логика
/// первичного создания объекта Collection.
class CollectionFactory {


  Collection create({
    required String name,
    String? templateId,
  }) {


    final now =
        DateTime.now();



    return Collection(

      id:
          now.microsecondsSinceEpoch
              .toString(),


      name:
          name.trim(),


      templateId:
          templateId,


      createdAt:
          now,


      updatedAt:
          now,

    );


  }


}