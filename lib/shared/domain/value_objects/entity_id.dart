class EntityId {


  final String value;


  const EntityId(this.value);



  @override
  bool operator ==(Object other) {

    return other is EntityId &&
        other.value == value;

  }



  @override
  int get hashCode => value.hashCode;


}