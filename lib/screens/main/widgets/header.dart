import 'package:cattyled_app/api/commands.dart';
import 'package:cattyled_app/screens/main/widgets/greeting.dart';
import 'package:cattyled_app/store/mqtt.dart';
import 'package:cattyled_app/widgets/text_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.settings,
              color: colorScheme.secondary,
            ),
          ),
          Column(
            children: [
              const TextGreeting(),
              BlocBuilder<MqttBloc, MqttState>(
                buildWhen: (previous, current) {
                  if (previous.isConnected != current.isConnected) {
                    return true;
                  }
                  if (previous.isRemoteActive != current.isRemoteActive) {
                    return true;
                  }
                  return false;
                },
                builder: (context, state) => TextAnimated(
                  _stateToSubtitle(state),
                  _stateToSubtitle(state),
                ),
              ),
            ],
          ),
          BlocBuilder<MqttBloc, MqttState>(
            buildWhen: (previous, current) {
              if (previous.isConnected != current.isConnected) return true;
              if (previous.isEnabled != current.isEnabled) return true;
              return false;
            },
            builder: (context, state) => IconButton(
              onPressed:
                  state.isConnected ? () => _onPowerPressed(context) : null,
              icon: const Icon(Icons.power_settings_new),
              color:
                  state.isEnabled ? colorScheme.primary : colorScheme.secondary,
              disabledColor: colorScheme.secondary.withAlpha(50),
            ),
          ),
        ],
      ),
    );
  }

  String _stateToSubtitle(MqttState state) {
    if (!state.isConnected) return "Соединение...";
    if (state.isRemoteActive) return "Ощущаю чьё-то присутствие!";
    return "Кот на месте. Мурр!";
  }

  void _onPowerPressed(BuildContext context) {
    final store = context.read<MqttBloc>();
    store.add(
      MqttCommandEvent(CommandPower(state: !store.state.isEnabled)),
    );
  }
}
