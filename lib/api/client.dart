import 'dart:async';
import 'dart:collection';

import 'package:cattyled_app/config/config.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:typed_data/typed_data.dart';

typedef MqttMessageList = List<MqttReceivedMessage<MqttMessage>>;

class MqttClient {
  static final logger = Logger("MqttClient");

  final Config _config;
  late final MqttServerClient _client;
  final _pendingMessages = Queue<_MqttMessage>();
  final ValueNotifier<bool> _isConnected = ValueNotifier(false);

  ValueListenable<bool> get isConnected => _isConnected;
  bool get isStatusConnected =>
      _client.connectionStatus?.state == MqttConnectionState.connected;
  Stream<MqttMessageList>? get updatesStream => _client.updates;

  MqttClient(Config config) : _config = config {
    _client = MqttServerClient.withPort(config.mqttHost, "", config.mqttPort)
      ..keepAlivePeriod = 3600
      ..autoReconnect = true
      ..onConnected = _onConnected
      ..onDisconnected = _onDisconnected
      ..setProtocolV311();
  }

  Future<void> connect() async {
    try {
      logger.fine("Connecting to MQTT server");
      await _client.connect(_config.mqttUser, _config.mqttPassword);
      _isConnected.value = true;
    } catch (e) {
      logger.warning("Failed to connect to MQTT server", [e]);
      _isConnected.value = false;
    }
  }

  Future<void> disconnect() async {
    try {
      logger.fine("Disconnecting from MQTT server");
      _client.disconnect();
      _isConnected.value = false;
    } catch (e) {
      logger.warning("Failed to disconnect from MQTT server", [e]);
    }
  }

  void send(
    String topic,
    Uint8Buffer data, {
    bool keepAfterDisconnect = false,
  }) {
    if (isStatusConnected) {
      try {
        logger.fine("Sending message to $topic");
        _client.publishMessage(topic, MqttQos.atLeastOnce, data);
      } catch (e) {
        logger.warning("Failed to send MQTT message", [e]);
      }
      return;
    }
    if (keepAfterDisconnect) {
      logger.fine("Caching message to $topic");
      final message = _MqttMessage(topic: topic, message: data);
      _pendingMessages.add(message);
    }
  }

  Subscription? subscribe(String topic, {MqttQos qos = MqttQos.atLeastOnce}) {
    logger.fine("Subscribing to $topic");
    return _client.subscribe(topic, qos);
  }

  _onConnected() {
    final queue = Queue.from(_pendingMessages);
    while (queue.isNotEmpty) {
      final message = _pendingMessages.removeFirst();
      logger.fine("Restore message to ${message.topic} from cache");
      send(message.topic, message.message, keepAfterDisconnect: true);
    }
  }

  _onDisconnected() {
    _isConnected.value = false;
  }
}

class _MqttMessage {
  final String topic;
  final Uint8Buffer message;

  _MqttMessage({required this.topic, required this.message});
}
