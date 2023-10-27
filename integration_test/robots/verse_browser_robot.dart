import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class VerseBrowserRobot {
  VerseBrowserRobot(this.tester);
  final WidgetTester tester;

  Future<void> verifyEmpty() async {
    final listView = find.byType(ListView);
    expect(listView, findsOneWidget);
    final listTile = find.descendant(
      of: listView,
      matching: find.byType(ListTile),
    );
    expect(listTile, findsNothing);
  }
}
