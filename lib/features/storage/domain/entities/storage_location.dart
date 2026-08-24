/// Место хранения физического экземпляра.
class StorageLocation {
  final String id;
  final String name;
  final String? parentId;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StorageLocation({
    required this.id,
    required this.name,
    this.parentId,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });
}
