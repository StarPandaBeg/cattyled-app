import 'package:cattyled_app/screens/main/screen.dart';
import 'package:cattyled_app/screens/mqtt-test/screen.dart';
import 'package:cattyled_app/screens/settings-cloud/screen.dart';
import 'package:cattyled_app/screens/settings-wifi/screen.dart';
import 'package:cattyled_app/screens/settings/screen.dart';
import 'package:flutter/widgets.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  "/index": (BuildContext context) => const ScreenMain(),
  "/settings": (BuildContext context) => const ScreenSettings(),
  "/settings/wifi": (BuildContext context) => const ScreenSettingsWifi(),
  "/settings/sync": (BuildContext context) => const ScreenSettingsCloud(),
  "/mqtt-test": (BuildContext context) => const ScreenMqttTest(),
};
