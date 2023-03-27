import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/services/data_repository/data_repository.dart';
import 'package:memorize_scripture/services/data_repository/realm/schema.dart';
import 'package:realm/realm.dart';

class LocalStorage implements DataRepository {
  late Realm realm;

  @override
  Future<void> init() async {
    final config = Configuration.local([
      RealmCollection.schema,
      RealmVerse.schema,
    ]);
    realm = Realm(config);
  }

  @override
  Future<void> batchUpdateVerses(Collection collection) async {
    if (collection.verses == null) {
      throw ArgumentError('You must include verses in the collection');
    }
    final realmCollection = collectionToRealm(collection);
    realm.add(realmCollection);
  }

  @override
  Future<List<Collection>> fetchCollectionMetadata() async {
    final realmCollections = realm.all<RealmCollection>();
    final collections = <Collection>[];
    for (final realmCollection in realmCollections) {
      collections.add(realmToCollectionMetadata(realmCollection));
    }
    return collections;
  }

  @override
  Future<Verse?> fetchVerse({
    required String collectionId,
    required String verseId,
  }) async {
    final realmCollection = realm.find<RealmCollection>(
      ObjectId.fromHexString(collectionId),
    );
    if (realmCollection == null) return null;
    final results = realmCollection.verses.query(r'id == $0', [
      ObjectId.fromHexString(verseId),
    ]);
    if (results.isEmpty) return null;
    return realmToVerse(results.first);
  }

  @override
  Future<List<Verse>?> fetchVerses(String collectionId) async {
    final realmCollection = realm.find<RealmCollection>(
      ObjectId.fromHexString(collectionId),
    );
    if (realmCollection == null) return null;
    return realmToCollection(realmCollection).verses;
  }

  @override
  Future<void> updateVerse(String collectionId, Verse verse) async {
    final realmCollection = realm.find<RealmCollection>(
      ObjectId.fromHexString(collectionId),
    );
    if (realmCollection == null) return;
    //final realmVerse = verseToRealm(verse);
    final realmVerses = realmCollection.verses.query(r'id == $0', [
      ObjectId.fromHexString(verse.id),
    ]);
    if (realmVerses.isNotEmpty) {
      realm.write(() {
        final realmVerse = realmVerses.first;
        realm.add(realmVerse, update: true);
      });
    }
  }
}

Verse realmToVerse(RealmVerse verse) {
  return Verse(
    id: verse.id.toString(),
    prompt: verse.prompt,
    answer: verse.answer,
  );
}

RealmVerse verseToRealm(Verse verse) {
  return RealmVerse(
    ObjectId.fromHexString(verse.id),
    verse.prompt,
    verse.answer,
  );
}

Collection realmToCollection(RealmCollection collection) {
  return Collection(
    id: collection.id.toString(),
    name: collection.name,
    verses: collection.verses.map(realmToVerse).toList(),
  );
}

Collection realmToCollectionMetadata(RealmCollection collection) {
  return Collection(
    id: collection.id.toString(),
    name: collection.name,
  );
}

RealmCollection collectionToRealm(Collection collection) {
  final verses = collection.verses?.map(verseToRealm) ?? [];
  return RealmCollection(
    ObjectId.fromHexString(collection.id),
    collection.name,
    verses: verses,
  );
}
