import 'package:cattyled_app/screens/update/screen.dart';
import 'package:cattyled_app/store/lamp_settings/store.dart';
import 'package:cattyled_app/util/updates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:pub_semver/pub_semver.dart';

class ButtonCheckUpdates extends StatefulWidget {
  const ButtonCheckUpdates({super.key});

  @override
  State<ButtonCheckUpdates> createState() => _ButtonCheckUpdatesState();
}

class _ButtonCheckUpdatesState extends State<ButtonCheckUpdates> {
  static final _logger = Logger("_ButtonCheckUpdatesState");

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _onCheckUpdate(context),
        child: Text(_isLoading ? "Загрузка..." : "Проверить обновления"),
      ),
    );
  }

  void _onCheckUpdate(BuildContext context) async {
    final store = context.read<LampSettingsBloc>();
    final messenger = ScaffoldMessenger.of(context);

    if (!store.state.isConnected) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Нет соединения!')),
      );
    }

    try {
      messenger.showSnackBar(
        const SnackBar(content: Text('Проверка обновлений...')),
      );
      setState(() {
        _isLoading = true;
      });
      final state = await _checkUpdates(store.state);
      if (!state) {
        messenger.clearSnackBars();
        messenger.showSnackBar(
          const SnackBar(content: Text('Обновления не найдены!')),
        );
        return;
      }

      if (!mounted) return;
      _showUpdateAlert(store.state);
    } catch (e) {
      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(content: Text('При проверке произошла ошибка')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _checkUpdates(LampSettingsState state) async {
    final remoteFirmwareVersion =
        await fetchVersion(state.remoteFirmwareVersionUrl);
    final remoteFsVersion = await fetchVersion(state.remoteFirmwareVersionUrl);

    final localFirmwareVersion = Version.parse(state.firmwareVersion);
    final localFsVersion = Version.parse(state.fsVersion);

    if (localFsVersion < remoteFsVersion ||
        localFirmwareVersion < remoteFirmwareVersion) {
      _logger.info("Updates found");
      _logger.info("Firmware: $localFirmwareVersion -> $remoteFirmwareVersion");
      _logger.info("FS: $localFsVersion -> $remoteFsVersion");
      return true;
    }
    _logger.info("Updates not found");
    return false;
  }

  Future<void> _showUpdateAlert(LampSettingsState state) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Новая версия'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Найдена новая версия'),
                SizedBox(height: 10),
                Text('Рекомендуем обновить прошивку!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Обновить'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.popUntil(context, (_) => false);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      body: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: ScreenUpdate(address: state.wifiIp),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
