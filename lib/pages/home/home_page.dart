import 'package:flutter/material.dart';
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
                return ListView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    final name = collectionNames[index];
                    return Card(
                      child: ListTile(
                        title: Text(name),
                        onTap: () {
                          context.goNamed(
                            'practice',
                            params: {'collection': name},
                          );
                        },
                      ),
                    );
                  },
                );
              }),
        ),
        OutlinedButton(
          onPressed: () {},
          child: const Text('Add Collection'),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
