import 'dart:async';
import 'dart:math';

import 'package:cattyled_app/config/loader.dart';
import 'package:cattyled_app/util/qr_data.dart';
import 'package:flutter/material.dart';

class ScreenSplashHello extends StatefulWidget {
  const ScreenSplashHello({super.key});

  @override
  State<ScreenSplashHello> createState() => _ScreenSplashHelloState();
}

class _ScreenSplashHelloState extends State<ScreenSplashHello> {
  bool _catAnimationStarted = false;
  bool _actionStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _catAnimationStarted = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: _catAnimationStarted ? 1 : 0,
                duration: Durations.long2,
                child: Text(
                  "Привет!",
                  style: textTheme.headlineLarge!.merge(
                    const TextStyle(fontSize: 36),
                  ),
                ),
                onEnd: () {
                  Timer(const Duration(seconds: 4), () {
                    setState(() {
                      _actionStarted = _catAnimationStarted;
                    });
                  });
                },
              ),
              const SizedBox(height: 20),
              AnimatedOpacity(
                opacity: _actionStarted ? 1 : 0,
                duration: Durations.medium2,
                child: Column(
                  children: [
                    Text(
                      "Отсканируй код для подключения к твоему коту\nЯ жду!",
                      style: textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _doQrScan(context),
                      child: const Text("Отсканировать"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        AnimatedPositioned(
          left: _catAnimationStarted ? -108 : -300,
          bottom: _catAnimationStarted ? -123 : -250,
          duration: const Duration(milliseconds: 2500),
          curve: Curves.fastEaseInToSlowEaseOut,
          child: Transform.rotate(
            angle: pi / 180 * 25,
            child: SizedBox(
              width: 300,
              height: 306,
              child: Image.asset("assets/images/cat_splash.png"),
            ),
          ),
        ),
      ],
    );
  }

  void _doQrScan(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context,
      "/splash/qr",
    );
    if (result == null) return;

    final loader = ConfigLoader();
    final data = result as QueryData;
    loader.save(data);

    if (!mounted) return;
    Navigator.popAndPushNamed(context, "/splash/check");
  }
}
