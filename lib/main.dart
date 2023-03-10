import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memorize_scripture/pages/about/about_page.dart';
import 'package:memorize_scripture/pages/add_verse/add_verse_page.dart';
import 'package:memorize_scripture/pages/home/home_page.dart';
import 'package:memorize_scripture/pages/practice/practice_page.dart';
import 'package:memorize_scripture/pages/settings/settings_page.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/user_settings.dart';
import 'package:memorize_scripture/theme_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  await _setDarkLightTheme();
  runApp(const MyApp());
}

Future<void> _setDarkLightTheme() async {
  final userSettings = getIt<UserSettings>();
  final isDarkTheme = await userSettings.getDarkMode();
  final themeManager = getIt<ThemeManager>();
  themeManager.setDarkTheme(isDarkTheme);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final manager = getIt<ThemeManager>();

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
