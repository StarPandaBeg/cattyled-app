import 'package:cattyled_app/repository/mqtt.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:typed_data/typed_data.dart';

enum LampMode { classic, rainbow, glow, pulse, fire, lights }

abstract class Command {
  void execute(MqttRepository repository);

  Uint8Buffer _buildCommand(List<dynamic> args) {
    final data = args.map((item) => item.toString()).join(",");
    final builder = MqttClientPayloadBuilder();

    builder.addString("CATLAPP:");
    builder.addString(data);
    return builder.payload!;
  }
}

class CommandPower extends Command {
  final bool state;

  CommandPower({required this.state});

  @override
  void execute(MqttRepository repository) {
    final command = _buildCommand([3, state ? 1 : 0]);
    repository.send(command);
  }
}

class CommandColor extends Command {
  final Color color;

  CommandColor({required this.color});

  @override
  void execute(MqttRepository repository) {
    final hsvColor = HSVColor.fromColor(color);
    final hue = (hsvColor.hue / (360 / 255)).toInt();
    final saturation = (hsvColor.saturation * 255).toInt();
    final value = (hsvColor.value * 255).toInt();

    final command = _buildCommand([4, hue, saturation, value]);
    repository.send(command);
  }
}

class CommandMode extends Command {
  final LampMode mode;

  CommandMode({required this.mode});

  @override
  void execute(MqttRepository repository) {
    final command = _buildCommand([5, mode.index]);
    repository.send(command);
  }
}

class CommandWink extends Command {
  @override
  void execute(MqttRepository repository) {
    final command = _buildCommand([6]);
    repository.send(command);
  }
}
