
import 'dart:async';

import 'sim_info_plugin_platform_interface.dart';

class SimInfoPlugin {
  Future<List<dynamic>?> getSimCardsDirect() {
    return SimInfoPluginPlatform.instance.getSimCardsDirect();
  }

  Stream<List<dynamic>> getSimCardsStream() {
    return SimInfoPluginPlatform.instance.getSimCardsStream();
  }
}
