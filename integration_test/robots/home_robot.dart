import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class HomeRobot {
  HomeRobot(this.tester);
  final WidgetTester tester;

  Future<void> tapNewCollectionButton() async {
    await tester.pumpAndSettle();
    final addButton = find.byIcon(Icons.add);
    await tester.tap(addButton);
    await tester.pumpAndSettle();
  }

  Future<void> enterCollectionName(String name) async {
    final textField = find.byType(TextField);
    await tester.enterText(textField, name);
    await tester.pumpAndSettle();
  }

  Future<void> tapOk() async {
    final button = find.text('OK');
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  Future<void> longPressCollection(String name) async {
    final listItem = find.text(name);
    await tester.longPress(listItem);
    await tester.pumpAndSettle();
    await tester.pump(Duration(seconds: 1));
  }

  Future<void> tapMenuItem(String name) async {
    await tester.pumpAndSettle();
    final menuItem = find.text(name);
    await tester.tap(menuItem);
    await tester.pumpAndSettle();
  }

  Future<void> verifySnackbarShows() async {
    final snackBar = find.byType(SnackBar);
    expect(snackBar, findsOneWidget);
  }
}
