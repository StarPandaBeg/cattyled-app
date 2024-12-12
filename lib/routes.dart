import 'package:cattyled_app/screens/main/screen.dart';
import 'package:flutter/widgets.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  "/index": (BuildContext context) => const ScreenMain(),
};
