import 'package:cattyled_app/store/mqtt.dart';
import 'package:cattyled_app/widgets/status_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            BlocBuilder<MqttBloc, MqttState>(
              buildWhen: (previous, current) {
                if (previous.isConnected != current.isConnected) return true;
                if (previous.isRemoteActive != current.isRemoteActive) {
                  return true;
                }
                return false;
              },
              builder: (context, state) => Row(
                children: [
                  const StatusIcon(Icons.cloud_sync),
                  const SizedBox(width: 5),
                  StatusIcon(
                    Icons.cloud,
                    enabled: state.isConnected && state.isRemoteActive,
                  ),
                ],
              ),
            ),
            const SizedBox(),
          ],
        ),
      ),
    );
  }
}
