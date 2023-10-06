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
  static const add = 'add';
  static const edit = 'edit';
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
              collectionId: state.uri.queryParameters[Params.colId] as String,
              collectionName:
                  state.uri.queryParameters[Params.colName] as String,
            );
          },
        ),
        GoRoute(
          name: RouteName.verseBrowser,
          path: 'verse_browser',
          builder: (context, state) => VerseBrowser(
            collectionId: state.uri.queryParameters[Params.colId] as String,
            collectionName: state.uri.queryParameters[Params.colName] as String,
            onFinished: state.extra as void Function(String?)?,
          ),
        ),
        GoRoute(
          name: RouteName.edit,
          path: 'edit',
          builder: (context, state) => AddEditVersePage(
            collectionId: state.uri.queryParameters[Params.colId] as String,
            verseId: state.uri.queryParameters[Params.verseId] as String,
            onFinished: state.extra as void Function(String?)?,
          ),
        ),
        GoRoute(
          name: RouteName.add,
          path: 'add',
          builder: (context, state) => AddEditVersePage(
            collectionId: state.uri.queryParameters[Params.colId] as String,
            onFinished: state.extra as void Function(String?)?,
          ),
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
