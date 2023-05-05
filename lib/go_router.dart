import 'package:go_router/go_router.dart';
import 'package:memorize_scripture/pages/about/about_page.dart';
import 'package:memorize_scripture/pages/add_verse/add_verse_page.dart';
import 'package:memorize_scripture/pages/edit_verse/edit_verse.dart';
import 'package:memorize_scripture/pages/home/home_page.dart';
import 'package:memorize_scripture/pages/practice/practice_page.dart';
import 'package:memorize_scripture/pages/settings/settings_page.dart';
import 'package:memorize_scripture/pages/verse_browser/verse_browser.dart';

class Params {
  static const colId = 'collectionId';
  static const colName = 'collectionName';
  static const verseId = 'verseId';
}

class RouteName {
  static const home = 'home';
  static const practice = 'practice';
  static const add = 'add';
  static const editPractice = 'edit_practice';
  static const editBrowser = 'edit_browser';
  static const verseBrowser = 'verse_browser';
  static const about = 'about';
  static const settings = 'settings';
}

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      name: RouteName.home,
      path: "/",
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          name: RouteName.practice,
          path: 'practice',
          builder: (context, state) {
            return PracticePage(
              collectionId: state.queryParams[Params.colId] as String,
              collectionName: state.queryParams[Params.colName] as String,
            );
          },
          routes: [
            GoRoute(
              name: RouteName.add,
              path: 'add',
              builder: (context, state) => AddVersePage(
                collectionId: state.queryParams[Params.colId] as String,
                collectionName: state.queryParams[Params.colName] as String,
                onVerseAdded: state.extra as void Function()?,
              ),
            ),
            GoRoute(
              name: RouteName.editPractice,
              path: 'edit',
              builder: (context, state) => EditVersePage(
                collectionId: state.queryParams[Params.colId] as String,
                verseId: state.queryParams[Params.verseId] as String,
                onFinishedEditing: state.extra as void Function(String?)?,
              ),
            ),
          ],
        ),
        GoRoute(
          name: RouteName.verseBrowser,
          path: 'verse_browser',
          builder: (context, state) => VerseBrowser(
            collectionId: state.queryParams[Params.colId] as String,
            collectionName: state.queryParams[Params.colName] as String,
          ),
          routes: [
            GoRoute(
              name: RouteName.editBrowser,
              path: 'edit',
              builder: (context, state) => EditVersePage(
                collectionId: state.queryParams[Params.colId] as String,
                verseId: state.queryParams[Params.verseId] as String,
                onFinishedEditing: state.extra as void Function(String?)?,
              ),
            ),
          ],
        ),
        GoRoute(
          name: RouteName.about,
          path: 'about',
          builder: (context, state) => const AboutPage(),
        ),
        GoRoute(
          name: RouteName.settings,
          path: 'settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    ),
  ],
);
