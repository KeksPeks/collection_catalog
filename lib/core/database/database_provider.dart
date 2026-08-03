import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import 'database_connection.dart';



final databaseProvider =

    FutureProvider<AppDatabase>(


  (ref) async {


    ref.keepAlive();



    final connection =

        await openDatabaseConnection();



    return AppDatabase(
      connection,
    );


  },


);