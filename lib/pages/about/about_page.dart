import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:memorize_scripture/pages/about/about_page_manager.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final manager = AboutPageManager();

  @override
  void initState() {
    super.initState();
    manager.lookupVersionNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SvgPicture.asset(
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                ),
                'assets/logo.svg',
                width: 100,
                height: 100,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Memorize Scripture',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 5),
            ValueListenableBuilder<String>(
              valueListenable: manager.versionNotifier,
              builder: (context, version, child) {
                return Text('Version $version');
              },
            ),
            const SizedBox(height: 5),
            const SelectableText('contact@ethnos.dev'),
          ],
        ),
      ),
    );
  }
}
