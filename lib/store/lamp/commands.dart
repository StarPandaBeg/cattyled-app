import 'package:cattyled_app/repository/mqtt.dart';
import 'package:cattyled_app/store/lamp/store.dart';
import 'package:flutter/material.dart';

abstract class Command {
  void execute(MqttRepository repository, void Function(LampEvent) addEvent);
}

class CommandPower extends Command {
  final bool state;

  CommandPower({required this.state});

  @override
  void execute(MqttRepository repository, void Function(LampEvent) addEvent) {
    final command = buildCommand([3, state ? 1 : 0]);
    repository.send(command);
    addEvent(LampPowerEvent(value: state));
  }
}

class CommandColor extends Command {
  final Color color;

  CommandColor({required this.color});

  @override
  void execute(MqttRepository repository, void Function(LampEvent) addEvent) {
    final hsvColor = HSVColor.fromColor(color);
    final hue = (hsvColor.hue / (360 / 255)).toInt();
    final saturation = (hsvColor.saturation * 255).toInt();
    final value = (hsvColor.value * 255).toInt();

    final command = buildCommand([4, hue, saturation, value]);
    repository.send(command);
    addEvent(LampColorEvent(value: color));
  }
}

class CommandMode extends Command {
  final LampMode mode;

  CommandMode({required this.mode});

  @override
  void execute(MqttRepository repository, void Function(LampEvent) addEvent) {
    final command = buildCommand([5, mode.index]);
    repository.send(command);
    addEvent(LampModeEvent(value: mode));
  }
}

class CommandWink extends Command {
  @override
  void execute(MqttRepository repository, void Function(LampEvent) addEvent) {
    final command = buildCommand([6]);
    repository.send(command);
  }
}

class CommandBrightness extends Command {
  final int brightness;

  CommandBrightness({required this.brightness});

  @override
  void execute(MqttRepository repository, void Function(LampEvent) addEvent) {
    final command = buildCommand([7, brightness]);
    repository.send(command);
    addEvent(LampBrightnessEvent(value: brightness));
  }
}

class CommandPing extends Command {
  @override
  void execute(MqttRepository repository, void Function(LampEvent) addEvent) {
    final command = buildCommand([0]);
    repository.send(command);
  }
}

class CommandSyncRequest extends Command {
  @override
  void execute(MqttRepository repository, void Function(LampEvent) addEvent) {
    final command = buildCommand([2]);
    repository.sendToLocal(command);
  }
}

class CommandStatusRequest extends Command {
  @override
  void execute(MqttRepository repository, void Function(LampEvent) addEvent) {
    final command = buildCommand([8]);
    repository.sendToLocal(command);
  }
}
