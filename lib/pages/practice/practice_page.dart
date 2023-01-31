import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/drawer.dart';

class PracticePage extends StatelessWidget {
  const PracticePage({
    super.key,
    required this.collection,
  });

  final String collection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(collection),
      ),
      drawer: const MenuDrawer(),
      body: Stack(
        children: [
          const Text('12'),
          Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'John 15:1',
                ),
                const SizedBox(height: 20),
                Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).disabledColor,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton(
                              onPressed: () {},
                              child: const Text('Letters'),
                            ),
                            const SizedBox(width: 20),
                            OutlinedButton(
                              onPressed: () {},
                              child: const Text('Word'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 3,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Text(
                          'Hints',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton(
                    onPressed: () {},
                    child: Container(
                      padding: EdgeInsets.all(16),
                      width: double.infinity,
                      child: Center(child: Text('Show')),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
