import '../entities/collection.dart';


abstract class CollectionRepository {


  Future<List<Collection>> getCollections();



  Future<Collection?> getById(
    String id,
  );



  Future<void> saveCollection(
    Collection collection,
  );



  Future<void> deleteCollection(
    String id,
  );


}