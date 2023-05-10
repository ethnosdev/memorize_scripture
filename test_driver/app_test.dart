import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

// flutter drive --target=test_driver/app.dart

void main() {
  group('My App', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver.close();
    });

    // Write your test cases here
    test('My test case', () async {
      // Your test code
    });
  });
}
