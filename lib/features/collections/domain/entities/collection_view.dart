/// Описание представления списка предметов.
class CollectionView {
  final String id;
  final String name;
  final List<String> fieldIds;
  final bool showAttachments;

  const CollectionView({
    required this.id,
    required this.name,
    this.fieldIds = const [],
    this.showAttachments = true,
  });
}
