import '../entities/template.dart';

/// Реестр готовых шаблонов коллекций.
///
/// Шаблон описывает структуру коллекции и не содержит пользовательские
/// данные. Новая коллекция получает независимую копию структуры полей.
class TemplateRegistry {
  final Map<String, Template> _templates = {};

  void register(Template template) {
    _templates[template.id] = template;
  }

  Template? getById(String id) => _templates[id];

  List<Template> getAll() => List.unmodifiable(_templates.values);

  bool contains(String id) => _templates.containsKey(id);
}
