import 'package:flutter_test/flutter_test.dart';
import 'package:sim_info_plugin/sim_info_plugin.dart';
import 'package:sim_info_plugin/sim_info_plugin_platform_interface.dart';
import 'package:sim_info_plugin/sim_info_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSimInfoPluginPlatform
    with MockPlatformInterfaceMixin
    implements SimInfoPluginPlatform {

  @override
  Future<List<dynamic>?> getSimCardsDirect() => Future.value([{'number': '123'}]);
}

void main() {
  final SimInfoPluginPlatform initialPlatform = SimInfoPluginPlatform.instance;

  test('$MethodChannelSimInfoPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSimInfoPlugin>());
  });

  test('getSimCardsDirect', () async {
    SimInfoPlugin simInfoPlugin = SimInfoPlugin();
    MockSimInfoPluginPlatform fakePlatform = MockSimInfoPluginPlatform();
    SimInfoPluginPlatform.instance = fakePlatform;

    expect(await simInfoPlugin.getSimCardsDirect(), [{'number': '123'}]);
  });
}
