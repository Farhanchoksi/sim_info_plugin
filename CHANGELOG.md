## 1.1.0

* Added Android live SIM change listener support via stream events.
* Exposed `getSimCardsStream()` in the plugin API for real-time SIM updates.
* Updated the example app to listen to SIM changes and log SIM insertion/withdrawal tracking.

## 1.0.2

* Updated README.md to highlight the primary use case and solution for dual-SIM devices.

## 1.0.1

* Removed iOS support to focus solely on Android implementation.

## 1.0.0

* Initial release.
* Support for Android `SubscriptionManager` to retrieve SIM card details.
* Automated phone number detection (including Android 13+).
