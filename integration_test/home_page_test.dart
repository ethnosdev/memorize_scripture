import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:memorize_scripture/main.dart' as app;

import 'robots/app_robot.dart';
import 'robots/home_robot.dart';
import 'robots/verse_browser_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Test home page UI", (WidgetTester tester) async {
    await app.main();

    final homeRobot = HomeRobot(tester);
    final verseBrowserRobot = VerseBrowserRobot(tester);
    final appRobot = AppRobot(tester);

    await homeRobot.tapNewCollectionButton();
    await homeRobot.enterCollectionName('John 3');
    await homeRobot.tapOk();
    await homeRobot.longPressCollection('John 3');
    await homeRobot.tapMenuItem('Browse verses');
    await verseBrowserRobot.verifyEmpty();
    await appRobot.navigateBack();
    await homeRobot.longPressCollection('John 3');
    await homeRobot.tapMenuItem('Browse verses');
    // await homeRobot.tapMenuItem('Reset due dates');
    // await homeRobot.verifySnackbarShows();
    // await homeRobot.longPressCollection('John 3');
    // await homeRobot.verifyMenuItemExists('Share');
    // await homeRobot.tapMenuItem('Rename');
    // await homeRobot.enterCollectionName('Matthew 28');
    // await homeRobot.tapOk();
    // await homeRobot.longPressCollection('Matthew 28');
    // await homeRobot.tapMenuItem('Delete');
    // await homeRobot.tapCancel();
    // await homeRobot.longPressCollection('Matthew 28');
    // await homeRobot.tapMenuItem('Delete');
    // await homeRobot.tapDelete();
    // await homeRobot.verifyNoCollections();
  });
}
