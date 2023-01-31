import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memorize_scripture/pages/home/home_page.dart';
import 'package:memorize_scripture/pages/practice/practice_page.dart';
import 'package:memorize_scripture/service_locator.dart';

Future<void> main() async {
  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Memorize Scripture',
      routerConfig: _router,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.lightBlue.shade800,
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 14),
          labelSmall: TextStyle(color: Theme.of(context).disabledColor),
        ),
      ),
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
        ),
      ],
    ),
  ],
);
