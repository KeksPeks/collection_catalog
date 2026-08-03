import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';

import '../../domain/entities/collection.dart';
import '../../domain/repositories/collection_repository.dart';



class CollectionRepositoryDrift
    implements CollectionRepository {



  final AppDatabase database;



  CollectionRepositoryDrift(
    this.database,
  );




  @override
  Future<List<Collection>> getCollections() async {


    final rows =

        await database

            .select(
              database.collectionTable,
            )

            .get();



    return rows.map((row) {


      return Collection(

        id:
            row.id,

        name:
            row.name,

        templateId:
            row.templateId,

        createdAt:
            row.createdAt,

        updatedAt:
            row.updatedAt,

      );


    }).toList();



  }







  @override
  Future<Collection?> getById(
    String id,
  ) async {



    final query =

        database

            .select(
              database.collectionTable,
            )

          ..where(
            (table) =>
                table.id.equals(id),
          );



    final row =

        await query.getSingleOrNull();



    if(row == null){

      return null;

    }



    return Collection(

      id:
          row.id,

      name:
          row.name,

      templateId:
          row.templateId,

      createdAt:
          row.createdAt,

      updatedAt:
          row.updatedAt,

    );



  }








  @override
  Future<void> saveCollection(
    Collection collection,
  ) async {



    await database

        .into(
          database.collectionTable,
        )

        .insertOnConflictUpdate(


          CollectionTableCompanion(

            id:
                Value(
              collection.id,
            ),


            name:
                Value(
              collection.name,
            ),


            templateId:
                Value(
              collection.templateId,
            ),


            createdAt:
                Value(
              collection.createdAt,
            ),


            updatedAt:
                Value(
              collection.updatedAt,
            ),


          ),


        );


  }








  @override
  Future<void> deleteCollection(
    String id,
  ) async {


    await (

      database.delete(
        database.collectionTable,
      )

      ..where(
        (table) =>
            table.id.equals(id),
      )

    )
    .go();



  }



}