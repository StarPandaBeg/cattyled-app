import 'package:cattyled_app/providers/index.dart';
import 'package:cattyled_app/routes.dart';
import 'package:cattyled_app/theme/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

final appLogger = Logger("Application");

void setupLogging() {
  Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print(
      '[${record.level.name}] (${record.loggerName}) ${record.time}: ${record.message}',
    );
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLogging();
  await setup();

  appLogger.info("Setup complete. Running app");
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
