import 'dart:async';

import 'package:cattyled_app/config/loader.dart';
import 'package:cattyled_app/screens/splash-check/check.dart';
import 'package:cattyled_app/screens/update/screen.dart';
import 'package:cattyled_app/util/qr_data.dart';
import 'package:cattyled_app/widgets/logo_animated.dart';
import 'package:flutter/material.dart';

class ScreenSplashCheck extends StatefulWidget {
  const ScreenSplashCheck({super.key});

  @override
  State<ScreenSplashCheck> createState() => _ScreenSplashCheckState();
}

class _ScreenSplashCheckState extends State<ScreenSplashCheck> {
  final checker = LampChecker();
  final ConfigLoader _loader = ConfigLoader();

  Config _config = Config.placeholder();

  @override
  void initState() {
    super.initState();

    cleanConfig();
    checker.addListener(_onCheckStatus);
    checker.run();
  }

  @override
  void dispose() {
    checker.removeListener(_onCheckStatus);
    checker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LogoAnimated(),
          Text("Сканируем WiFi..."),
          Text("Это займет несколько минут.")
        ],
      ),
    );
  }

  Future<void> _showError(String text) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ошибка'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(text),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                checker.run();
              },
              child: const Text('Повторить'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUpdateAlert(String ip) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Требуется обновление'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Приложение использует более новую версию прошивки'),
                SizedBox(height: 10),
                Text(
                  'Подключитесь к одной сети, что и лампа и выключите VPN.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => _doUpdate(ip),
              child: const Text('Продолжить'),
            ),
          ],
        );
      },
    );
  }

  void _doUpdate(String ip) {
    Navigator.popUntil(context, (_) => false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ScreenUpdate(address: ip),
            ),
          ),
        ),
      ),
    );
  }

  void _onCheckStatus() async {
    if (!checker.isOk) {
      _showError(checker.lastError);
      return;
    }

    await _loader.save(QueryData.fromConfig(_config));
    if (checker.needUpdate) {
      _showUpdateAlert(checker.foundIp);
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context, "/splash", (route) => false);
  }

  void cleanConfig() async {
    await _loader.load();
    _config = _loader.config;
    await _loader.clear();
  }
}
