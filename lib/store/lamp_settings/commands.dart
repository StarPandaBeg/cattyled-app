import 'package:cattyled_app/repository/mqtt.dart';
import 'package:cattyled_app/store/lamp_settings/store.dart';
import 'package:cattyled_app/util/util.dart';

abstract class Command {
  void execute(
    MqttRepository repository,
    void Function(LampSettingsEvent) addEvent,
  );
}

class CommandWifiRequest extends Command {
  @override
  void execute(
    MqttRepository repository,
    void Function(LampSettingsEvent) addEvent,
  ) {
    final command = buildCommand([-1]);
    repository.sendToLocal(command);
  }
}

class CommandMqttRequest extends Command {
  @override
  void execute(
    MqttRepository repository,
    void Function(LampSettingsEvent) addEvent,
  ) {
    final command = buildCommand([-5]);
    repository.sendToLocal(command);
  }
}

class CommandIpRequest extends Command {
  @override
  void execute(
    MqttRepository repository,
    void Function(LampSettingsEvent) addEvent,
  ) {
    final command = buildCommand([-17]);
    repository.sendToLocal(command);
  }
}

class CommandIdRequest extends Command {
  @override
  void execute(
    MqttRepository repository,
    void Function(LampSettingsEvent) addEvent,
  ) {
    final command = buildCommand([-21]);
    repository.sendToLocal(command);
  }
}

class CommandVersionRequest extends Command {
  @override
  void execute(
    MqttRepository repository,
    void Function(LampSettingsEvent) addEvent,
  ) {
    final command = buildCommand([-7]);
    repository.sendToLocal(command);
  }
}

class CommandWifi extends Command {
  final String ssid;
  final String password;

  CommandWifi({required this.ssid, required this.password});

  @override
  void execute(
    MqttRepository repository,
    void Function(LampSettingsEvent) addEvent,
  ) {
    final command = buildCommand([-3, ssid, password]);
    repository.sendToLocal(command);
    addEvent(LampSettingsWifiEvent(ssid: ssid, password: password));
  }
}
