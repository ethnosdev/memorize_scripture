import 'package:flutter/material.dart';
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
            Container(
              color: Colors.blue,
              width: 100,
              height: 100,
            ),
            Text(
              'Memorize Scripture',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            ValueListenableBuilder<String>(
              valueListenable: manager.versionNotifier,
              builder: (context, version, child) {
                return Text('Version $version');
              },
            ),
          ],
        ),
      ),
    );
  }
}
