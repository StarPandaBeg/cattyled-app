import 'package:cattyled_app/screens/settings/widgets/header.dart';
import 'package:cattyled_app/store/lamp_settings/store.dart';
import 'package:cattyled_app/util/qr_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ScreenSettingsCloud extends StatelessWidget {
  const ScreenSettingsCloud({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const PageHeader(header: "Синхронизация"),
          BlocProvider(
            create: (_) => LampSettingsBloc(),
            child: Expanded(
              child: Column(
                children: [
                  BlocBuilder<LampSettingsBloc, LampSettingsState>(
                    builder: (context, state) {
                      if (!state.isSynced ||
                          state.mqttHost.isEmpty ||
                          state.mqttLocalId.isEmpty) {
                        return const Card(
                          child: SizedBox(
                            width: 300,
                            height: 300,
                            child: Center(child: Text("Загрузка...")),
                          ),
                        );
                      }
                      return Column(
                        children: [
                          Card(
                            clipBehavior: Clip.hardEdge,
                            child: QrImageView(
                              data: stringifyData(state, invertIds: true),
                              size: 300,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Отсканируйте этот QR-код в другом приложении для подключения лампы-пары",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    },
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
