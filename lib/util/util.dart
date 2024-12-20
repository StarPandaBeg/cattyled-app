import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:typed_data/typed_data.dart';

enum LampMode { classic, rainbow, glow, pulse, fire, lights }

final Map<LampMode, Map<String, dynamic>> lampModes = {
  LampMode.classic: {
    "name": "Классика",
    "icon": Icons.light,
  },
  LampMode.rainbow: {
    "name": "Радуга",
    "icon": Icons.looks,
  },
  LampMode.glow: {
    "name": "Сияние",
    "icon": Icons.auto_awesome,
  },
  LampMode.pulse: {
    "name": "Пульс",
    "icon": Icons.favorite,
  },
  LampMode.fire: {
    "name": "Пламя",
    "icon": Icons.local_fire_department,
  },
  LampMode.lights: {
    "name": "Праздник",
    "icon": Icons.celebration,
  },
};

Uint8Buffer buildCommand(List<dynamic> args) {
  final data = args.map((item) => item.toString()).join(",");
  final builder = MqttClientPayloadBuilder();

  builder.addString("CATLAPP:");
  builder.addString(data);
  return builder.payload!;
}

List<String> parseCommand(Uint8Buffer payload) {
  final command = String.fromCharCodes(payload);
  if (!command.startsWith("CATL:")) return [];
  return command.substring(5).split(",");
}
