import 'dart:async';

import 'package:cattyled_app/api/client.dart';
import 'package:cattyled_app/config/config.dart';
import 'package:cattyled_app/providers/config.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:typed_data/typed_data.dart';

class MqttRepository {
  late final MqttClient _client;
  late Config _config;

  bool get isStatusConnected => _client.isStatusConnected;
  bool get isConnected => _client.isConnected.value;
  ValueListenable<bool> get isConnectedNotifier => _client.isConnected;

  MqttRepository() {
    _config = GetIt.instance<ConfigProvider>().config;
    _client = MqttClient(_config);
  }

  Future<void> dispose() async {
    if (isStatusConnected) await disconnect();
  }

  Future<void> connect() async {
    await _client.connect();
  }

  Future<void> disconnect() async {
    await _client.disconnect();
  }

  void send(Uint8Buffer message) {
    sendToLocal(message);
    sendToRemote(message);
  }

  void sendToLocal(Uint8Buffer message) {
    _client.send(_config.localTopic, message);
  }

  void sendToRemote(Uint8Buffer message) {
    _client.send(_config.remoteTopic, message);
  }

  // TODO: add ability to subscribe & listen messages
}
