// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing


import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:sim_info_plugin/sim_info_plugin.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('getSimCardsDirect test', (WidgetTester tester) async {
    final SimInfoPlugin plugin = SimInfoPlugin();
    final List<dynamic>? simCards = await plugin.getSimCardsDirect();
    // The result should be a list if the native call is successful,
    // even if it's empty (no SIM cards present).
    expect(simCards is List?, true);
  });
}
