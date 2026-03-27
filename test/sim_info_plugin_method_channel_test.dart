import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sim_info_plugin/sim_info_plugin_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelSimInfoPlugin platform = MethodChannelSimInfoPlugin();
  const MethodChannel channel = MethodChannel('sim_info_plugin');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'getSimCardsDirect') {
          return [{'number': '42'}];
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getSimCardsDirect', () async {
    expect(await platform.getSimCardsDirect(), [{'number': '42'}]);
  });
}
