import '../entities/storage_node.dart';



class StorageTreeService {


  final List<StorageNode> _nodes = [];



  // Добавить новый узел хранения
  void add(StorageNode node) {

    _nodes.add(node);

  }



  // Получить детей определённого узла
  List<StorageNode> childrenOf(String? parentId) {


    return _nodes
        .where(
          (node) =>
              node.parentId == parentId,
        )
        .toList();

  }



  // Найти узел по id
  StorageNode? find(String id) {


    for (final node in _nodes) {


      if (node.id == id) {

        return node;

      }

    }


    return null;

  }



  // Получить полный путь хранения
  List<StorageNode> pathTo(String id) {


    final result = <StorageNode>[];


    StorageNode? current = find(id);



    while (current != null) {


      result.insert(
        0,
        current,
      );


      current =
          current.parentId == null
              ? null
              : find(current.parentId!);

    }


    return result;

  }


}