import 'package:flutter/material.dart';
import 'package:memorize_scripture/go_router.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/app_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  await getIt<AppManager>().init();
  runApp(const MemorizeScriptureApp());
}

class MemorizeScriptureApp extends StatefulWidget {
  const MemorizeScriptureApp({super.key});

  @override
  State<MemorizeScriptureApp> createState() => _MemorizeScriptureAppState();
}

class _MemorizeScriptureAppState extends State<MemorizeScriptureApp> {
  final manager = getIt<AppManager>();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeData>(
      valueListenable: manager.themeListener,
      builder: (context, theme, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Memorize Scripture',
          routerConfig: router,
          theme: theme,
        );
      },
    );
  }
}
