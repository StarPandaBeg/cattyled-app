import 'package:cattyled_app/screens/settings-update/widgets/button_check_updates.dart';
import 'package:cattyled_app/screens/settings/widgets/header.dart';
import 'package:cattyled_app/store/lamp_settings/store.dart';
import 'package:cattyled_app/widgets/text_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ScreenSettingsUpdate extends StatelessWidget {
  const ScreenSettingsUpdate({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const PageHeader(header: "Обновление"),
          BlocProvider(
            create: (_) => LampSettingsBloc(),
            child: Expanded(
              child: BlocBuilder<LampSettingsBloc, LampSettingsState>(
                buildWhen: (previous, current) {
                  if (previous.isConnected != current.isConnected) return true;
                  if (previous.isSynced != current.isSynced) return true;
                  if (previous.firmwareVersion != current.firmwareVersion) {
                    return true;
                  }
                  if (previous.fsVersion != current.fsVersion) return true;
                  return false;
                },
                builder: (context, state) => Column(
                  children: [
                    _CardFirmware(
                      version: (state.isConnected && state.isSynced)
                          ? state.firmwareVersion
                          : "Загрузка...",
                      versionAnimationKey: state.isConnected && state.isSynced,
                    ),
                    _CardInfo(
                      fsVersion: (state.isConnected && state.isSynced)
                          ? state.fsVersion
                          : "Загрузка...",
                      fsVersionAnimationKey:
                          state.isConnected && state.isSynced,
                    ),
                    const ButtonCheckUpdates(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardFirmware extends StatelessWidget {
  final String version;
  final dynamic versionAnimationKey;

  const _CardFirmware({
    required this.version,
    required this.versionAnimationKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
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
              Text(
                "CattyLED",
                style: textTheme.headlineLarge,
              ),
              const SizedBox(height: 10),
              TextAnimated(version, versionAnimationKey)
            ],
          ),
        ),
      ),
    );
  }
}

class _CardInfo extends StatelessWidget {
  final String fsVersion;
  final dynamic fsVersionAnimationKey;

  const _CardInfo({
    required this.fsVersion,
    required this.fsVersionAnimationKey,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Версия файловой системы:"),
                  TextAnimated(fsVersion, fsVersionAnimationKey),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Версия приложения:"),
                  FutureBuilder<String>(
                    future: _getAppVersion(),
                    builder: (context, snapshot) {
                      String text = snapshot.data ?? "Загрузка...";
                      return TextAnimated(text, text);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}
