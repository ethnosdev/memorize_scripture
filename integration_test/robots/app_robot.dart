import 'package:flutter_test/flutter_test.dart';

class AppRobot {
  AppRobot(this.tester);
  final WidgetTester tester;

  Future<void> navigateBack() async {
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
  }
}
