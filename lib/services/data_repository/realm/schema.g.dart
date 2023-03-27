// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class RealmCollection extends _RealmCollection
    with RealmEntity, RealmObjectBase, RealmObject {
  RealmCollection(
    ObjectId id,
    String name, {
    Iterable<RealmVerse> verses = const [],
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set<RealmList<RealmVerse>>(
        this, 'verses', RealmList<RealmVerse>(verses));
  }

  RealmCollection._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  RealmList<RealmVerse> get verses =>
      RealmObjectBase.get<RealmVerse>(this, 'verses') as RealmList<RealmVerse>;
  @override
  set verses(covariant RealmList<RealmVerse> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<RealmCollection>> get changes =>
      RealmObjectBase.getChanges<RealmCollection>(this);

  @override
  RealmCollection freeze() =>
      RealmObjectBase.freezeObject<RealmCollection>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(RealmCollection._);
    return const SchemaObject(
        ObjectType.realmObject, RealmCollection, 'RealmCollection', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('verses', RealmPropertyType.object,
          linkTarget: 'RealmVerse', collectionType: RealmCollectionType.list),
    ]);
  }
}

class RealmVerse extends _RealmVerse
    with RealmEntity, RealmObjectBase, RealmObject {
  RealmVerse(
    ObjectId id,
    String prompt,
    String answer,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'prompt', prompt);
    RealmObjectBase.set(this, 'answer', answer);
  }

  RealmVerse._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get prompt => RealmObjectBase.get<String>(this, 'prompt') as String;
  @override
  set prompt(String value) => RealmObjectBase.set(this, 'prompt', value);

  @override
  String get answer => RealmObjectBase.get<String>(this, 'answer') as String;
  @override
  set answer(String value) => RealmObjectBase.set(this, 'answer', value);

  @override
  Stream<RealmObjectChanges<RealmVerse>> get changes =>
      RealmObjectBase.getChanges<RealmVerse>(this);

  @override
  RealmVerse freeze() => RealmObjectBase.freezeObject<RealmVerse>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(RealmVerse._);
    return const SchemaObject(
        ObjectType.realmObject, RealmVerse, 'RealmVerse', [
      SchemaProperty('id', RealmPropertyType.objectid),
      SchemaProperty('prompt', RealmPropertyType.string),
      SchemaProperty('answer', RealmPropertyType.string),
    ]);
  }
}
