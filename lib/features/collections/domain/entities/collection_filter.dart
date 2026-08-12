/// Описание фильтра коллекции.
class CollectionFilter {
  final String fieldId;
  final String query;
  final bool descending;

  const CollectionFilter({
    required this.fieldId,
    this.query = '',
    this.descending = false,
  });

  CollectionFilter copyWith({
    String? fieldId,
    String? query,
    bool? descending,
  }) {
    return CollectionFilter(
      fieldId: fieldId ?? this.fieldId,
      query: query ?? this.query,
      descending: descending ?? this.descending,
    );
  }
}
