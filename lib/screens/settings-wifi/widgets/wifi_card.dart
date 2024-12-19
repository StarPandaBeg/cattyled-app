import 'package:cattyled_app/store/lamp_settings/store.dart';
import 'package:cattyled_app/util/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CardWifiForm extends StatefulWidget {
  final String ssid;
  final String password;

  const CardWifiForm({
    super.key,
    this.ssid = "",
    this.password = "",
  });

  @override
  State<CardWifiForm> createState() => _CardWifiFormState();
}

class _CardWifiFormState extends State<CardWifiForm> {
  final _formKey = GlobalKey<FormState>();

  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ssidController.text = widget.ssid;
    _passwordController.text = widget.password;
  }

  @override
  void didUpdateWidget(covariant CardWifiForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _ssidController.text = widget.ssid;
      _passwordController.text = widget.password;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text("Настройка роутера"),
              const SizedBox(height: 10),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(hintText: "SSID"),
                      validator: notEmpty,
                      controller: _ssidController,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: const InputDecoration(hintText: "Пароль"),
                      validator: notEmpty,
                      controller: _passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _onFormSubmit(context),
                        style: ButtonStyle(
                          alignment: Alignment.center,
                          backgroundColor:
                              WidgetStatePropertyAll(colorScheme.primary),
                          foregroundColor:
                              WidgetStatePropertyAll(colorScheme.secondary),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide.none,
                            ),
                          ),
                        ),
                        child: const SizedBox(
                          child: Text("Изменить"),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onFormSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final ssid = _ssidController.text;
    final password = _passwordController.text;
    final store = context.read<LampSettingsBloc>();

    if (!store.state.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет соединения!')),
      );
      return;
    }

    store.add(
        LampSettingsCommandEvent(CommandWifi(ssid: ssid, password: password)));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Данные обновлены!')),
    );
  }
}
