import '../entities/item.dart';

/// Сервис расчёта базовой статистики коллекции.
class CollectionStatisticsService {
  /// Возвращает количество предметов.
  int itemCount(List<Item> items) => items.length;

  /// Возвращает количество уникальных предметов по идентификатору.
  int uniqueItemCount(List<Item> items) => items.map((item) => item.id).toSet().length;

  /// Возвращает процент заполнения коллекции.
  ///
  /// Если [totalCatalogItems] не задан или равен нулю, возвращается 0.
  double completionPercent(
    int ownedItems,
    int totalCatalogItems,
  ) {
    if (totalCatalogItems <= 0 || ownedItems <= 0) {
      return 0;
    }

    final percent = ownedItems / totalCatalogItems * 100;
    return percent.clamp(0, 100).toDouble();
  }
}
