class CollectionSettings {

  final String defaultView;


  final String? defaultSortField;


  final bool ascending;


  const CollectionSettings({

    this.defaultView = 'list',

    this.defaultSortField,

    this.ascending = true,

  });


  CollectionSettings copyWith({

    String? defaultView,

    String? defaultSortField,

    bool? ascending,

  }) {

    return CollectionSettings(

      defaultView:
          defaultView ?? this.defaultView,

      defaultSortField:
          defaultSortField ?? this.defaultSortField,

      ascending:
          ascending ?? this.ascending,

    );

  }

}