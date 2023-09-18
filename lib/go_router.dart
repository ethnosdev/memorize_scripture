import 'package:go_router/go_router.dart';
import 'package:memorize_scripture/pages/about/about_page.dart';
import 'package:memorize_scripture/pages/add_edit_verse/add_edit_verse_page.dart';
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
  static const practiceAdd = 'practice-add';
  static const practiceEdit = 'practice-edit';
  static const practiceBrowser = 'practice-browser';
  static const browserAdd = 'browser-add';
  static const browserEdit = 'browser-edit';
  static const verseBrowser = 'verse-browser';
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
              collectionId: state.queryParameters[Params.colId] as String,
              collectionName: state.queryParameters[Params.colName] as String,
            );
          },
          routes: [
            GoRoute(
              name: RouteName.practiceAdd,
              path: 'add',
              builder: (context, state) => AddEditVersePage(
                collectionId: state.queryParameters[Params.colId] as String,
                onFinished: state.extra as void Function(String?)?,
              ),
            ),
            GoRoute(
              name: RouteName.practiceEdit,
              path: 'edit',
              builder: (context, state) => AddEditVersePage(
                collectionId: state.queryParameters[Params.colId] as String,
                verseId: state.queryParameters[Params.verseId] as String,
                onFinished: state.extra as void Function(String?)?,
              ),
            ),
            GoRoute(
              name: RouteName.practiceBrowser,
              path: 'verse_browser',
              builder: (context, state) => VerseBrowser(
                collectionId: state.queryParameters[Params.colId] as String,
                collectionName: state.queryParameters[Params.colName] as String,
              ),
            ),
          ],
        ),
        GoRoute(
          name: RouteName.verseBrowser,
          path: 'verse_browser',
          builder: (context, state) => VerseBrowser(
            collectionId: state.queryParameters[Params.colId] as String,
            collectionName: state.queryParameters[Params.colName] as String,
          ),
          routes: [
            GoRoute(
              name: RouteName.browserEdit,
              path: 'edit',
              builder: (context, state) => AddEditVersePage(
                collectionId: state.queryParameters[Params.colId] as String,
                verseId: state.queryParameters[Params.verseId] as String,
                onFinished: state.extra as void Function(String?)?,
              ),
            ),
            GoRoute(
              name: RouteName.browserAdd,
              path: 'add',
              builder: (context, state) => AddEditVersePage(
                collectionId: state.queryParameters[Params.colId] as String,
                onFinished: state.extra as void Function(String?)?,
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
