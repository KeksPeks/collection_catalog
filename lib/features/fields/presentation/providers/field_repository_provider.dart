import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/field_repository_memory.dart';
import '../../domain/repositories/field_repository.dart';



final fieldRepositoryProvider =
    Provider<FieldRepository>((ref){


  return FieldRepositoryMemory();


});