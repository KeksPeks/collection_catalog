import 'package:drift/drift.dart';



class FieldTable extends Table {


  TextColumn get id =>
      text()();



  TextColumn get collectionId =>
      text()();



  TextColumn get label =>
      text()();



  TextColumn get type =>
      text()();



  @override
  Set<Column> get primaryKey =>
      {
        id,
      };


}