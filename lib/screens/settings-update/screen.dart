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
            child: const Expanded(
              child: Column(
                children: [_CardInfo()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardInfo extends StatelessWidget {
  const _CardInfo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Версия прошивки:"),
                    TextAnimated(
                      (state.isConnected && state.isSynced)
                          ? state.firmwareVersion
                          : "Обновление...",
                      state.isConnected && state.isSynced,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Версия файловой системы:"),
                    TextAnimated(
                      (state.isConnected && state.isSynced)
                          ? state.fsVersion
                          : "Обновление...",
                      state.isConnected && state.isSynced,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Версия приложения:"),
                    FutureBuilder<String>(
                      future: _getAppVersion(),
                      builder: (context, snapshot) {
                        String text = snapshot.data ?? "Обновление...";
                        return TextAnimated(
                          text,
                          text,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
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
