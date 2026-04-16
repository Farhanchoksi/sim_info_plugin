import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'sim_info_plugin_platform_interface.dart';

/// An implementation of [SimInfoPluginPlatform] that uses method channels.
class MethodChannelSimInfoPlugin extends SimInfoPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('sim_info_plugin');

  @visibleForTesting
  final eventChannel = const EventChannel('sim_info_plugin_events');

  @override
  Future<List<dynamic>?> getSimCardsDirect() async {
    final simList = await methodChannel.invokeMethod<List<dynamic>>('getSimCardsDirect');
    return simList;
  }

  @override
  Stream<List<dynamic>> getSimCardsStream() {
    return eventChannel.receiveBroadcastStream().map((dynamic event) {
      if (event is List) {
        return List<dynamic>.from(event);
      }
      return <dynamic>[];
    });
  }
}
