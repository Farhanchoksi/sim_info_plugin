
import 'sim_info_plugin_platform_interface.dart';

class SimInfoPlugin {
  Future<List<dynamic>?> getSimCardsDirect() {
    return SimInfoPluginPlatform.instance.getSimCardsDirect();
  }
}
