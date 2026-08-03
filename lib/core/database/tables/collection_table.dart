import 'package:drift/drift.dart';



class CollectionTable extends Table {


  TextColumn get id =>
      text()();



  TextColumn get name =>
      text()();



  TextColumn get templateId =>
      text().nullable()();



  DateTimeColumn get createdAt =>
      dateTime()();



  DateTimeColumn get updatedAt =>
      dateTime()();



  @override
  Set<Column> get primaryKey =>
      {
        id,
      };


}