abstract class Entity {

  final String id;


  const Entity({
    required this.id,
  });


  @override
  bool operator ==(Object other) {

    if (identical(this, other)) {
      return true;
    }


    if (other is! Entity) {
      return false;
    }


    return id == other.id;
  }


  @override
  int get hashCode => id.hashCode;

}