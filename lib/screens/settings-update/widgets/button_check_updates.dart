import 'package:cattyled_app/store/lamp_settings/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ButtonCheckUpdates extends StatefulWidget {
  const ButtonCheckUpdates({super.key});

  @override
  State<ButtonCheckUpdates> createState() => _ButtonCheckUpdatesState();
}

class _ButtonCheckUpdatesState extends State<ButtonCheckUpdates> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _onCheckUpdate(context),
        child: const Text("Проверить обновления"),
      ),
    );
  }

  void _onCheckUpdate(BuildContext context) {
    final store = context.read<LampSettingsBloc>();
    if (!store.state.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет соединения!')),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Проверка обновлений...')),
    );
  }
}
