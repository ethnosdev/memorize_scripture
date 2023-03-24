import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memorize_scripture/pages/about/about_page.dart';
import 'package:memorize_scripture/pages/add_verse/add_verse_page.dart';
import 'package:memorize_scripture/pages/edit_verse/edit_verse.dart';
import 'package:memorize_scripture/pages/home/home_page.dart';
import 'package:memorize_scripture/pages/practice/practice_page.dart';
import 'package:memorize_scripture/pages/settings/settings_page.dart';
import 'package:memorize_scripture/pages/verse_browser/verse_browser.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/app_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  await getIt<AppManager>().init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final manager = getIt<AppManager>();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeData>(
      valueListenable: manager.themeListener,
      builder: (context, theme, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Memorize Scripture',
          routerConfig: _router,
          theme: theme,
        );
      },
    );
  }
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      name: 'home',
      path: "/",
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          name: 'practice',
          path: "practice/:collection",
          builder: (context, state) => PracticePage(
            collection: state.params['collection']!,
          ),
          routes: [
            GoRoute(
              name: 'add',
              path: 'add',
              builder: (context, state) => AddVersePage(
                collection: state.params['collection']!,
              ),
            ),
            GoRoute(
              name: 'edit',
              path: 'edit/:verse',
              builder: (context, state) => EditVersePage(
                collectionId: state.params['collection']!,
                verseId: state.params['verse']!,
              ),
            ),
            GoRoute(
              name: 'verse_browser',
              path: 'verse_browser',
              builder: (context, state) => VerseBrowser(
                collection: state.params['collection']!,
              ),
            ),
          ],
        ),
        GoRoute(
          name: 'about',
          path: 'about',
          builder: (context, state) => const AboutPage(),
        ),
        GoRoute(
          name: 'settings',
          path: 'settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    ),
  ],
);
