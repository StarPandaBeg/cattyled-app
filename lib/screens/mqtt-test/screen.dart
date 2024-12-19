import 'package:cattyled_app/store/lamp/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScreenMqttTest extends StatelessWidget {
  const ScreenMqttTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          BlocBuilder<LampBloc, LampState>(
            builder: (context, state) =>
                Text(state.isConnected ? "Connected" : "Disconnected"),
          ),
          BlocBuilder<LampBloc, LampState>(
            builder: (context, state) =>
                Text(state.isEnabled ? "Enabled" : "Disabled"),
          ),
          BlocBuilder<LampBloc, LampState>(
            builder: (context, state) =>
                Text("Remote: ${state.isRemoteActive ? "Online" : "Offline"}"),
          ),
          BlocBuilder<LampBloc, LampState>(
            builder: (context, state) => Text(state.color.toString()),
          ),
          BlocBuilder<LampBloc, LampState>(
            builder: (context, state) => Text(state.mode.toString()),
          ),
          BlocBuilder<LampBloc, LampState>(
            builder: (context, state) =>
                Text("Brightness: ${state.brightness}"),
          ),
          ElevatedButton(
            onPressed: () {
              final store = context.read<LampBloc>();
              store.add(LampCommandEvent(CommandPower(state: true)));
            },
            child: const Text("Power ON"),
          ),
          ElevatedButton(
            onPressed: () {
              final store = context.read<LampBloc>();
              store.add(LampCommandEvent(CommandPower(state: false)));
            },
            child: const Text("Power OFF"),
          ),
          ElevatedButton(
            onPressed: () {
              final store = context.read<LampBloc>();
              store.add(
                LampCommandEvent(CommandColor(color: const Color(0xffff0000))),
              );
            },
            child: const Text("Set Color RED"),
          ),
          ElevatedButton(
            onPressed: () {
              final store = context.read<LampBloc>();
              store.add(
                LampCommandEvent(CommandColor(color: const Color(0xff0000FF))),
              );
            },
            child: const Text("Set Color BLUE"),
          ),
          ElevatedButton(
            onPressed: () {
              final store = context.read<LampBloc>();
              store.add(LampCommandEvent(CommandMode(mode: LampMode.classic)));
            },
            child: const Text("Set Mode Classic"),
          ),
          ElevatedButton(
            onPressed: () {
              final store = context.read<LampBloc>();
              store.add(LampCommandEvent(CommandMode(mode: LampMode.rainbow)));
            },
            child: const Text("Set Mode Rainbow"),
          ),
          ElevatedButton(
            onPressed: () {
              final store = context.read<LampBloc>();
              store.add(LampCommandEvent(CommandWink()));
            },
            child: const Text("Do Wink"),
          ),
          ElevatedButton(
            onPressed: () {
              final store = context.read<LampBloc>();
              store.add(LampCommandEvent(CommandBrightness(brightness: 255)));
            },
            child: const Text("Set Full Brightness"),
          ),
          ElevatedButton(
            onPressed: () {
              final store = context.read<LampBloc>();
              store.add(LampCommandEvent(CommandBrightness(brightness: 127)));
            },
            child: const Text("Set Half Brightness"),
          ),
          ElevatedButton(
            onPressed: () {
              final store = context.read<LampBloc>();
              store.add(LampCommandEvent(CommandSyncRequest()));
              store.add(LampCommandEvent(CommandStatusRequest()));
            },
            child: const Text("Sync"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, "/index");
            },
            child: const Text("Go to App"),
          ),
        ],
      ),
    );
  }
}
