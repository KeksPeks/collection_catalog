/// Запись списка желаемых покупок.
class WishlistItem {
  final String id;
  final String catalogItemId;
  final String title;
  final String groupName;
  final double? currentPrice;
  final double? targetPrice;
  final int priority;
  final String? url;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WishlistItem({
    required this.id,
    required this.catalogItemId,
    required this.title,
    required this.groupName,
    this.currentPrice,
    this.targetPrice,
    this.priority = 2,
    this.url,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  String get priorityLabel {
    switch (priority) {
      case 1:
        return '🔥 Очень хочу';
      case 2:
        return '⭐ Хочу';
      default:
        return '○ Когда-нибудь';
    }
  }
}
