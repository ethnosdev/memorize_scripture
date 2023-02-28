import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:memorize_scripture/common/drawer.dart';
import 'package:memorize_scripture/pages/home/home_page_manager.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memorize Scripture'),
      ),
      drawer: const MenuDrawer(),
      body: const BodyWidget(),
    );
  }
}

class BodyWidget extends StatefulWidget {
  const BodyWidget({
    super.key,
  });

  @override
  State<BodyWidget> createState() => _BodyWidgetState();
}

class _BodyWidgetState extends State<BodyWidget> {
  final manager = HomePageManager();

  @override
  void initState() {
    super.initState();
    manager.init();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ValueListenableBuilder<List<String>>(
              valueListenable: manager.collectionNotifier,
              builder: (context, collectionNames, child) {
                return ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  itemCount: collectionNames.length,
                  itemBuilder: (context, index) {
                    final name = collectionNames[index];
                    return Card(
                      key: ValueKey(name),
                      child: ReorderableDragStartListener(
                        index: index,
                        child: ListTile(
                          title: Text(name),
                          onTap: () {
                            context.goNamed(
                              'practice',
                              params: {'collection': name},
                            );
                          },
                        ),
                      ),
                    );
                  },
                  onReorder: (int oldIndex, int newIndex) {
                    manager.onCollectionItemReordered(oldIndex, newIndex);
                  },
                );
              }),
        ),
        OutlinedButton(
          onPressed: () async {
            final name = await _showNewCollectionDialog();
            print(name);
          },
          child: const Text('Add Collection'),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<String?> _showNewCollectionDialog() async {
    final controller = TextEditingController();
    Widget continueButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop(controller.text);
        manager.addCollection(controller.text);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Name"),
      content: TextField(
        autofocus: true,
        controller: controller,
      ),
      actions: [continueButton],
    );

    // show the dialog
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
