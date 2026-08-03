// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CollectionTableTable extends CollectionTable
    with TableInfo<$CollectionTableTable, CollectionTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    templateId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collection_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CollectionTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CollectionTableTable createAlias(String alias) {
    return $CollectionTableTable(attachedDatabase, alias);
  }
}

class CollectionTableData extends DataClass
    implements Insertable<CollectionTableData> {
  final String id;
  final String name;
  final String? templateId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CollectionTableData({
    required this.id,
    required this.name,
    this.templateId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || templateId != null) {
      map['template_id'] = Variable<String>(templateId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CollectionTableCompanion toCompanion(bool nullToAbsent) {
    return CollectionTableCompanion(
      id: Value(id),
      name: Value(name),
      templateId: templateId == null && nullToAbsent
          ? const Value.absent()
          : Value(templateId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CollectionTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      templateId: serializer.fromJson<String?>(json['templateId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'templateId': serializer.toJson<String?>(templateId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CollectionTableData copyWith({
    String? id,
    String? name,
    Value<String?> templateId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CollectionTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    templateId: templateId.present ? templateId.value : this.templateId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CollectionTableData copyWithCompanion(CollectionTableCompanion data) {
    return CollectionTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('templateId: $templateId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, templateId, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.templateId == this.templateId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CollectionTableCompanion extends UpdateCompanion<CollectionTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> templateId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CollectionTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.templateId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionTableCompanion.insert({
    required String id,
    required String name,
    this.templateId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CollectionTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? templateId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (templateId != null) 'template_id': templateId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? templateId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CollectionTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      templateId: templateId ?? this.templateId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('templateId: $templateId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FieldTableTable extends FieldTable
    with TableInfo<$FieldTableTable, FieldTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FieldTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, collectionId, label, type];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'field_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<FieldTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FieldTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FieldTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
    );
  }

  @override
  $FieldTableTable createAlias(String alias) {
    return $FieldTableTable(attachedDatabase, alias);
  }
}

class FieldTableData extends DataClass implements Insertable<FieldTableData> {
  final String id;
  final String collectionId;
  final String label;
  final String type;
  const FieldTableData({
    required this.id,
    required this.collectionId,
    required this.label,
    required this.type,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['collection_id'] = Variable<String>(collectionId);
    map['label'] = Variable<String>(label);
    map['type'] = Variable<String>(type);
    return map;
  }

  FieldTableCompanion toCompanion(bool nullToAbsent) {
    return FieldTableCompanion(
      id: Value(id),
      collectionId: Value(collectionId),
      label: Value(label),
      type: Value(type),
    );
  }

  factory FieldTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FieldTableData(
      id: serializer.fromJson<String>(json['id']),
      collectionId: serializer.fromJson<String>(json['collectionId']),
      label: serializer.fromJson<String>(json['label']),
      type: serializer.fromJson<String>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'collectionId': serializer.toJson<String>(collectionId),
      'label': serializer.toJson<String>(label),
      'type': serializer.toJson<String>(type),
    };
  }

  FieldTableData copyWith({
    String? id,
    String? collectionId,
    String? label,
    String? type,
  }) => FieldTableData(
    id: id ?? this.id,
    collectionId: collectionId ?? this.collectionId,
    label: label ?? this.label,
    type: type ?? this.type,
  );
  FieldTableData copyWithCompanion(FieldTableCompanion data) {
    return FieldTableData(
      id: data.id.present ? data.id.value : this.id,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      label: data.label.present ? data.label.value : this.label,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FieldTableData(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('label: $label, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, collectionId, label, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FieldTableData &&
          other.id == this.id &&
          other.collectionId == this.collectionId &&
          other.label == this.label &&
          other.type == this.type);
}

class FieldTableCompanion extends UpdateCompanion<FieldTableData> {
  final Value<String> id;
  final Value<String> collectionId;
  final Value<String> label;
  final Value<String> type;
  final Value<int> rowid;
  const FieldTableCompanion({
    this.id = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.label = const Value.absent(),
    this.type = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FieldTableCompanion.insert({
    required String id,
    required String collectionId,
    required String label,
    required String type,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       collectionId = Value(collectionId),
       label = Value(label),
       type = Value(type);
  static Insertable<FieldTableData> custom({
    Expression<String>? id,
    Expression<String>? collectionId,
    Expression<String>? label,
    Expression<String>? type,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (collectionId != null) 'collection_id': collectionId,
      if (label != null) 'label': label,
      if (type != null) 'type': type,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FieldTableCompanion copyWith({
    Value<String>? id,
    Value<String>? collectionId,
    Value<String>? label,
    Value<String>? type,
    Value<int>? rowid,
  }) {
    return FieldTableCompanion(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      label: label ?? this.label,
      type: type ?? this.type,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FieldTableCompanion(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('label: $label, ')
          ..write('type: $type, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionSectionTableTable extends CollectionSectionTable
    with TableInfo<$CollectionSectionTableTable, CollectionSectionTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionSectionTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    collectionId,
    parentId,
    name,
    createdAt,
    updatedAt,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collection_section_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionSectionTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CollectionSectionTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionSectionTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CollectionSectionTableTable createAlias(String alias) {
    return $CollectionSectionTableTable(attachedDatabase, alias);
  }
}

class CollectionSectionTableData extends DataClass
    implements Insertable<CollectionSectionTableData> {
  /// Идентификатор раздела.
  final String id;

  /// Коллекция, которой принадлежит раздел.
  final String collectionId;

  /// Родительский раздел.
  final String? parentId;

  /// Название раздела.
  final String name;

  /// Дата создания.
  final DateTime createdAt;

  /// Дата обновления.
  final DateTime updatedAt;

  /// Порядок отображения.
  final int sortOrder;
  const CollectionSectionTableData({
    required this.id,
    required this.collectionId,
    this.parentId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['collection_id'] = Variable<String>(collectionId);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CollectionSectionTableCompanion toCompanion(bool nullToAbsent) {
    return CollectionSectionTableCompanion(
      id: Value(id),
      collectionId: Value(collectionId),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      sortOrder: Value(sortOrder),
    );
  }

  factory CollectionSectionTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionSectionTableData(
      id: serializer.fromJson<String>(json['id']),
      collectionId: serializer.fromJson<String>(json['collectionId']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'collectionId': serializer.toJson<String>(collectionId),
      'parentId': serializer.toJson<String?>(parentId),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CollectionSectionTableData copyWith({
    String? id,
    String? collectionId,
    Value<String?> parentId = const Value.absent(),
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? sortOrder,
  }) => CollectionSectionTableData(
    id: id ?? this.id,
    collectionId: collectionId ?? this.collectionId,
    parentId: parentId.present ? parentId.value : this.parentId,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  CollectionSectionTableData copyWithCompanion(
    CollectionSectionTableCompanion data,
  ) {
    return CollectionSectionTableData(
      id: data.id.present ? data.id.value : this.id,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionSectionTableData(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    collectionId,
    parentId,
    name,
    createdAt,
    updatedAt,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionSectionTableData &&
          other.id == this.id &&
          other.collectionId == this.collectionId &&
          other.parentId == this.parentId &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.sortOrder == this.sortOrder);
}

class CollectionSectionTableCompanion
    extends UpdateCompanion<CollectionSectionTableData> {
  final Value<String> id;
  final Value<String> collectionId;
  final Value<String?> parentId;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CollectionSectionTableCompanion({
    this.id = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.parentId = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionSectionTableCompanion.insert({
    required String id,
    required String collectionId,
    this.parentId = const Value.absent(),
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       collectionId = Value(collectionId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CollectionSectionTableData> custom({
    Expression<String>? id,
    Expression<String>? collectionId,
    Expression<String>? parentId,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (collectionId != null) 'collection_id': collectionId,
      if (parentId != null) 'parent_id': parentId,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionSectionTableCompanion copyWith({
    Value<String>? id,
    Value<String>? collectionId,
    Value<String?>? parentId,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return CollectionSectionTableCompanion(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionSectionTableCompanion(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemTableTable extends ItemTable
    with TableInfo<$ItemTableTable, ItemTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<String> sectionId = GeneratedColumn<String>(
    'section_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    collectionId,
    sectionId,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_id'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ItemTableTable createAlias(String alias) {
    return $ItemTableTable(attachedDatabase, alias);
  }
}

class ItemTableData extends DataClass implements Insertable<ItemTableData> {
  /// Идентификатор предмета.
  final String id;

  /// Коллекция, которой принадлежит предмет.
  final String collectionId;

  /// Раздел коллекции.
  final String? sectionId;

  /// Порядок отображения.
  final int sortOrder;

  /// Дата создания.
  final DateTime createdAt;

  /// Дата последнего изменения.
  final DateTime updatedAt;
  const ItemTableData({
    required this.id,
    required this.collectionId,
    this.sectionId,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['collection_id'] = Variable<String>(collectionId);
    if (!nullToAbsent || sectionId != null) {
      map['section_id'] = Variable<String>(sectionId);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ItemTableCompanion toCompanion(bool nullToAbsent) {
    return ItemTableCompanion(
      id: Value(id),
      collectionId: Value(collectionId),
      sectionId: sectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sectionId),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ItemTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemTableData(
      id: serializer.fromJson<String>(json['id']),
      collectionId: serializer.fromJson<String>(json['collectionId']),
      sectionId: serializer.fromJson<String?>(json['sectionId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'collectionId': serializer.toJson<String>(collectionId),
      'sectionId': serializer.toJson<String?>(sectionId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ItemTableData copyWith({
    String? id,
    String? collectionId,
    Value<String?> sectionId = const Value.absent(),
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ItemTableData(
    id: id ?? this.id,
    collectionId: collectionId ?? this.collectionId,
    sectionId: sectionId.present ? sectionId.value : this.sectionId,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ItemTableData copyWithCompanion(ItemTableCompanion data) {
    return ItemTableData(
      id: data.id.present ? data.id.value : this.id,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemTableData(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('sectionId: $sectionId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, collectionId, sectionId, sortOrder, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemTableData &&
          other.id == this.id &&
          other.collectionId == this.collectionId &&
          other.sectionId == this.sectionId &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ItemTableCompanion extends UpdateCompanion<ItemTableData> {
  final Value<String> id;
  final Value<String> collectionId;
  final Value<String?> sectionId;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ItemTableCompanion({
    this.id = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemTableCompanion.insert({
    required String id,
    required String collectionId,
    this.sectionId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       collectionId = Value(collectionId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ItemTableData> custom({
    Expression<String>? id,
    Expression<String>? collectionId,
    Expression<String>? sectionId,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (collectionId != null) 'collection_id': collectionId,
      if (sectionId != null) 'section_id': sectionId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemTableCompanion copyWith({
    Value<String>? id,
    Value<String>? collectionId,
    Value<String?>? sectionId,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ItemTableCompanion(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      sectionId: sectionId ?? this.sectionId,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<String>(sectionId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemTableCompanion(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('sectionId: $sectionId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemValueTableTable extends ItemValueTable
    with TableInfo<$ItemValueTableTable, ItemValueTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemValueTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldIdMeta = const VerificationMeta(
    'fieldId',
  );
  @override
  late final GeneratedColumn<String> fieldId = GeneratedColumn<String>(
    'field_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, itemId, fieldId, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_value_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemValueTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('field_id')) {
      context.handle(
        _fieldIdMeta,
        fieldId.isAcceptableOrUnknown(data['field_id']!, _fieldIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemValueTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemValueTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      fieldId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $ItemValueTableTable createAlias(String alias) {
    return $ItemValueTableTable(attachedDatabase, alias);
  }
}

class ItemValueTableData extends DataClass
    implements Insertable<ItemValueTableData> {
  /// Идентификатор значения.
  final String id;

  /// Идентификатор предмета.
  final String itemId;

  /// Идентификатор поля.
  final String fieldId;

  /// Значение поля.
  ///
  /// Хранится в строковом виде.
  /// Для чисел, дат, логических значений и ссылок используется
  /// строковое представление. Тип определяется FieldDefinition.
  final String value;
  const ItemValueTableData({
    required this.id,
    required this.itemId,
    required this.fieldId,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['field_id'] = Variable<String>(fieldId);
    map['value'] = Variable<String>(value);
    return map;
  }

  ItemValueTableCompanion toCompanion(bool nullToAbsent) {
    return ItemValueTableCompanion(
      id: Value(id),
      itemId: Value(itemId),
      fieldId: Value(fieldId),
      value: Value(value),
    );
  }

  factory ItemValueTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemValueTableData(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      fieldId: serializer.fromJson<String>(json['fieldId']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'fieldId': serializer.toJson<String>(fieldId),
      'value': serializer.toJson<String>(value),
    };
  }

  ItemValueTableData copyWith({
    String? id,
    String? itemId,
    String? fieldId,
    String? value,
  }) => ItemValueTableData(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    fieldId: fieldId ?? this.fieldId,
    value: value ?? this.value,
  );
  ItemValueTableData copyWithCompanion(ItemValueTableCompanion data) {
    return ItemValueTableData(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      fieldId: data.fieldId.present ? data.fieldId.value : this.fieldId,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemValueTableData(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('fieldId: $fieldId, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, itemId, fieldId, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemValueTableData &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.fieldId == this.fieldId &&
          other.value == this.value);
}

class ItemValueTableCompanion extends UpdateCompanion<ItemValueTableData> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String> fieldId;
  final Value<String> value;
  final Value<int> rowid;
  const ItemValueTableCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.fieldId = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemValueTableCompanion.insert({
    required String id,
    required String itemId,
    required String fieldId,
    required String value,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemId = Value(itemId),
       fieldId = Value(fieldId),
       value = Value(value);
  static Insertable<ItemValueTableData> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? fieldId,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (fieldId != null) 'field_id': fieldId,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemValueTableCompanion copyWith({
    Value<String>? id,
    Value<String>? itemId,
    Value<String>? fieldId,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return ItemValueTableCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      fieldId: fieldId ?? this.fieldId,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (fieldId.present) {
      map['field_id'] = Variable<String>(fieldId.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemValueTableCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('fieldId: $fieldId, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemAttachmentTableTable extends ItemAttachmentTable
    with TableInfo<$ItemAttachmentTableTable, ItemAttachmentTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemAttachmentTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, itemId, path, type];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_attachment_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemAttachmentTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemAttachmentTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemAttachmentTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
    );
  }

  @override
  $ItemAttachmentTableTable createAlias(String alias) {
    return $ItemAttachmentTableTable(attachedDatabase, alias);
  }
}

class ItemAttachmentTableData extends DataClass
    implements Insertable<ItemAttachmentTableData> {
  /// Идентификатор файла.
  final String id;

  /// Идентификатор предмета.
  final String itemId;

  /// Путь к файлу.
  final String path;

  /// Тип файла.
  ///
  /// Например:
  /// - image
  /// - pdf
  /// - video
  /// - audio
  /// - archive
  final String type;
  const ItemAttachmentTableData({
    required this.id,
    required this.itemId,
    required this.path,
    required this.type,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['path'] = Variable<String>(path);
    map['type'] = Variable<String>(type);
    return map;
  }

  ItemAttachmentTableCompanion toCompanion(bool nullToAbsent) {
    return ItemAttachmentTableCompanion(
      id: Value(id),
      itemId: Value(itemId),
      path: Value(path),
      type: Value(type),
    );
  }

  factory ItemAttachmentTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemAttachmentTableData(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      path: serializer.fromJson<String>(json['path']),
      type: serializer.fromJson<String>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'path': serializer.toJson<String>(path),
      'type': serializer.toJson<String>(type),
    };
  }

  ItemAttachmentTableData copyWith({
    String? id,
    String? itemId,
    String? path,
    String? type,
  }) => ItemAttachmentTableData(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    path: path ?? this.path,
    type: type ?? this.type,
  );
  ItemAttachmentTableData copyWithCompanion(ItemAttachmentTableCompanion data) {
    return ItemAttachmentTableData(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      path: data.path.present ? data.path.value : this.path,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemAttachmentTableData(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('path: $path, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, itemId, path, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemAttachmentTableData &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.path == this.path &&
          other.type == this.type);
}

class ItemAttachmentTableCompanion
    extends UpdateCompanion<ItemAttachmentTableData> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String> path;
  final Value<String> type;
  final Value<int> rowid;
  const ItemAttachmentTableCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.path = const Value.absent(),
    this.type = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemAttachmentTableCompanion.insert({
    required String id,
    required String itemId,
    required String path,
    required String type,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemId = Value(itemId),
       path = Value(path),
       type = Value(type);
  static Insertable<ItemAttachmentTableData> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? path,
    Expression<String>? type,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (path != null) 'path': path,
      if (type != null) 'type': type,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemAttachmentTableCompanion copyWith({
    Value<String>? id,
    Value<String>? itemId,
    Value<String>? path,
    Value<String>? type,
    Value<int>? rowid,
  }) {
    return ItemAttachmentTableCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      path: path ?? this.path,
      type: type ?? this.type,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemAttachmentTableCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('path: $path, ')
          ..write('type: $type, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CollectionTableTable collectionTable = $CollectionTableTable(
    this,
  );
  late final $FieldTableTable fieldTable = $FieldTableTable(this);
  late final $CollectionSectionTableTable collectionSectionTable =
      $CollectionSectionTableTable(this);
  late final $ItemTableTable itemTable = $ItemTableTable(this);
  late final $ItemValueTableTable itemValueTable = $ItemValueTableTable(this);
  late final $ItemAttachmentTableTable itemAttachmentTable =
      $ItemAttachmentTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    collectionTable,
    fieldTable,
    collectionSectionTable,
    itemTable,
    itemValueTable,
    itemAttachmentTable,
  ];
}

typedef $$CollectionTableTableCreateCompanionBuilder =
    CollectionTableCompanion Function({
      required String id,
      required String name,
      Value<String?> templateId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CollectionTableTableUpdateCompanionBuilder =
    CollectionTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> templateId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CollectionTableTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionTableTable> {
  $$CollectionTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CollectionTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionTableTable> {
  $$CollectionTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionTableTable> {
  $$CollectionTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CollectionTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionTableTable,
          CollectionTableData,
          $$CollectionTableTableFilterComposer,
          $$CollectionTableTableOrderingComposer,
          $$CollectionTableTableAnnotationComposer,
          $$CollectionTableTableCreateCompanionBuilder,
          $$CollectionTableTableUpdateCompanionBuilder,
          (
            CollectionTableData,
            BaseReferences<
              _$AppDatabase,
              $CollectionTableTable,
              CollectionTableData
            >,
          ),
          CollectionTableData,
          PrefetchHooks Function()
        > {
  $$CollectionTableTableTableManager(
    _$AppDatabase db,
    $CollectionTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> templateId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionTableCompanion(
                id: id,
                name: name,
                templateId: templateId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> templateId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CollectionTableCompanion.insert(
                id: id,
                name: name,
                templateId: templateId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CollectionTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionTableTable,
      CollectionTableData,
      $$CollectionTableTableFilterComposer,
      $$CollectionTableTableOrderingComposer,
      $$CollectionTableTableAnnotationComposer,
      $$CollectionTableTableCreateCompanionBuilder,
      $$CollectionTableTableUpdateCompanionBuilder,
      (
        CollectionTableData,
        BaseReferences<
          _$AppDatabase,
          $CollectionTableTable,
          CollectionTableData
        >,
      ),
      CollectionTableData,
      PrefetchHooks Function()
    >;
typedef $$FieldTableTableCreateCompanionBuilder =
    FieldTableCompanion Function({
      required String id,
      required String collectionId,
      required String label,
      required String type,
      Value<int> rowid,
    });
typedef $$FieldTableTableUpdateCompanionBuilder =
    FieldTableCompanion Function({
      Value<String> id,
      Value<String> collectionId,
      Value<String> label,
      Value<String> type,
      Value<int> rowid,
    });

class $$FieldTableTableFilterComposer
    extends Composer<_$AppDatabase, $FieldTableTable> {
  $$FieldTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FieldTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FieldTableTable> {
  $$FieldTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FieldTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FieldTableTable> {
  $$FieldTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);
}

class $$FieldTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FieldTableTable,
          FieldTableData,
          $$FieldTableTableFilterComposer,
          $$FieldTableTableOrderingComposer,
          $$FieldTableTableAnnotationComposer,
          $$FieldTableTableCreateCompanionBuilder,
          $$FieldTableTableUpdateCompanionBuilder,
          (
            FieldTableData,
            BaseReferences<_$AppDatabase, $FieldTableTable, FieldTableData>,
          ),
          FieldTableData,
          PrefetchHooks Function()
        > {
  $$FieldTableTableTableManager(_$AppDatabase db, $FieldTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FieldTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FieldTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FieldTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> collectionId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FieldTableCompanion(
                id: id,
                collectionId: collectionId,
                label: label,
                type: type,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String collectionId,
                required String label,
                required String type,
                Value<int> rowid = const Value.absent(),
              }) => FieldTableCompanion.insert(
                id: id,
                collectionId: collectionId,
                label: label,
                type: type,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FieldTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FieldTableTable,
      FieldTableData,
      $$FieldTableTableFilterComposer,
      $$FieldTableTableOrderingComposer,
      $$FieldTableTableAnnotationComposer,
      $$FieldTableTableCreateCompanionBuilder,
      $$FieldTableTableUpdateCompanionBuilder,
      (
        FieldTableData,
        BaseReferences<_$AppDatabase, $FieldTableTable, FieldTableData>,
      ),
      FieldTableData,
      PrefetchHooks Function()
    >;
typedef $$CollectionSectionTableTableCreateCompanionBuilder =
    CollectionSectionTableCompanion Function({
      required String id,
      required String collectionId,
      Value<String?> parentId,
      required String name,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$CollectionSectionTableTableUpdateCompanionBuilder =
    CollectionSectionTableCompanion Function({
      Value<String> id,
      Value<String> collectionId,
      Value<String?> parentId,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$CollectionSectionTableTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionSectionTableTable> {
  $$CollectionSectionTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CollectionSectionTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionSectionTableTable> {
  $$CollectionSectionTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionSectionTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionSectionTableTable> {
  $$CollectionSectionTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$CollectionSectionTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionSectionTableTable,
          CollectionSectionTableData,
          $$CollectionSectionTableTableFilterComposer,
          $$CollectionSectionTableTableOrderingComposer,
          $$CollectionSectionTableTableAnnotationComposer,
          $$CollectionSectionTableTableCreateCompanionBuilder,
          $$CollectionSectionTableTableUpdateCompanionBuilder,
          (
            CollectionSectionTableData,
            BaseReferences<
              _$AppDatabase,
              $CollectionSectionTableTable,
              CollectionSectionTableData
            >,
          ),
          CollectionSectionTableData,
          PrefetchHooks Function()
        > {
  $$CollectionSectionTableTableTableManager(
    _$AppDatabase db,
    $CollectionSectionTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionSectionTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CollectionSectionTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CollectionSectionTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> collectionId = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionSectionTableCompanion(
                id: id,
                collectionId: collectionId,
                parentId: parentId,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String collectionId,
                Value<String?> parentId = const Value.absent(),
                required String name,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionSectionTableCompanion.insert(
                id: id,
                collectionId: collectionId,
                parentId: parentId,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CollectionSectionTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionSectionTableTable,
      CollectionSectionTableData,
      $$CollectionSectionTableTableFilterComposer,
      $$CollectionSectionTableTableOrderingComposer,
      $$CollectionSectionTableTableAnnotationComposer,
      $$CollectionSectionTableTableCreateCompanionBuilder,
      $$CollectionSectionTableTableUpdateCompanionBuilder,
      (
        CollectionSectionTableData,
        BaseReferences<
          _$AppDatabase,
          $CollectionSectionTableTable,
          CollectionSectionTableData
        >,
      ),
      CollectionSectionTableData,
      PrefetchHooks Function()
    >;
typedef $$ItemTableTableCreateCompanionBuilder =
    ItemTableCompanion Function({
      required String id,
      required String collectionId,
      Value<String?> sectionId,
      Value<int> sortOrder,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ItemTableTableUpdateCompanionBuilder =
    ItemTableCompanion Function({
      Value<String> id,
      Value<String> collectionId,
      Value<String?> sectionId,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ItemTableTableFilterComposer
    extends Composer<_$AppDatabase, $ItemTableTable> {
  $$ItemTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemTableTable> {
  $$ItemTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemTableTable> {
  $$ItemTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sectionId =>
      $composableBuilder(column: $table.sectionId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ItemTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemTableTable,
          ItemTableData,
          $$ItemTableTableFilterComposer,
          $$ItemTableTableOrderingComposer,
          $$ItemTableTableAnnotationComposer,
          $$ItemTableTableCreateCompanionBuilder,
          $$ItemTableTableUpdateCompanionBuilder,
          (
            ItemTableData,
            BaseReferences<_$AppDatabase, $ItemTableTable, ItemTableData>,
          ),
          ItemTableData,
          PrefetchHooks Function()
        > {
  $$ItemTableTableTableManager(_$AppDatabase db, $ItemTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> collectionId = const Value.absent(),
                Value<String?> sectionId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemTableCompanion(
                id: id,
                collectionId: collectionId,
                sectionId: sectionId,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String collectionId,
                Value<String?> sectionId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ItemTableCompanion.insert(
                id: id,
                collectionId: collectionId,
                sectionId: sectionId,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItemTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemTableTable,
      ItemTableData,
      $$ItemTableTableFilterComposer,
      $$ItemTableTableOrderingComposer,
      $$ItemTableTableAnnotationComposer,
      $$ItemTableTableCreateCompanionBuilder,
      $$ItemTableTableUpdateCompanionBuilder,
      (
        ItemTableData,
        BaseReferences<_$AppDatabase, $ItemTableTable, ItemTableData>,
      ),
      ItemTableData,
      PrefetchHooks Function()
    >;
typedef $$ItemValueTableTableCreateCompanionBuilder =
    ItemValueTableCompanion Function({
      required String id,
      required String itemId,
      required String fieldId,
      required String value,
      Value<int> rowid,
    });
typedef $$ItemValueTableTableUpdateCompanionBuilder =
    ItemValueTableCompanion Function({
      Value<String> id,
      Value<String> itemId,
      Value<String> fieldId,
      Value<String> value,
      Value<int> rowid,
    });

class $$ItemValueTableTableFilterComposer
    extends Composer<_$AppDatabase, $ItemValueTableTable> {
  $$ItemValueTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldId => $composableBuilder(
    column: $table.fieldId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemValueTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemValueTableTable> {
  $$ItemValueTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldId => $composableBuilder(
    column: $table.fieldId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemValueTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemValueTableTable> {
  $$ItemValueTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get fieldId =>
      $composableBuilder(column: $table.fieldId, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$ItemValueTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemValueTableTable,
          ItemValueTableData,
          $$ItemValueTableTableFilterComposer,
          $$ItemValueTableTableOrderingComposer,
          $$ItemValueTableTableAnnotationComposer,
          $$ItemValueTableTableCreateCompanionBuilder,
          $$ItemValueTableTableUpdateCompanionBuilder,
          (
            ItemValueTableData,
            BaseReferences<
              _$AppDatabase,
              $ItemValueTableTable,
              ItemValueTableData
            >,
          ),
          ItemValueTableData,
          PrefetchHooks Function()
        > {
  $$ItemValueTableTableTableManager(
    _$AppDatabase db,
    $ItemValueTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemValueTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemValueTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemValueTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> fieldId = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemValueTableCompanion(
                id: id,
                itemId: itemId,
                fieldId: fieldId,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String itemId,
                required String fieldId,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => ItemValueTableCompanion.insert(
                id: id,
                itemId: itemId,
                fieldId: fieldId,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItemValueTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemValueTableTable,
      ItemValueTableData,
      $$ItemValueTableTableFilterComposer,
      $$ItemValueTableTableOrderingComposer,
      $$ItemValueTableTableAnnotationComposer,
      $$ItemValueTableTableCreateCompanionBuilder,
      $$ItemValueTableTableUpdateCompanionBuilder,
      (
        ItemValueTableData,
        BaseReferences<_$AppDatabase, $ItemValueTableTable, ItemValueTableData>,
      ),
      ItemValueTableData,
      PrefetchHooks Function()
    >;
typedef $$ItemAttachmentTableTableCreateCompanionBuilder =
    ItemAttachmentTableCompanion Function({
      required String id,
      required String itemId,
      required String path,
      required String type,
      Value<int> rowid,
    });
typedef $$ItemAttachmentTableTableUpdateCompanionBuilder =
    ItemAttachmentTableCompanion Function({
      Value<String> id,
      Value<String> itemId,
      Value<String> path,
      Value<String> type,
      Value<int> rowid,
    });

class $$ItemAttachmentTableTableFilterComposer
    extends Composer<_$AppDatabase, $ItemAttachmentTableTable> {
  $$ItemAttachmentTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemAttachmentTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemAttachmentTableTable> {
  $$ItemAttachmentTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemAttachmentTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemAttachmentTableTable> {
  $$ItemAttachmentTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);
}

class $$ItemAttachmentTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemAttachmentTableTable,
          ItemAttachmentTableData,
          $$ItemAttachmentTableTableFilterComposer,
          $$ItemAttachmentTableTableOrderingComposer,
          $$ItemAttachmentTableTableAnnotationComposer,
          $$ItemAttachmentTableTableCreateCompanionBuilder,
          $$ItemAttachmentTableTableUpdateCompanionBuilder,
          (
            ItemAttachmentTableData,
            BaseReferences<
              _$AppDatabase,
              $ItemAttachmentTableTable,
              ItemAttachmentTableData
            >,
          ),
          ItemAttachmentTableData,
          PrefetchHooks Function()
        > {
  $$ItemAttachmentTableTableTableManager(
    _$AppDatabase db,
    $ItemAttachmentTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemAttachmentTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemAttachmentTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ItemAttachmentTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemAttachmentTableCompanion(
                id: id,
                itemId: itemId,
                path: path,
                type: type,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String itemId,
                required String path,
                required String type,
                Value<int> rowid = const Value.absent(),
              }) => ItemAttachmentTableCompanion.insert(
                id: id,
                itemId: itemId,
                path: path,
                type: type,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItemAttachmentTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemAttachmentTableTable,
      ItemAttachmentTableData,
      $$ItemAttachmentTableTableFilterComposer,
      $$ItemAttachmentTableTableOrderingComposer,
      $$ItemAttachmentTableTableAnnotationComposer,
      $$ItemAttachmentTableTableCreateCompanionBuilder,
      $$ItemAttachmentTableTableUpdateCompanionBuilder,
      (
        ItemAttachmentTableData,
        BaseReferences<
          _$AppDatabase,
          $ItemAttachmentTableTable,
          ItemAttachmentTableData
        >,
      ),
      ItemAttachmentTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CollectionTableTableTableManager get collectionTable =>
      $$CollectionTableTableTableManager(_db, _db.collectionTable);
  $$FieldTableTableTableManager get fieldTable =>
      $$FieldTableTableTableManager(_db, _db.fieldTable);
  $$CollectionSectionTableTableTableManager get collectionSectionTable =>
      $$CollectionSectionTableTableTableManager(
        _db,
        _db.collectionSectionTable,
      );
  $$ItemTableTableTableManager get itemTable =>
      $$ItemTableTableTableManager(_db, _db.itemTable);
  $$ItemValueTableTableTableManager get itemValueTable =>
      $$ItemValueTableTableTableManager(_db, _db.itemValueTable);
  $$ItemAttachmentTableTableTableManager get itemAttachmentTable =>
      $$ItemAttachmentTableTableTableManager(_db, _db.itemAttachmentTable);
}
