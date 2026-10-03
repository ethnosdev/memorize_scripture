import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/pages/account/account_page.dart';
import 'package:memorize_scripture/pages/account/account_page_manager.dart';
import 'package:memorize_scripture/pages/account/shared/account_screen_type.dart';
import 'package:memorize_scripture/pages/home/home_page.dart';
import 'package:memorize_scripture/pages/home/home_page_manager.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/backend/auth/auth_service.dart';
import 'package:memorize_scripture/services/backend/auth/user.dart';
import 'package:memorize_scripture/services/backend/backend_service.dart';
import 'package:memorize_scripture/services/backend/exceptions.dart';
import 'package:memorize_scripture/services/backend/web_api/web_api.dart';
import 'package:memorize_scripture/services/local_storage/local_storage.dart';
import 'package:memorize_scripture/services/secure_settings.dart';
import 'package:memorize_scripture/services/user_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeSecureStorage implements SecureStorage {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<String?> getEmail() async => null;

  @override
  Future<String?> getToken() async => null;
}

class FakeLocalStorage implements LocalStorage {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<Collection>> fetchCollections() async => [];
}

class FakeBackendService implements BackendService {
  bool initDelay = true;
  bool isInitialized = false;
  User? currentUser;
  bool syncThrowsUserNotLoggedIn = false;

  @override
  Future<void> init() async {
    if (isInitialized) return;
    if (initDelay) {
      // Simulate async storage read on first init
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    isInitialized = true;
  }

  @override
  AuthService get auth => FakeAuthService(currentUser);

  @override
  WebApi get webApi => FakeWebApi(syncThrowsUserNotLoggedIn);
}

class FakeAuthService implements AuthService {
  FakeAuthService(this._user);
  final User? _user;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  User? getUser() => _user;

  @override
  Future<User?> refreshUser() async => _user;
}

class FakeWebApi implements WebApi {
  FakeWebApi(this._syncThrowsUserNotLoggedIn);
  final bool _syncThrowsUserNotLoggedIn;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> syncVerses({
    required User? user,
    required void Function(String p1) onFinished,
  }) async {
    if (user == null || _syncThrowsUserNotLoggedIn) {
      throw UserNotLoggedInException();
    }
    onFinished('Sync complete');
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    if (getIt.isRegistered<SecureStorage>()) getIt.unregister<SecureStorage>();
    if (getIt.isRegistered<LocalStorage>()) getIt.unregister<LocalStorage>();
    if (getIt.isRegistered<UserSettings>()) getIt.unregister<UserSettings>();
    if (getIt.isRegistered<HomePageManager>()) getIt.unregister<HomePageManager>();
    if (getIt.isRegistered<BackendService>()) getIt.unregister<BackendService>();

    final userSettings = UserSettings();
    await userSettings.init();
    getIt.registerSingleton<SecureStorage>(FakeSecureStorage());
    getIt.registerSingleton<LocalStorage>(FakeLocalStorage());
    getIt.registerSingleton<UserSettings>(userSettings);
    getIt.registerSingleton<HomePageManager>(HomePageManager());
    getIt.registerSingleton<BackendService>(FakeBackendService());
  });

  tearDown(() {
    getIt.reset();
  });

  testWidgets('tapping Sync when not logged in navigates to AccountPage on first try', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomePage(),
      ),
    );
    await tester.pumpAndSettle();

    // Find and tap the popup menu button
    final popupButton = find.byType(PopupMenuButton<int>);
    expect(popupButton, findsOneWidget);
    await tester.tap(popupButton);
    await tester.pumpAndSettle();

    // Find and tap "Sync"
    final syncItem = find.text('Sync');
    expect(syncItem, findsOneWidget);
    await tester.tap(syncItem);

    // Let async operations and animations run
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpAndSettle();

    // Check if AccountPage is displayed on first try
    expect(find.byType(AccountPage), findsOneWidget);
  });

  testWidgets('tapping Sync when session expired (UserNotLoggedInException during sync) navigates to AccountPage on first try', (tester) async {
    final backendService = FakeBackendService();
    // Simulate user being locally present but server rejecting token with UserNotLoggedInException
    backendService.currentUser = User(id: 'u1', email: 'test@example.com', token: 'expired');
    backendService.syncThrowsUserNotLoggedIn = true;
    getIt.unregister<BackendService>();
    getIt.registerSingleton<BackendService>(backendService);

    await tester.pumpWidget(
      const MaterialApp(
        home: HomePage(),
      ),
    );
    await tester.pumpAndSettle();

    final popupButton = find.byType(PopupMenuButton<int>);
    await tester.tap(popupButton);
    await tester.pumpAndSettle();

    final syncItem = find.text('Sync');
    await tester.tap(syncItem);

    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpAndSettle();

    expect(find.byType(AccountPage), findsOneWidget);
  });

  testWidgets('tapping Sync when logged in and sync succeeds does not navigate to AccountPage', (tester) async {
    final backendService = FakeBackendService();
    backendService.currentUser = User(id: 'u1', email: 'test@example.com', token: 'valid');
    getIt.unregister<BackendService>();
    getIt.registerSingleton<BackendService>(backendService);

    await tester.pumpWidget(
      const MaterialApp(
        home: HomePage(),
      ),
    );
    await tester.pumpAndSettle();

    final popupButton = find.byType(PopupMenuButton<int>);
    await tester.tap(popupButton);
    await tester.pumpAndSettle();

    final syncItem = find.text('Sync');
    await tester.tap(syncItem);

    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpAndSettle();

    // Still on HomePage, not AccountPage
    expect(find.byType(AccountPage), findsNothing);
    expect(find.byType(HomePage), findsOneWidget);
  });

  test('AccountPageManager.init refreshes user and shows LoggedIn state', () async {
    final backendService = FakeBackendService();
    backendService.currentUser = User(id: 'u1', email: 'test@example.com', token: 'refreshed_token');
    getIt.unregister<BackendService>();
    getIt.registerSingleton<BackendService>(backendService);

    final manager = AccountPageManager();
    await manager.init();

    expect(manager.screenNotifier.value, isA<LoggedIn>());
    final loggedInState = manager.screenNotifier.value as LoggedIn;
    expect(loggedInState.user.email, 'test@example.com');
  });
}
