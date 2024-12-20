import 'package:cattyled_app/screens/main/screen.dart';
import 'package:cattyled_app/screens/mqtt-test/screen.dart';
import 'package:cattyled_app/screens/settings-cloud/screen.dart';
import 'package:cattyled_app/screens/settings-update/screen.dart';
import 'package:cattyled_app/screens/settings-wifi/screen.dart';
import 'package:cattyled_app/screens/settings/screen.dart';
import 'package:cattyled_app/screens/splash-hello/screen.dart';
import 'package:cattyled_app/screens/splash-qr/screen.dart';
import 'package:cattyled_app/screens/splash/screen.dart';
import 'package:flutter/widgets.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  "/splash": (BuildContext context) => const ScreenSplash(),
  "/splash/hello": (BuildContext context) => const ScreenSplashHello(),
  "/splash/qr": (BuildContext context) => const ScreenSplashQr(),
  "/index": (BuildContext context) => const ScreenMain(),
  "/settings": (BuildContext context) => const ScreenSettings(),
  "/settings/wifi": (BuildContext context) => const ScreenSettingsWifi(),
  "/settings/sync": (BuildContext context) => const ScreenSettingsCloud(),
  "/settings/updates": (BuildContext context) => const ScreenSettingsUpdate(),
  "/mqtt-test": (BuildContext context) => const ScreenMqttTest(),
};
