import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sim_info_plugin/sim_info_plugin_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelSimInfoPlugin platform = MethodChannelSimInfoPlugin();
  const MethodChannel channel = MethodChannel('sim_info_plugin');
  const StandardMethodCodec codec = StandardMethodCodec();

  bool streamListenCalled = false;

  setUp(() {
    streamListenCalled = false;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'getSimCardsDirect') {
          return [{'number': '42'}];
        }
        return null;
      },
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'sim_info_plugin_events',
      (ByteData? message) async {
        if (message == null) {
          return codec.encodeSuccessEnvelope(null);
        }

        final MethodCall call = codec.decodeMethodCall(message);
        if (call.method == 'listen') {
          streamListenCalled = true;
        }
        return codec.encodeSuccessEnvelope(null);
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('sim_info_plugin_events', null);
  });

  test('getSimCardsDirect', () async {
    expect(await platform.getSimCardsDirect(), [{'number': '42'}]);
  });

  test('getSimCardsStream wires EventChannel listen', () async {
    final StreamSubscription<List<dynamic>> subscription = platform.getSimCardsStream().listen((_) {});
    await Future<void>.delayed(Duration.zero);

    expect(streamListenCalled, isTrue);

    await subscription.cancel();
  });
}
