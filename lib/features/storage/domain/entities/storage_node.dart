import '../../../../shared/domain/entities/entity.dart';



class StorageNode extends Entity {


  // Название узла хранения
  final String name;



  // Родительский узел
  // null означает корневой уровень
  final String? parentId;



  // Тип узла
  final StorageNodeType type;



  // Порядок отображения
  final int order;



  const StorageNode({

    required super.id,

    required this.name,

    this.parentId,

    required this.type,

    this.order = 0,

  });



  StorageNode copyWith({

    String? name,

    String? parentId,

    StorageNodeType? type,

    int? order,

  }) {


    return StorageNode(

      id: id,


      name:
          name ?? this.name,


      parentId:
          parentId ?? this.parentId,


      type:
          type ?? this.type,


      order:
          order ?? this.order,

    );

  }



}
enum StorageNodeType {


  // Дом, квартира, гараж
  location,


  // Шкаф, сейф, коробка
  container,


  // Альбом, папка
  folder,


  // Страница альбома
  page,


}