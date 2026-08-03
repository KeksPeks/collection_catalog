import '../entities/collection.dart';
import '../factories/collection_factory.dart';
import '../repositories/collection_repository.dart';



class CollectionService {


  final CollectionRepository repository;


  final CollectionFactory factory;



  CollectionService({

    required this.repository,

    required this.factory,

  });



  Future<List<Collection>> getCollections() async {

    return repository.getCollections();

  }




  Future<Collection?> getCollection(
    String id,
  ) async {

    return repository.getById(
      id,
    );

  }




  Future<void> createCollection(
    Collection collection,
  ) async {


    if(collection.name.trim().isEmpty){

      throw Exception(
        'Название коллекции пустое',
      );

    }


    await repository.saveCollection(
      collection,
    );


  }





  Future<void> createNewCollection(
    String name,
  ) async {


    final collection =
        factory.create(
          name: name,
        );


    await createCollection(
      collection,
    );


  }





  Future<void> updateCollection(
    Collection collection,
  ) async {


    await repository.saveCollection(
      collection,
    );


  }





  Future<void> deleteCollection(
    String id,
  ) async {


    await repository.deleteCollection(
      id,
    );


  }


}