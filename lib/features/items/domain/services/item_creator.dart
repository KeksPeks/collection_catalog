import '../entities/item.dart';

class ItemCreator {
  Item create({
    required String collectionId,
    String? sectionId,
  }) {
    final now = DateTime.now();

    return Item(
      id: now.microsecondsSinceEpoch.toString(),
      collectionId: collectionId,
      sectionId: sectionId,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
  }
}