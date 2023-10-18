import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:memorize_scripture/main.dart' as app;

import 'robots/home_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Test '+' button interaction", (WidgetTester tester) async {
    await app.main();
    await tester.pumpAndSettle();
    final homeRobot = HomeRobot(tester);

    await homeRobot.clickNewCollectionButton();
  });
}
