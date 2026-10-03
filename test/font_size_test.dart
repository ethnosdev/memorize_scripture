import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memorize_scripture/app_manager.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/pages/add_edit_verse/add_edit_verse_page.dart';
import 'package:memorize_scripture/pages/home/home_page.dart';
import 'package:memorize_scripture/pages/home/home_page_manager.dart';
import 'package:memorize_scripture/pages/practice/practice_page_manager.dart';
import 'package:memorize_scripture/pages/practice/widgets/buttons.dart';
import 'package:memorize_scripture/pages/practice/widgets/prompt_answer_layout.dart';
import 'package:memorize_scripture/pages/practice/widgets/single_line_button.dart';
import 'package:memorize_scripture/pages/settings/settings_page.dart';
import 'package:memorize_scripture/pages/settings/settings_page_manager.dart';
import 'package:memorize_scripture/pages/verse_browser/verse_browser.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/local_storage/local_storage.dart';
import 'package:memorize_scripture/services/notification_service.dart';
import 'package:memorize_scripture/services/user_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeLocalStorage implements LocalStorage {
  final List<Verse> verses = [];
  final List<Collection> collections = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> init() async {}

  @override
  Future<List<Collection>> fetchCollections() async => collections;

  @override
  Future<List<Verse>> fetchAllVersesInCollection(String collectionId) async => verses;

  @override
  Future<int> numberInCollection(String collectionId) async => verses.length;

  @override
  Future<List<Verse>> fetchTodaysVerses({
    required Collection collection,
    int? newVerseLimit,
  }) async => verses;
}

class FakeNotificationService implements NotificationService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestNotificationPermission() async => true;

  @override
  Future<void> scheduleNotifications() async {}

  @override
  Future<void> clearNotifications() async {}
}

void main() {
  late UserSettings userSettings;
  late AppManager appManager;
  late FakeLocalStorage fakeLocalStorage;
  late FakeNotificationService fakeNotificationService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    userSettings = UserSettings();
    await userSettings.init();

    fakeLocalStorage = FakeLocalStorage();
    fakeNotificationService = FakeNotificationService();

    if (getIt.isRegistered<UserSettings>()) {
      getIt.unregister<UserSettings>();
    }
    getIt.registerSingleton<UserSettings>(userSettings);

    if (getIt.isRegistered<LocalStorage>()) {
      getIt.unregister<LocalStorage>();
    }
    getIt.registerSingleton<LocalStorage>(fakeLocalStorage);

    if (getIt.isRegistered<NotificationService>()) {
      getIt.unregister<NotificationService>();
    }
    getIt.registerSingleton<NotificationService>(fakeNotificationService);

    if (getIt.isRegistered<AppManager>()) {
      getIt.unregister<AppManager>();
    }
    appManager = AppManager();
    await appManager.init();
    getIt.registerSingleton<AppManager>(appManager);

    if (getIt.isRegistered<HomePageManager>()) {
      getIt.unregister<HomePageManager>();
    }
    getIt.registerSingleton<HomePageManager>(HomePageManager(
      localStorage: fakeLocalStorage,
      userSettings: userSettings,
    ));
  });

  tearDown(() {
    if (getIt.isRegistered<HomePageManager>()) {
      getIt.unregister<HomePageManager>();
    }
    if (getIt.isRegistered<UserSettings>()) {
      getIt.unregister<UserSettings>();
    }
    if (getIt.isRegistered<LocalStorage>()) {
      getIt.unregister<LocalStorage>();
    }
    if (getIt.isRegistered<NotificationService>()) {
      getIt.unregister<NotificationService>();
    }
    if (getIt.isRegistered<AppManager>()) {
      getIt.unregister<AppManager>();
    }
  });

  group('UserSettings font size', () {
    test('default font size is 20.0', () {
      expect(userSettings.fontSize, equals(20.0));
      expect(UserSettings.defaultFontSize, equals(20.0));
      expect(UserSettings.minFontSize, equals(10.0));
      expect(UserSettings.maxFontSize, equals(40.0));
    });

    test('setFontSize updates stored and returned value', () async {
      await userSettings.setFontSize(24.0);
      expect(userSettings.fontSize, equals(24.0));
    });
  });

  group('SettingsPageManager font size', () {
    test('fontSize initially matches userSettings default', () {
      final manager = SettingsPageManager();
      expect(manager.fontSize, equals(20.0));
    });

    test('validateFontSize clamps lower and upper bounds and parses ints', () {
      final manager = SettingsPageManager();
      expect(manager.validateFontSize('5'), equals('10'));
      expect(manager.validateFontSize('50'), equals('40'));
      expect(manager.validateFontSize('24'), equals('24'));
      expect(manager.validateFontSize('invalid'), equals('20'));
    });

    test('updateFontSize persists and updates AppManager and notifies listeners', () async {
      final manager = SettingsPageManager();
      bool notified = false;
      manager.addListener(() => notified = true);

      await manager.updateFontSize('26');
      expect(userSettings.fontSize, equals(26.0));
      expect(appManager.fontSize, equals(26.0));
      expect(manager.fontSize, equals(26.0));
      expect(notified, isTrue);
    });

    test('setFontSize directly sets double value', () async {
      final manager = SettingsPageManager();
      await manager.setFontSize(18.0);
      expect(userSettings.fontSize, equals(18.0));
      expect(appManager.fontSize, equals(18.0));
      expect(manager.fontSize, equals(18.0));
    });
  });

  group('AppManager font size and theme scaling', () {
    test('setFontSize updates fontSizeNotifier and scaledFontSize', () {
      appManager.setFontSize(25.0);
      expect(appManager.fontSize, equals(25.0));
      expect(appManager.fontSizeNotifier.value, equals(25.0));
      expect(appManager.scaledFontSize(0.8), equals(20.0));
      expect(appManager.scaledFontSize(1.2), equals(30.0));
    });

    test('lightTheme and darkTheme textTheme scale by font size factor, but buttons (labelLarge) remain unscaled', () {
      final theme20 = AppManager.lightTheme(20.0);
      final theme30 = AppManager.lightTheme(30.0);

      expect(theme30.textTheme.bodyMedium?.fontSize,
          equals((theme20.textTheme.bodyMedium?.fontSize ?? 14.0) * 1.5));
      expect(theme30.textTheme.labelLarge?.fontSize,
          equals(theme20.textTheme.labelLarge?.fontSize));
    });
  });

  group('SettingsPage font size UI widget tests', () {
    testWidgets('renders Font size ListTile with current value in Appearance section',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Font size'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('tapping Font size tile opens font size dialog with "Text" over Slider, without title, Cancel, or +/- buttons',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsPage(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'Font size'));
      await tester.pumpAndSettle();

      final dialogFinder = find.byType(AlertDialog);
      expect(dialogFinder, findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);

      // Verify no title in dialog
      expect(
        find.descendant(of: dialogFinder, matching: find.text('Font size')),
        findsNothing,
      );

      // Verify no Cancel button
      expect(find.text('Cancel'), findsNothing);

      // Verify no + or - buttons
      expect(find.byIcon(Icons.add), findsNothing);
      expect(find.byIcon(Icons.remove), findsNothing);

      // Verify only 'Text' is shown over slider and no numbers in dialog
      final textFinder = find.descendant(of: dialogFinder, matching: find.text('Text'));
      expect(textFinder, findsOneWidget);

      // Verify initial preview font size matches current font size (20)
      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.fontSize, equals(20.0));

      final sliderWidget = tester.widget<Slider>(find.byType(Slider));
      expect(sliderWidget.label, equals('20'));
      expect(sliderWidget.divisions, equals(30));

      // Tap OK
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('dragging slider shows popup over thumb with font size',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsPage(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'Font size'));
      await tester.pumpAndSettle();

      final sliderFinder = find.byType(Slider);

      // Start gesture on slider to display the value indicator popup over thumb
      final gesture = await tester.startGesture(tester.getCenter(sliderFinder));
      await tester.pumpAndSettle();

      final slider = tester.widget<Slider>(sliderFinder);
      expect(slider.label, isNotNull);
      // Value indicator popup paints paragraph in the Overlay
      expect(tester.renderObject(find.byType(Overlay)), paints..paragraph());

      // Drag slider to the right
      await gesture.moveBy(const Offset(80, 0));
      await tester.pumpAndSettle();

      expect(tester.renderObject(find.byType(Overlay)), paints..paragraph());

      await gesture.up();
      await tester.pumpAndSettle();

      // Tap OK
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });

    testWidgets('dialog size does not change when dragging slider to change font size',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsPage(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'Font size'));
      await tester.pumpAndSettle();

      final dialogFinder = find.byType(AlertDialog);
      final initialSize = tester.getSize(dialogFinder);

      // Drag slider towards max
      final sliderFinder = find.byType(Slider);
      await tester.drag(sliderFinder, const Offset(150, 0));
      await tester.pumpAndSettle();

      final newSize = tester.getSize(dialogFinder);
      expect(newSize.height, equals(initialSize.height));
      expect(newSize.width, equals(initialSize.width));

      // Tap OK
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });

    testWidgets('adjusting font size via Slider in dialog updates font size',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsPage(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'Font size'));
      await tester.pumpAndSettle();

      final sliderFinder = find.byType(Slider);
      // Drag slider to the right
      await tester.drag(sliderFinder, const Offset(100, 0));
      await tester.pumpAndSettle();

      // Tap OK
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(userSettings.fontSize, greaterThan(20.0));
      expect(appManager.fontSize, equals(userSettings.fontSize));
    });
  });

  group('Verse and widget font size scaling', () {
    testWidgets('PromptAnswerLayout renders Prompt and Answer at manager.fontSize and counter scaled',
        (tester) async {
      await userSettings.setFontSize(24.0);
      final practiceManager = PracticePageManager(
        localStorage: fakeLocalStorage,
        userSettings: userSettings,
      );

      final verse = Verse(
        id: 'v1',
        prompt: 'Genesis 1:1',
        text: 'In the beginning God created the heavens and the earth.',
      );
      fakeLocalStorage.verses.add(verse);
      final collection = Collection(
        id: 'c1',
        name: 'Test Collection',
        studyStyle: StudyStyle.spacedRepetition,
        createdDate: DateTime.now(),
      );
      await practiceManager.init(collection: collection);
      practiceManager.show();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PromptAnswerLayout(manager: practiceManager),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Prompt SelectableText
      final promptFinder = find.byType(Prompt);
      expect(promptFinder, findsOneWidget);
      final promptSelectable = tester.widget<SelectableText>(
        find.descendant(of: promptFinder, matching: find.byType(SelectableText)),
      );
      expect(promptSelectable.style?.fontSize, equals(24.0));

      // Answer SelectableText
      final answerFinder = find.byType(Answer);
      expect(answerFinder, findsOneWidget);
      final answerSelectable = tester.widget<SelectableText>(
        find.descendant(of: answerFinder, matching: find.byType(SelectableText)),
      );
      expect(answerSelectable.style?.fontSize, equals(24.0));

      // Counter Text
      final counterFinder = find.byType(Counter);
      final counterText = tester.widget<Text>(
        find.descendant(of: counterFinder, matching: find.byType(Text)),
      );
      expect(counterText.style?.fontSize, equals(24.0 * 0.8));
    });

    testWidgets('VerseBrowser tiles scale based on saved font size', (tester) async {
      await userSettings.setFontSize(25.0);
      final verse = Verse(
        id: '1',
        prompt: 'John 3:16',
        text: 'For God so loved the world...',
      );
      fakeLocalStorage.verses.add(verse);
      final collection = Collection(
        id: 'c1',
        name: 'Test Collection',
        studyStyle: StudyStyle.spacedRepetition,
        createdDate: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: VerseBrowser(collection: collection),
        ),
      );
      await tester.pumpAndSettle();

      // By default 2 columns
      final richTexts = tester.widgetList<RichText>(find.byType(RichText)).toList();
      expect(richTexts.isNotEmpty, isTrue);
      // In 2 columns, font size is 25.0 * 0.8 = 20.0
      expect(richTexts.any((rt) => rt.text.style?.fontSize == 20.0), isTrue);

      // Switch to 1 column
      await tester.tap(find.byIcon(Icons.table_rows_outlined));
      await tester.pumpAndSettle();

      final richTexts1Col = tester.widgetList<RichText>(find.byType(RichText)).toList();
      // In 1 column, font size is 25.0
      expect(richTexts1Col.any((rt) => rt.text.style?.fontSize == 25.0), isTrue);
    });

    testWidgets('AddEditVersePage text fields use manager.fontSize', (tester) async {
      await userSettings.setFontSize(22.0);

      await tester.pumpWidget(
        const MaterialApp(
          home: AddEditVersePage(collectionId: 'c1'),
        ),
      );
      await tester.pumpAndSettle();

      final textFields = tester.widgetList<TextField>(find.byType(TextField)).toList();
      expect(textFields.length, greaterThanOrEqualTo(2));
      for (final tf in textFields) {
        expect(tf.style?.fontSize, equals(22.0));
      }
    });

    testWidgets('SingleLineButton text remains standard size and does not blow up at max font size',
        (tester) async {
      await userSettings.setFontSize(40.0);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppManager.lightTheme(40.0),
          home: const Scaffold(
            body: SizedBox(
              width: 100,
              child: SingleLineButton(title: 'Letters'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textFinder = find.text('Letters');
      expect(textFinder, findsNWidgets(2)); // background invisible text + visible text

      // Visible text has standard button labelLarge font size (14.0), NOT scaled to 34 or 40
      final visibleText = tester.widget<Text>(textFinder.last);
      expect(visibleText.style?.fontSize, equals(14.0));
    });

    testWidgets('Delete account button in 200px width retains standard label size at max font size',
        (tester) async {
      await userSettings.setFontSize(40.0);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppManager.lightTheme(40.0),
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Delete account'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // In Material 3, OutlinedButton default text style uses labelLarge (14pt)
      final textElement = find.text('Delete account').evaluate().single;
      final defaultStyle = DefaultTextStyle.of(textElement).style;
      expect(defaultStyle.fontSize, equals(14.0));
    });

    testWidgets('ResponseButton and ShowButton maintain standard button font size at max font size',
        (tester) async {
      await userSettings.setFontSize(40.0);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppManager.lightTheme(40.0),
          home: Scaffold(
            body: Column(
              children: [
                ResponseButton(
                  title: 'Good',
                  subtitle: '7 days',
                  onPressed: () {},
                ),
                ShowButton(onPressed: () {}),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final goodFinder = find.text('Good');
      expect(goodFinder, findsOneWidget);
      final goodWidget = tester.widget<Text>(goodFinder);
      expect(goodWidget.style?.fontSize, equals(14.0));

      final subtitleFinder = find.text('7 days');
      expect(subtitleFinder, findsOneWidget);
      final subtitleWidget = tester.widget<Text>(subtitleFinder);
      expect(subtitleWidget.style?.fontSize, equals(11.0));

      final showFinder = find.text('Show');
      expect(showFinder, findsOneWidget);
      final showElement = showFinder.evaluate().single;
      expect(DefaultTextStyle.of(showElement).style.fontSize, equals(14.0));
    });

    testWidgets('Collection names in HomePage resize immediately when font size changes without restart',
        (tester) async {
      final collection = Collection(
        id: 'c1',
        name: 'My Special Collection',
        studyStyle: StudyStyle.spacedRepetition,
        createdDate: DateTime.now(),
      );
      fakeLocalStorage.collections.add(collection);
      final homeManager = getIt<HomePageManager>();
      await homeManager.init();

      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );
      await tester.pumpAndSettle();

      final collectionFinder = find.text('My Special Collection');
      expect(collectionFinder, findsOneWidget);
      final initialText = tester.widget<Text>(collectionFinder);
      expect(initialText.style?.fontSize, equals(20.0 * 0.9)); // 18.0

      // Change font size via userSettings and appManager
      await userSettings.setFontSize(30.0);
      appManager.setFontSize(30.0);
      await tester.pumpAndSettle();

      final updatedText = tester.widget<Text>(collectionFinder);
      expect(updatedText.style?.fontSize, equals(30.0 * 0.9)); // 27.0
    });

    testWidgets('NoCollections text in HomePage resizes immediately when font size changes without restart',
        (tester) async {
      final homeManager = getIt<HomePageManager>();
      await homeManager.init();

      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );
      await tester.pumpAndSettle();

      final emptyFinder = find.text('Press the + button to add a collection.');
      expect(emptyFinder, findsOneWidget);
      final initialText = tester.widget<Text>(emptyFinder);
      expect(initialText.style?.fontSize, equals(20.0 * 0.9));

      // Change font size
      await userSettings.setFontSize(32.0);
      appManager.setFontSize(32.0);
      await tester.pumpAndSettle();

      final updatedText = tester.widget<Text>(emptyFinder);
      expect(updatedText.style?.fontSize, equals(32.0 * 0.9));
    });
  });
}
