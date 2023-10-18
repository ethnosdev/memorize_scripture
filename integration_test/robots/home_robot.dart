import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class HomeRobot {
  HomeRobot(this.tester);
  final WidgetTester tester;

  Future<void> clickNewCollectionButton() async {
    final addButton = find.byIcon(Icons.add);
    await tester.tap(addButton);
    await tester.pumpAndSettle();
  }
}
