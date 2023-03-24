import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/verse_browser/verse_browser_manager.dart';

class VerseBrowser extends StatefulWidget {
  const VerseBrowser({
    super.key,
    required this.collection,
  });

  final String collection;

  @override
  State<VerseBrowser> createState() => _VerseBrowserState();
}

class _VerseBrowserState extends State<VerseBrowser> {
  final manager = VerseBrowserManager();

  @override
  void initState() {
    super.initState();
    manager.init(widget.collection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collection),
      ),
      body: ValueListenableBuilder(
        valueListenable: manager.listNotifier,
        builder: (context, list, child) {
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final verse = list[index];
              return ListTile(
                title: Row(
                  children: [
                    Expanded(
                        child: Text(
                      verse.prompt,
                      style: Theme.of(context).textTheme.bodySmall,
                    )),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(
                      verse.answer,
                      style: Theme.of(context).textTheme.bodySmall,
                    )),
                  ],
                ),
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }
}
