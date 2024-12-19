import 'package:cattyled_app/screens/settings-wifi/widgets/wifi_card.dart';
import 'package:cattyled_app/screens/settings/widgets/header.dart';
import 'package:cattyled_app/store/lamp_settings/store.dart';
import 'package:cattyled_app/widgets/text_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScreenSettingsWifi extends StatelessWidget {
  const ScreenSettingsWifi({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const PageHeader(header: "Настройки WiFi"),
          BlocProvider(
            create: (_) => LampSettingsBloc(),
            child: Expanded(
              child: Column(
                children: [
                  const _CardInfo(),
                  BlocBuilder<LampSettingsBloc, LampSettingsState>(
                    buildWhen: (previous, current) {
                      if (previous.wifiSSID != current.wifiSSID) return true;
                      if (previous.wifiPassword != current.wifiPassword) {
                        return true;
                      }
                      return false;
                    },
                    builder: (context, state) => CardWifiForm(
                      ssid: state.wifiSSID,
                      password: state.wifiPassword,
                    ),
                  )
                ],
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
              if (previous.wifiIp != current.wifiIp) return true;
              if (previous.wifiSSID != current.wifiSSID) return true;
              return false;
            },
            builder: (context, state) => Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Адрес в сети:"),
                    TextAnimated(
                      (state.isConnected && state.isSynced)
                          ? state.wifiIp
                          : "Обновление...",
                      state.isConnected && state.isSynced,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Текущая сеть:"),
                    TextAnimated(
                      (state.isConnected && state.isSynced)
                          ? state.wifiSSID
                          : "Обновление...",
                      state.isConnected && state.isSynced,
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
}
