import '../models/catalog_item_model.dart';

/// Локальный источник данных.
///
/// Пока данные хранятся в коде.
/// Позже здесь будет SQLite (Drift).
class CatalogLocalSource {
  List<CatalogItemModel> getItems() {
    return const [
      CatalogItemModel(
        id: '1',
        title: 'Super Mario Bros.',
        description: 'Легендарный платформер Nintendo.',
        platform: 'NES',
        genre: 'Platform',
        developer: 'Nintendo',
        publisher: 'Nintendo',
        year: 1985,
        isOwned: true,
      ),
      CatalogItemModel(
        id: '2',
        title: 'The Legend of Zelda',
        description: 'Приключенческая игра.',
        platform: 'NES',
        genre: 'Adventure',
        developer: 'Nintendo',
        publisher: 'Nintendo',
        year: 1986,
      ),
      CatalogItemModel(
        id: '3',
        title: 'Metroid',
        description: 'Научно-фантастический экшен.',
        platform: 'NES',
        genre: 'Action',
        developer: 'Nintendo',
        publisher: 'Nintendo',
        year: 1986,
      ),
    ];
  }
}