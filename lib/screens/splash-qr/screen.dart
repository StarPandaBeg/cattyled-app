import 'dart:async';

import 'package:cattyled_app/util/qr_data.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';

class ScreenSplashQr extends StatefulWidget {
  const ScreenSplashQr({super.key});

  @override
  State<ScreenSplashQr> createState() => _ScreenSplashQrState();
}

class _ScreenSplashQrState extends State<ScreenSplashQr>
    with WidgetsBindingObserver {
  String _status = "";
  bool _hasVibration = false;
  bool _isProcessing = false;

  final MobileScannerController _controller = MobileScannerController(
    autoStart: true,
  );

  @override
  void initState() {
    super.initState();
    Vibration.hasVibrator().then(
      (value) {
        setState(() {
          _hasVibration = value!;
        });
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.hasCameraPermission) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        unawaited(_controller.start());
      case AppLifecycleState.inactive:
        unawaited(_controller.stop());
    }
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    if (!mounted) return;
    if (_isProcessing) return;

    _changeStatus("");

    final barcode = barcodes.barcodes[0];
    final value = barcode.rawValue;
    if (value == null) return;

    setState(() {
      _isProcessing = true;
    });

    final data = _doQrParse(value);
    if (data == null) {
      _changeStatus("Повторите попытку!");
      Timer(const Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() {
          _isProcessing = false;
        });
      });
      return;
    }
    Navigator.pop(context, data);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: _handleBarcode,
          errorBuilder: (context, exception, widget) => Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.warning,
                    size: 96,
                  ),
                  const SizedBox(height: 20),
                  const Text("При сканировании произошла ошибка"),
                  const Text("Ты разрешил приложению использовать камеру?"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Назад"),
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
                width: 256,
                height: 256,
              ),
              const SizedBox(height: 10),
              Text(_status),
            ],
          ),
        )
      ],
    );
  }

  void _changeStatus(String string) async {
    setState(() {
      _status = string;
    });

    if (_hasVibration) {
      Vibration.vibrate(duration: 50);
    }
  }

  QueryData? _doQrParse(String value) {
    try {
      return parseData(value);
    } catch (e) {
      return null;
    }
  }
}
