import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/home/home_page.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/app_manager.dart';
import 'package:memorize_scripture/services/deep_link_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  await getIt<AppManager>().init();
  getIt<DeepLinkService>().init();
  runApp(const MemorizeScriptureApp());
}

class MemorizeScriptureApp extends StatefulWidget {
  const MemorizeScriptureApp({super.key});

  @override
  State<MemorizeScriptureApp> createState() => _MemorizeScriptureAppState();
}

class _MemorizeScriptureAppState extends State<MemorizeScriptureApp> {
  final manager = getIt<AppManager>();
  final deepLinkService = getIt<DeepLinkService>();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: manager.themeNotifier,
      builder: (context, mode, child) {
        return MaterialApp(
          navigatorKey: deepLinkService.navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Memorize Scripture',
          theme: AppManager.lightTheme,
          darkTheme: AppManager.darkTheme,
          themeMode: mode,
          home: const HomePage(),
          onGenerateRoute: (settings) {
            final uri = Uri.tryParse(settings.name ?? '');
            if (uri != null && DeepLinkData.fromUri(uri) != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                deepLinkService.handleUri(uri);
              });
            }
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => const HomePage(),
            );
          },
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => const HomePage(),
            );
          },
        );
      },
    );
  }
}
