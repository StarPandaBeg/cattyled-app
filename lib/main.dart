import 'package:cattyled_app/providers/index.dart';
import 'package:cattyled_app/routes.dart';
import 'package:cattyled_app/theme/app.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setup();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Твой кот',
      theme: appTheme(),
      initialRoute: "/mqtt-test",
      onGenerateRoute: (settings) {
        final builder = routes[settings.name];
        if (builder == null) return null;
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: builder(context),
              ),
            ),
          ),
        );
      },
    );
  }
}
