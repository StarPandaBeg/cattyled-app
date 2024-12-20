import 'dart:async';

import 'package:async/async.dart';
import 'package:cattyled_app/api/client.dart';
import 'package:cattyled_app/config/config.dart';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart' show MqttPublishMessage;
import 'package:typed_data/typed_data.dart';

class MqttRepository {
  late final MqttClient _client;
  late Config _config;

  final StreamController<Uint8Buffer> _localMessageController =
      StreamController<Uint8Buffer>.broadcast();
  final StreamController<Uint8Buffer> _remoteMessageController =
      StreamController<Uint8Buffer>.broadcast();

  bool get isStatusConnected => _client.isStatusConnected;
  bool get isConnected => _client.isConnected.value;
  ValueListenable<bool> get isConnectedNotifier => _client.isConnected;

  Stream<Uint8Buffer> get localMessages => _localMessageController.stream;
  Stream<Uint8Buffer> get remoteMessages => _remoteMessageController.stream;
  Stream<Uint8Buffer> get messages =>
      StreamGroup.mergeBroadcast([localMessages, remoteMessages]);

  MqttRepository(Config config) {
    _config = config;
    _client = MqttClient(_config);
  }

  Future<void> dispose() async {
    if (isStatusConnected) await disconnect();
  }

  Future<void> connect() async {
    await _client.connect();
    _subscribe();
    _client.updatesStream!.listen(_listenMessages);
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

  void _subscribe() {
    _client.subscribe(_config.localTopic);
    _client.subscribe(_config.remoteTopic);
  }

  void _listenMessages(MqttMessageList data) {
    for (var el in data) {
      final isLocal = el.topic == _config.localTopic;
      final message = el.payload as MqttPublishMessage;

      if (isLocal) {
        _localMessageController.add(message.payload.message);
      } else {
        _remoteMessageController.add(message.payload.message);
      }
    }
  }
}
