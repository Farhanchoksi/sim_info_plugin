# sim_info_plugin

A Flutter plugin to retrieve SIM card information, such as phone number, carrier name, and slot index, primarily for Android.

## The Problem It Solves

Many existing SIM information plugins have a common issue: **they only detect one SIM card on dual-SIM devices**. 

This plugin provides the solution by correctly detecting and fetching information for **both SIM cards** on dual-SIM mobile phones.

## Features

- Get active SIM cards on the device.
- Retrieve phone number, carrier name, slot index, and subscription ID.
- Handle Android 13+ (API 33+) phone number retrieval restrictions.

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  sim_info_plugin: ^1.0.0
```

## Permissions (Android)

Add the following permissions to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.READ_PHONE_NUMBERS" />
```

## Usage

```dart
import 'package:sim_info_plugin/sim_info_plugin.dart';

final _simInfoPlugin = SimInfoPlugin();

Future<void> getSimCards() async {
  final List<dynamic>? simCards = await _simInfoPlugin.getSimCardsDirect();
  if (simCards != null) {
    for (var sim in simCards) {
      print('Number: ${sim['number']}');
      print('Carrier: ${sim['carrierName']}');
    }
  }
}
```
## Maintainer

Maintained by **Farhan Choksi**.
