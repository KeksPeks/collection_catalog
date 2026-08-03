import '../../../../shared/domain/entities/entity.dart';



class ViewDefinition extends Entity {


  // Название представления
  final String name;



  // Тип отображения
  final ViewType type;



  // Поля которые показываем
  final List<String> visibleFields;



  const ViewDefinition({

    required super.id,


    required this.name,


    required this.type,


    this.visibleFields = const [],

  });


}



enum ViewType {


  // Обычный список
  list,


  // Карточки
  cards,


  // Таблица
  table,


  // Группировка
  grouped,


}