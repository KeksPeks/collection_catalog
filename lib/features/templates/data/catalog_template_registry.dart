import '../domain/entities/template.dart';
import '../../fields/domain/entities/field_definition.dart';
import '../../fields/domain/types/field_type.dart';

/// Готовые шаблоны основных направлений коллекционирования.
class CatalogTemplateRegistry {
  static List<Template> get all => [
        _template('coins', 'Монеты', 'Нумизматический каталог', [
          _field('country', 'Страна', FieldType.text),
          _field('period', 'Период', FieldType.text),
          _field('denomination', 'Номинал', FieldType.text),
          _field('year', 'Год', FieldType.integer),
          _field('mint', 'Монетный двор', FieldType.text),
          _field('metal', 'Металл', FieldType.text),
          _field('variety', 'Разновидность', FieldType.text),
          _field('condition', 'Состояние', FieldType.text),
          _field('quantity', 'Количество', FieldType.integer),
        ]),
        _template('banknotes', 'Банкноты', 'Бонистический каталог', [
          _field('country', 'Страна', FieldType.text),
          _field('currency', 'Валюта', FieldType.text),
          _field('denomination', 'Номинал', FieldType.text),
          _field('year', 'Год', FieldType.integer),
          _field('series', 'Серия', FieldType.text),
          _field('signature', 'Подпись', FieldType.text),
          _field('condition', 'Состояние', FieldType.text),
          _field('quantity', 'Количество', FieldType.integer),
        ]),
        _template('pokemon_tcg', 'Pokémon TCG', 'Коллекционные карточки', [
          _field('series', 'Серия', FieldType.text),
          _field('set', 'Сет', FieldType.text),
          _field('number', 'Номер', FieldType.text),
          _field('name', 'Название', FieldType.text),
          _field('rarity', 'Редкость', FieldType.text),
          _field('language', 'Язык', FieldType.text),
          _field('condition', 'Состояние', FieldType.text),
          _field('quantity', 'Количество', FieldType.integer),
        ]),
        _template('games', 'Игры', 'Игры для различных платформ', [
          _field('platform', 'Платформа', FieldType.text),
          _field('generation', 'Поколение', FieldType.text),
          _field('title', 'Название', FieldType.text),
          _field('region', 'Регион', FieldType.text),
          _field('publisher', 'Издатель', FieldType.text),
          _field('genre', 'Жанр', FieldType.text),
          _field('releaseYear', 'Год выпуска', FieldType.integer),
          _field('condition', 'Состояние', FieldType.text),
        ]),
        _template('discs', 'Диски', 'Игровые и музыкальные диски', [
          _field('platform', 'Платформа', FieldType.text),
          _field('type', 'Тип диска', FieldType.text),
          _field('title', 'Название', FieldType.text),
          _field('region', 'Регион', FieldType.text),
          _field('publisher', 'Издатель', FieldType.text),
          _field('year', 'Год', FieldType.integer),
          _field('condition', 'Состояние', FieldType.text),
        ]),
        _template('movies', 'Фильмы', 'Каталог фильмов', [
          _field('title', 'Название', FieldType.text),
          _field('year', 'Год', FieldType.integer),
          _field('country', 'Страна', FieldType.text),
          _field('director', 'Режиссёр', FieldType.text),
          _field('genre', 'Жанр', FieldType.text),
          _field('language', 'Язык', FieldType.text),
          _field('format', 'Формат', FieldType.text),
          _field('rating', 'Рейтинг', FieldType.decimal),
        ]),
        _template('figurines', 'Фигурки', 'Каталог фигурок', [
          _field('name', 'Название', FieldType.text),
          _field('series', 'Серия', FieldType.text),
          _field('character', 'Персонаж', FieldType.text),
          _field('manufacturer', 'Производитель', FieldType.text),
          _field('scale', 'Масштаб', FieldType.text),
          _field('material', 'Материал', FieldType.text),
          _field('year', 'Год', FieldType.integer),
          _field('condition', 'Состояние', FieldType.text),
        ]),
      ];

  static Template? byId(String id) {
    for (final template in all) {
      if (template.id == id) return template;
    }
    return null;
  }

  static Template _template(
    String id,
    String name,
    String description,
    List<FieldDefinition> fields,
  ) {
    return Template(
      id: id,
      name: name,
      description: description,
      fields: fields,
    );
  }

  static FieldDefinition _field(
    String id,
    String label,
    FieldType type,
  ) {
    return FieldDefinition(
      id: id,
      collectionId: '',
      label: label,
      type: type,
    );
  }
}
