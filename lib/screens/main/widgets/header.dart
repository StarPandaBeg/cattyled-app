import 'package:cattyled_app/api/commands.dart';
import 'package:cattyled_app/screens/main/widgets/greeting.dart';
import 'package:cattyled_app/store/lamp.dart';
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
            onPressed: () {
              Navigator.pushNamed(context, "/settings");
            },
            icon: Icon(
              Icons.settings,
              color: colorScheme.secondary,
            ),
          ),
          Column(
            children: [
              const TextGreeting(),
              BlocBuilder<LampBloc, LampState>(
                buildWhen: (previous, current) {
                  if (previous.isConnected != current.isConnected) {
                    return true;
                  }
                  if (previous.isSynced != current.isSynced) {
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
          BlocBuilder<LampBloc, LampState>(
            buildWhen: (previous, current) {
              if (previous.isSynced != current.isSynced) return true;
              if (previous.isEnabled != current.isEnabled) return true;
              return false;
            },
            builder: (context, state) => IconButton(
              onPressed: state.isSynced ? () => _onPowerPressed(context) : null,
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

  String _stateToSubtitle(LampState state) {
    if (!state.isConnected) return "Соединение...";
    if (!state.isSynced) return "Синхронизация...";
    if (state.isRemoteActive) return "Ощущаю чьё-то присутствие!";
    return "Кот на месте. Мурр!";
  }

  void _onPowerPressed(BuildContext context) {
    final store = context.read<LampBloc>();
    store.add(
      LampCommandEvent(CommandPower(state: !store.state.isEnabled)),
    );
  }
}
