import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'sim_info_plugin_method_channel.dart';

abstract class SimInfoPluginPlatform extends PlatformInterface {
  /// Constructs a SimInfoPluginPlatform.
  SimInfoPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static SimInfoPluginPlatform _instance = MethodChannelSimInfoPlugin();

  /// The default instance of [SimInfoPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelSimInfoPlugin].
  static SimInfoPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SimInfoPluginPlatform] when
  /// they register themselves.
  static set instance(SimInfoPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<List<dynamic>?> getSimCardsDirect() {
    throw UnimplementedError('getSimCardsDirect() has not been implemented.');
  }
}
