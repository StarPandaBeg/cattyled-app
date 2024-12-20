import 'dart:io';

import 'package:cattyled_app/screens/settings/widgets/header.dart';
import 'package:cattyled_app/store/lamp/store.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ScreenUpdate extends StatefulWidget {
  final String address;

  const ScreenUpdate({super.key, required this.address});

  @override
  State<ScreenUpdate> createState() => _ScreenUpdateState();
}

class _ScreenUpdateState extends State<ScreenUpdate> {
  WebSocketChannel? _channel;

  double _firmwareValue = 0;
  double _fsValue = 0;
  bool _closeNormal = false;

  @override
  void initState() {
    super.initState();
    _setupChannel();
  }

  @override
  void dispose() {
    _closeNormal = true;
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const PageHeader(
            header: "Обновление",
            enableBack: false,
          ),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                child: Column(
                  children: [
                    SizedBox(
                      width: 256,
                      height: 192,
                      child: Image.asset("assets/images/logo.png"),
                    ),
                    const Text("Пожалуйста, подождите..."),
                  ],
                ),
              ),
            ),
          ),
          Card(
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _ProgressBar(
                      label: "Обновление прошивки",
                      value: _firmwareValue,
                    ),
                    const SizedBox(height: 20),
                    _ProgressBar(label: "Обновление файлов", value: _fsValue)
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _setupChannel() async {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://${widget.address}/ws'),
    );

    try {
      await _channel?.ready;
    } catch (e) {
      _showError();
      return;
    }
    _channel?.sink.done.then((_) {
      if (_closeNormal) return;
      _showErrorConnection();
    });
    _channel?.stream.listen((e) => _parseEvent(e as String));
    _channel?.sink.add("CATL:-11");
  }

  Future<void> _showError() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ошибка'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('При подключении к лампе произошла ошибка'),
                SizedBox(height: 10),
                Text('- Ты подключен к той же сети, что и твоя лампа?'),
                Text('- У тебя выключен VPN?'),
                SizedBox(height: 10),
                Text('Попробуй выключить лампу и снова её включить.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Выход'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Повторить'),
              onPressed: () {
                Navigator.of(context).pop();
                _setupChannel();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorConnection() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ошибка'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Соединение прервано'),
                SizedBox(height: 10),
                Text(
                  'Процесс обновления продолжится, он не зависит от приложения!',
                ),
                SizedBox(height: 10),
                Text(
                  'Если лампа продолжит гореть красным в течение 5-7 минут - смело выключай ее!',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Выход'),
              onPressed: () {
                exit(0);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorUpdate(int errorCode) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ошибка'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('При обновлении произошла ошибка'),
                const SizedBox(height: 10),
                Text('Код ошибки: $errorCode'),
                const SizedBox(height: 10),
                const Text('Попробуй выключить лампу и снова её включить.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Выход'),
              onPressed: () {
                exit(0);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSuccess() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Обновление завершено!'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Бегом проверять новую версию!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Вперёд'),
              onPressed: () {
                Navigator.popUntil(context, (_) => true);
                Navigator.pushReplacementNamed(context, "/splash");
              },
            ),
          ],
        );
      },
    );
  }

  void _parseEvent(String data) {
    final parts = parseCommandFromString(data);
    final type = int.parse(parts[0]);
    final args = parts.sublist(1);

    switch (type) {
      case -12:
        final updateType = int.parse(args[0]);
        final percentage = double.parse(args[1]) / 100;

        setState(() {
          if (updateType == 0) {
            _firmwareValue = percentage;
          } else {
            _fsValue = percentage;
          }
        });
        break;
      case -14:
        _closeNormal = true;
        _channel?.sink.close();
        _showSuccess();
        break;
      case -16:
        int code = int.parse(args[0]);
        _showErrorUpdate(code);
        break;
    }
  }
}

class _ProgressBar extends StatelessWidget {
  final String label;
  final double value;

  const _ProgressBar({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final percentage = "${(value * 100).toStringAsFixed(0)}%";
    final percentageLabel = switch (value) {
      0 => "не начато",
      1 => "завершено",
      _ => percentage,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(percentageLabel),
          ],
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: value,
          minHeight: 32,
          backgroundColor: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        )
      ],
    );
  }
}
