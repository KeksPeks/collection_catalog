import '../entities/view_definition.dart';



class ViewService {


  final List<ViewDefinition> _views = [];



  // Добавление нового представления
  void add(ViewDefinition view) {

    _views.add(view);

  }



  // Получение всех представлений
  List<ViewDefinition> getAll() {

    return List.unmodifiable(_views);

  }



  // Поиск представления по id
  ViewDefinition? findById(String id) {


    for (final view in _views) {


      if (view.id == id) {

        return view;

      }

    }


    return null;

  }



  // Удаление представления
  void remove(String id) {


    _views.removeWhere(

      (view) =>
          view.id == id,

    );

  }



  // Очистка
  void clear() {

    _views.clear();

  }


}