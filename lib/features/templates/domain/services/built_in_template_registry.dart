import '../../../fields/domain/entities/field_definition.dart';
import '../../../fields/domain/types/field_type.dart';
import '../entities/template.dart';

/// Готовые шаблоны каталогов для основных направлений коллекционирования.
class BuiltInTemplateRegistry {
  static final List<Template> templates = [
    Template(id: 'coins', name: 'Монеты', description: 'Страна, номинал, год, металл, монетный двор, состояние и тираж.', fields: [_f('country', 'Страна', FieldType.text), _f('denomination', 'Номинал', FieldType.text), _f('year', 'Год', FieldType.integer), _f('metal', 'Металл', FieldType.text), _f('mint', 'Монетный двор', FieldType.text), _f('condition', 'Состояние', FieldType.text), _f('mintage', 'Тираж', FieldType.integer)]),
    Template(id: 'banknotes', name: 'Банкноты', description: 'Валюта, номинал, страна, год, серия, состояние и номер.', fields: [_f('country', 'Страна', FieldType.text), _f('currency', 'Валюта', FieldType.text), _f('denomination', 'Номинал', FieldType.text), _f('year', 'Год', FieldType.integer), _f('series', 'Серия', FieldType.text), _f('condition', 'Состояние', FieldType.text), _f('serial', 'Серийный номер', FieldType.text)]),
    Template(id: 'discs', name: 'Диски', description: 'Платформа, регион, издатель, год, жанр и состояние.', fields: [_f('title', 'Название', FieldType.text), _f('platform', 'Платформа', FieldType.text), _f('region', 'Регион', FieldType.text), _f('publisher', 'Издатель', FieldType.text), _f('year', 'Год', FieldType.integer), _f('genre', 'Жанр', FieldType.text), _f('condition', 'Состояние', FieldType.text)]),
    Template(id: 'pokemon_cards', name: 'Карточки Pokémon', description: 'Сет, номер, язык, редкость, состояние и наличие.', fields: [_f('name', 'Название карты', FieldType.text), _f('set', 'Сет', FieldType.text), _f('number', 'Номер', FieldType.text), _f('rarity', 'Редкость', FieldType.text), _f('language', 'Язык', FieldType.text), _f('condition', 'Состояние', FieldType.text), _f('owned', 'Есть в коллекции', FieldType.boolean)]),
    Template(id: 'games', name: 'Игры', description: 'Название, платформа, регион, издатель, жанр, год и версия.', fields: [_f('title', 'Название', FieldType.text), _f('platform', 'Платформа', FieldType.text), _f('region', 'Регион', FieldType.text), _f('publisher', 'Издатель', FieldType.text), _f('genre', 'Жанр', FieldType.text), _f('year', 'Год', FieldType.integer), _f('edition', 'Издание', FieldType.text)]),
    Template(id: 'movies', name: 'Фильмы', description: 'Название, год, режиссёр, жанр, страна, формат и рейтинг.', fields: [_f('title', 'Название', FieldType.text), _f('year', 'Год', FieldType.integer), _f('director', 'Режиссёр', FieldType.text), _f('genre', 'Жанр', FieldType.text), _f('country', 'Страна', FieldType.text), _f('format', 'Формат', FieldType.text), _f('rating', 'Рейтинг', FieldType.decimal)]),
  ];

  static FieldDefinition _f(String id, String label, FieldType type) => FieldDefinition(id: id, collectionId: '', label: label, type: type);
}
