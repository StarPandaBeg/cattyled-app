import 'package:cattyled_app/api/commands.dart';
import 'package:cattyled_app/store/mqtt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScreenMqttTest extends StatelessWidget {
  const ScreenMqttTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          BlocBuilder<MqttBloc, MqttState>(
            builder: (context, state) =>
                Text(state.isConnected ? "Connected" : "Disconnected"),
          ),
          BlocBuilder<MqttBloc, MqttState>(
            builder: (context, state) =>
                Text(state.isEnabled ? "Enabled" : "Disabled"),
          ),
          BlocBuilder<MqttBloc, MqttState>(
            builder: (context, state) =>
                Text("Remote: ${state.isRemoteActive ? "Online" : "Offline"}"),
          ),
          BlocBuilder<MqttBloc, MqttState>(
            builder: (context, state) => Text(state.color.toString()),
          ),
          BlocBuilder<MqttBloc, MqttState>(
            builder: (context, state) => Text(state.mode.toString()),
          ),
          BlocBuilder<MqttBloc, MqttState>(
            builder: (context, state) =>
                Text("Brightness: ${state.brightness}"),
          ),
          ElevatedButton(
            onPressed: () {
              final store = context.read<MqttBloc>();
              store.add(MqttCommandEvent(CommandPower(state: true)));
            },
            child: const Text("Power ON"),
          ),
          ElevatedButton(
            onPressed: () {
              final store = context.read<MqttBloc>();
              store.add(MqttCommandEvent(CommandPower(state: false)));
            },
            child: const Text("Power OFF"),
          ),
          ElevatedButton(
            onPressed: () {
              final store = context.read<MqttBloc>();
              store.add(
                MqttCommandEvent(CommandColor(color: const Color(0xffff0000))),
              );
            },
            child: const Text("Set Color RED"),
          ),
          ElevatedButton(
            onPressed: () {
              final store = context.read<MqttBloc>();
              store.add(
                MqttCommandEvent(CommandColor(color: const Color(0xff0000FF))),
              );
            },
            child: const Text("Set Color BLUE"),
          ),
          ElevatedButton(
            onPressed: () {
              final store = context.read<MqttBloc>();
              store.add(MqttCommandEvent(CommandMode(mode: LampMode.classic)));
            },
            child: const Text("Set Mode Classic"),
          ),
          ElevatedButton(
            onPressed: () {
              final store = context.read<MqttBloc>();
              store.add(MqttCommandEvent(CommandMode(mode: LampMode.rainbow)));
            },
            child: const Text("Set Mode Rainbow"),
          ),
          ElevatedButton(
            onPressed: () {
              final store = context.read<MqttBloc>();
              store.add(MqttCommandEvent(CommandWink()));
            },
            child: const Text("Do Wink"),
          ),
          ElevatedButton(
            onPressed: () {
              final store = context.read<MqttBloc>();
              store.add(MqttCommandEvent(CommandBrightness(brightness: 255)));
            },
            child: const Text("Set Full Brightness"),
          ),
          ElevatedButton(
            onPressed: () {
              final store = context.read<MqttBloc>();
              store.add(MqttCommandEvent(CommandBrightness(brightness: 127)));
            },
            child: const Text("Set Half Brightness"),
          ),
          ElevatedButton(
            onPressed: () {
              final store = context.read<MqttBloc>();
              store.add(MqttCommandEvent(CommandSyncRequest()));
              store.add(MqttCommandEvent(CommandStatusRequest()));
            },
            child: const Text("Sync"),
          ),
        ],
      ),
    );
  }
}
