import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/common/dialog/edit_collection_dialog.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/pages/add_edit_verse/add_edit_verse_page.dart';
import 'package:memorize_scripture/pages/add_edit_verse/add_edit_verse_page_manager.dart';
import 'package:memorize_scripture/pages/add_edit_verse/select_collection_sheet.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/deep_link_service.dart';
import 'package:memorize_scripture/services/local_storage/local_storage.dart';

class FakeLocalStorage implements LocalStorage {
  final List<Collection> collections = [];
  final List<Verse> verses = [];
  String? lastInsertedCollectionId;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<Collection>> fetchCollections() async => List.from(collections);

  @override
  Future<void> insertCollection(Collection collection) async {
    collections.add(collection);
  }

  @override
  Future<bool> promptExists({
    required String collectionId,
    required String prompt,
  }) async {
    return verses.any((v) => v.prompt.trim() == prompt.trim());
  }

  @override
  Future<void> insertVerse(String collectionId, Verse verse) async {
    lastInsertedCollectionId = collectionId;
    verses.add(verse);
  }
}

void main() {
  late FakeLocalStorage fakeStorage;

  setUp(() {
    fakeStorage = FakeLocalStorage();
    if (getIt.isRegistered<LocalStorage>()) {
      getIt.unregister<LocalStorage>();
    }
    getIt.registerSingleton<LocalStorage>(fakeStorage);
  });

  tearDown(() {
    if (getIt.isRegistered<LocalStorage>()) {
      getIt.unregister<LocalStorage>();
    }
  });

  group('DeepLinkData', () {
    test('parses valid memorizescripture://add URI', () {
      final uri = Uri.parse(
        'memorizescripture://add?prompt=John%203%3A16&text=For%20God%20so%20loved%20the%20world&version=BSB',
      );
      final data = DeepLinkData.fromUri(uri);

      expect(data, isNotNull);
      expect(data!.prompt, 'John 3:16');
      expect(data.text, 'For God so loved the world');
      expect(data.version, 'BSB');
    });

    test('parses valid memorizescripture://?prompt=... URI (BSB app format)', () {
      final uri = Uri.parse(
        'memorizescripture://?prompt=Joel+2:1&text=Blow+the+ram’s+horn&version=BSB',
      );
      final data = DeepLinkData.fromUri(uri);

      expect(data, isNotNull);
      expect(data!.prompt, 'Joel 2:1');
      expect(data.text, 'Blow the ram’s horn');
      expect(data.version, 'BSB');
    });

    test('parses valid route URI (/?prompt=...)', () {
      final uri = Uri.parse(
        '/?prompt=Joel+2:1&text=Blow+the+ram’s+horn&version=BSB',
      );
      final data = DeepLinkData.fromUri(uri);

      expect(data, isNotNull);
      expect(data!.prompt, 'Joel 2:1');
      expect(data.text, 'Blow the ram’s horn');
      expect(data.version, 'BSB');
    });

    test('returns null for wrong scheme or host', () {
      expect(DeepLinkData.fromUri(Uri.parse('https://example.com')), isNull);
      expect(DeepLinkData.fromUri(Uri.parse('memorizescripture://view')), isNull);
      expect(DeepLinkData.fromUri(Uri.parse('other://add')), isNull);
    });

    test('returns null if both prompt and text are empty', () {
      expect(DeepLinkData.fromUri(Uri.parse('memorizescripture://add')), isNull);
      expect(
        DeepLinkData.fromUri(Uri.parse('memorizescripture://add?prompt=&text=')),
        isNull,
      );
    });
  });

  group('AddEditVersePage prefill with initialPrompt and initialVerseText', () {
    test('AddEditVersePageManager initializes and enables canAddNotifier when prefilled', () async {
      final manager = AddEditVersePageManager();
      await manager.init(
        collectionId: 'c1',
        verseId: null,
        initialPrompt: 'Romans 8:28',
        initialVerseText: 'And we know that in all things God works for the good...',
      );

      expect(manager.verseNotifier.value, isNotNull);
      expect(manager.verseNotifier.value!.prompt, 'Romans 8:28');
      expect(
        manager.verseNotifier.value!.text,
        'And we know that in all things God works for the good...',
      );

      // Wait for async promptExists check
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(manager.canAddNotifier.value, isTrue);
    });

    testWidgets('AddEditVersePage renders prefilled text fields and active Done button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AddEditVersePage(
            collectionId: 'c1',
            initialPrompt: 'Philippians 4:13',
            initialVerseText: 'I can do all things through Christ who strengthens me.',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Philippians 4:13'), findsOneWidget);
      expect(
        find.text('I can do all things through Christ who strengthens me.'),
        findsOneWidget,
      );

      // Verify Done button is enabled
      final doneButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.done),
          matching: find.byType(IconButton),
        ),
      );
      expect(doneButton.onPressed, isNotNull);

      // Tap Done button to save
      await tester.tap(find.byIcon(Icons.done));
      await tester.pumpAndSettle();

      expect(fakeStorage.verses.length, 1);
      expect(fakeStorage.verses.first.prompt, 'Philippians 4:13');
      expect(
        fakeStorage.verses.first.text,
        'I can do all things through Christ who strengthens me.',
      );
    });
  });

  group('SelectCollectionSheet', () {
    testWidgets('displays collections and allows selecting one', (tester) async {
      final collection1 = Collection(
        id: 'col-1',
        name: 'Gospels',
        studyStyle: StudyStyle.spacedRepetition,
        createdDate: DateTime.now(),
      );
      final collection2 = Collection(
        id: 'col-2',
        name: 'Epistles',
        studyStyle: StudyStyle.spacedRepetition,
        createdDate: DateTime.now(),
      );

      Collection? selectedResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    selectedResult = await SelectCollectionSheet.show(
                      context,
                      collections: [collection1, collection2],
                      localStorage: fakeStorage,
                    );
                  },
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      // Open sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Select Collection'), findsOneWidget);
      expect(find.text('Gospels'), findsOneWidget);
      expect(find.text('Epistles'), findsOneWidget);
      expect(find.text('Create new collection'), findsOneWidget);

      // Tap Gospels
      await tester.tap(find.text('Gospels'));
      await tester.pumpAndSettle();

      expect(selectedResult, isNotNull);
      expect(selectedResult!.id, 'col-1');
      expect(selectedResult!.name, 'Gospels');
    });

    testWidgets('allows creating a new collection directly from sheet using collection dialog', (tester) async {
      Collection? selectedResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    selectedResult = await SelectCollectionSheet.show(
                      context,
                      collections: [],
                      localStorage: fakeStorage,
                    );
                  },
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Create new collection'), findsOneWidget);
      await tester.tap(find.text('Create new collection'));
      await tester.pumpAndSettle();

      // Uses the app's standard Collection dialog
      expect(find.text('Collection'), findsOneWidget);
      expect(find.text('Review style'), findsOneWidget);

      // Enter name
      await tester.enterText(find.byType(TextField).first, 'Favorites');
      await tester.pumpAndSettle();

      // Tap OK
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(selectedResult, isNotNull);
      expect(selectedResult!.name, 'Favorites');
      expect(fakeStorage.collections.length, 1);
      expect(fakeStorage.collections.first.name, 'Favorites');
    });

    testWidgets('calls onCollectionCreated callback when creating a new collection', (tester) async {
      Collection? createdCollection;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await SelectCollectionSheet.show(
                      context,
                      collections: [],
                      localStorage: fakeStorage,
                      onCollectionCreated: (collection) {
                        createdCollection = collection;
                      },
                    );
                  },
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create new collection'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Promises');
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(createdCollection, isNotNull);
      expect(createdCollection!.name, 'Promises');
    });
  });

  group('DeepLinkService', () {
    testWidgets('handles deep link when no collections exist by directly opening collection dialog', (tester) async {
      var collectionsChangedCount = 0;
      final service = DeepLinkService(
        localStorage: fakeStorage,
        onCollectionsChanged: () {
          collectionsChangedCount++;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    service.handleUri(
                      context,
                      Uri.parse(
                        'memorizescripture://?prompt=Joel+2:1&text=Blow+the+ram’s+horn+in+Zion&version=BSB',
                      ),
                    );
                  },
                  child: const Text('Handle Link'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Handle Link'));
      await tester.pumpAndSettle();

      // Since there are no collections, collection creation dialog is shown directly!
      expect(find.text('Collection'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Bible Verses'), findsOneWidget);

      // Create a collection
      await tester.enterText(find.byType(TextField).first, 'Prophets');
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(collectionsChangedCount, greaterThanOrEqualTo(1));

      // Now AddEditVersePage is displayed with prefilled verse
      expect(find.text('Joel 2:1'), findsOneWidget);
      expect(find.text('Blow the ram’s horn in Zion'), findsOneWidget);

      // Save verse
      await tester.tap(find.byIcon(Icons.done));
      await tester.pumpAndSettle();

      // Back button pops page and notifies collections changed again
      await tester.tap(find.byType(IconButton).first);
      await tester.pumpAndSettle();

      expect(collectionsChangedCount, greaterThanOrEqualTo(2));
      expect(fakeStorage.verses.length, 1);
      expect(fakeStorage.verses.first.prompt, 'Joel 2:1');
    });

    testWidgets('handles deep link when collections exist by opening collection selection sheet', (tester) async {
      final existingCol = Collection(
        id: 'col-1',
        name: 'My Verses',
        studyStyle: StudyStyle.spacedRepetition,
        versesPerDay: 5,
        createdDate: DateTime.now(),
      );
      await fakeStorage.insertCollection(existingCol);

      final service = DeepLinkService(
        localStorage: fakeStorage,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    service.handleUri(
                      context,
                      Uri.parse(
                        'memorizescripture://add?prompt=John%201%3A1&text=In%20the%20beginning',
                      ),
                    );
                  },
                  child: const Text('Handle Link'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Handle Link'));
      await tester.pumpAndSettle();

      // The sheet should be shown with the existing collection
      expect(find.text('Select Collection'), findsOneWidget);
      expect(find.text('My Verses'), findsOneWidget);

      // Tap the existing collection
      await tester.tap(find.text('My Verses'));
      await tester.pumpAndSettle();

      // AddEditVersePage is displayed
      expect(find.text('John 1:1'), findsOneWidget);
      expect(find.text('In the beginning'), findsOneWidget);

      // Save verse
      await tester.tap(find.byIcon(Icons.done));
      await tester.pumpAndSettle();

      expect(fakeStorage.verses.length, 1);
      expect(fakeStorage.lastInsertedCollectionId, 'col-1');
    });

    testWidgets('showEditCollectionDialog supports defaultName and submits on keyboard done', (tester) async {
      Collection? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showEditCollectionDialog(context, defaultName: 'Bible Verses');
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Bible Verses'), findsOneWidget);

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.name, 'Bible Verses');
    });
  });
}

