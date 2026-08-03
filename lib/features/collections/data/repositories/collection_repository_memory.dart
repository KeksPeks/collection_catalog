import '../../domain/entities/collection.dart';
import '../../domain/repositories/collection_repository.dart';



class CollectionRepositoryMemory
    implements CollectionRepository {


  final List<Collection> _items = [];



  @override
  Future<List<Collection>> getCollections() async {

    return List.unmodifiable(
      _items,
    );

  }



  @override
  Future<Collection?> getById(
    String id,
  ) async {


    try {

      return _items.firstWhere(
        (element) =>
            element.id == id,
      );


    } catch (_) {

      return null;

    }


  }



  @override
  Future<void> saveCollection(
    Collection collection,
  ) async {


    _items.add(
      collection,
    );


  }



  @override
  Future<void> deleteCollection(
    String id,
  ) async {


    _items.removeWhere(
      (element) =>
          element.id == id,
    );


  }


}