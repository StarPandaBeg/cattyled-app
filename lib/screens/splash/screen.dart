import 'package:cattyled_app/config/loader.dart';
import 'package:cattyled_app/providers/index.dart';
import 'package:cattyled_app/screens/splash/widgets/logo_animated.dart';
import 'package:flutter/material.dart';

class ScreenSplash extends StatelessWidget {
  const ScreenSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<bool>(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final route = snapshot.data! ? "/index" : "/splash/hello";
            Future.microtask(
              () => Navigator.pushReplacementNamed(context, route),
            );
          }
          return const LogoAnimated();
        },
        future: _loadConfig(),
      ),
    );
  }

  Future<bool> _loadConfig() async {
    final loader = ConfigLoader();
    final state = await loader.load();

    if (state == ConfigLoadingState.loaded) {
      final config = loader.config;
      await setup(config);
      return true;
    }
    return false;
  }
}
