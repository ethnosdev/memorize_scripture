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

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      name: 'home',
      path: "/",
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          name: 'practice',
          path: 'practice',
          builder: (context, state) {
            return PracticePage(
              collectionId: state.queryParams[Params.colId] as String,
              collectionName: state.queryParams[Params.colName] as String,
            );
          },
          routes: [
            GoRoute(
              name: 'add',
              path: 'add',
              builder: (context, state) => AddVersePage(
                collectionId: state.queryParams[Params.colId] as String,
                collectionName: state.queryParams[Params.colName] as String,
              ),
            ),
            GoRoute(
              name: 'edit',
              path: 'edit',
              builder: (context, state) => EditVersePage(
                collectionId: state.queryParams[Params.colId] as String,
                collectionName: state.queryParams[Params.colName] as String,
                verseId: state.queryParams[Params.verseId] as String,
                onFinishedEditing: state.extra as void Function(String?)?,
              ),
            ),
          ],
        ),
        GoRoute(
          name: 'verse_browser',
          path: 'verse_browser',
          builder: (context, state) => VerseBrowser(
            collectionId: state.queryParams[Params.colId] as String,
            collectionName: state.queryParams[Params.colName] as String,
          ),
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
