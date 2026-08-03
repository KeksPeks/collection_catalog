import '../../domain/entities/collection_field.dart';
import '../../domain/repositories/collection_field_repository.dart';


/// Временная реализация в памяти.
///
/// Будет заменена на Drift.
class CollectionFieldRepositoryMemory
    implements CollectionFieldRepository {


  final List<CollectionField> _fields = [];


  @override
  Future<List<CollectionField>> getByCollection(
    String collectionId,
  ) async {

    return _fields
        .where(
          (field) =>
              field.collectionId == collectionId,
        )
        .toList();

  }



  @override
  Future<void> add(
    CollectionField field,
  ) async {

    _fields.add(field);

  }



  @override
  Future<void> update(
    CollectionField field,
  ) async {


    final index =
        _fields.indexWhere(
          (item) =>
              item.id == field.id,
        );


    if(index >= 0){

      _fields[index] = field;

    }

  }



  @override
  Future<void> delete(
    String id,
  ) async {


    _fields.removeWhere(
      (item) =>
          item.id == id,
    );

  }

}