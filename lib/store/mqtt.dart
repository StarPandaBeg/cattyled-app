import 'dart:async';

import 'package:cattyled_app/api/commands.dart';
import 'package:cattyled_app/repository/connection.dart';
import 'package:cattyled_app/repository/mqtt.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:typed_data/typed_data.dart';

abstract class MqttEvent {}

class _MqttConnectEvent extends MqttEvent {
  final bool state;

  _MqttConnectEvent({required this.state});
}

class MqttPowerEvent extends MqttEvent {
  final bool value;

  MqttPowerEvent({required this.value});

  factory MqttPowerEvent.fromList(List<String> values) {
    return MqttPowerEvent(value: values[0] == "1");
  }
}

class MqttSyncEvent extends MqttEvent {
  final bool power;
  final int hue;
  final int saturation;
  final int value;
  final LampMode mode;

  MqttSyncEvent({
    required this.power,
    required this.hue,
    required this.saturation,
    required this.value,
    required this.mode,
  });

  factory MqttSyncEvent.fromList(List<String> values) {
    return MqttSyncEvent(
      power: values[0] == "1",
      hue: int.parse(values[1]),
      saturation: int.parse(values[2]),
      value: int.parse(values[3]),
      mode: LampMode.values[int.parse(values[4])],
    );
  }
}

class MqttCommandEvent extends MqttEvent {
  final Command command;

  MqttCommandEvent(this.command);
}

class MqttState {
  final bool isConnected;
  final bool isEnabled;

  MqttState({required this.isConnected, required this.isEnabled});

  MqttState copyWith({bool? isConnected, bool? isEnabled}) {
    return MqttState(
      isConnected: isConnected ?? this.isConnected,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  factory MqttState.initial() {
    return MqttState(isConnected: false, isEnabled: false);
  }
}

class MqttBloc extends Bloc<MqttEvent, MqttState> {
  static final logger = Logger("MqttBloc");

  final _mqttRepo = MqttRepository();
  final _connRepo = ConnectionRepository();
  final _parser = _MqttCommandParser();

  late final StreamSubscription<Uint8Buffer> _localMessageSubscription;
  late final StreamSubscription<Uint8Buffer> _remoteMessageSubscription;

  MqttBloc() : super(MqttState.initial()) {
    _setupNativeConnectionListener();
    _setupActualConnectionListener();
    _setupEventListeners();

    _localMessageSubscription = _mqttRepo.localMessages.listen(
      (p) => parseEvent(_parser.mapLocalCommandToEvent, p),
    );
    _remoteMessageSubscription = _mqttRepo.remoteMessages.listen(
      (p) => parseEvent(_parser.mapRemoteCommandToEvent, p),
    );
  }

  @override
  Future<void> close() async {
    _localMessageSubscription.cancel();
    _remoteMessageSubscription.cancel();
    _connRepo.isConnectedNotifier
        .removeListener(_onNativeConnectionStatusChange);
    return super.close();
  }

  void _setupEventListeners() {
    on<_MqttConnectEvent>(
      (event, emit) {
        emit(state.copyWith(isConnected: event.state));

        if (event.state) {
          add(MqttCommandEvent(CommandSyncRequest()));
        }
      },
    );
    on<MqttCommandEvent>(
      (event, emit) {
        final command = event.command;
        command.execute(_mqttRepo, add);
      },
    );
    on<MqttPowerEvent>(
      (event, emit) {
        emit(state.copyWith(isEnabled: event.value));
      },
    );
    on<MqttSyncEvent>(
      (event, emit) {
        add(MqttPowerEvent(value: event.power));
        // TODO: sync color & mode
      },
    );
  }

  void _setupNativeConnectionListener() {
    _connRepo.isConnectedNotifier.addListener(_onNativeConnectionStatusChange);
  }

  void _setupActualConnectionListener() {
    _mqttRepo.isConnectedNotifier.addListener(_onActualConnectionStatusChange);
  }

  Future<void> _onNativeConnectionStatusChange() async {
    final state = _connRepo.isConnected;
    try {
      final action = state ? _mqttRepo.connect : _mqttRepo.disconnect;
      await action();
      logger.info(
        "Successfully ${state ? 'connected to' : 'disconnected from'} MQTT server",
      );
    } catch (e) {
      logger.warning(
        "Unable to ${state ? 'connect to' : 'disconnect from'} MQTT server",
        [e],
      );
    }
  }

  void _onActualConnectionStatusChange() {
    final state = _mqttRepo.isConnected;
    add(_MqttConnectEvent(state: state));
  }

  void parseEvent(
    MqttEvent? Function(Uint8Buffer) onData,
    Uint8Buffer payload,
  ) {
    final event = onData(payload);
    if (event == null) return;
    add(event);
  }
}

class _MqttCommandParser {
  static final logger = Logger("MqttCommandParser");

  MqttEvent? mapLocalCommandToEvent(Uint8Buffer payload) {
    final data = _getArgs(payload);
    if (data.isEmpty) return null;

    final type = int.parse(data[0]);
    final args = data.sublist(1);
    logger.fine("Got command from Local with type $type");

    final command = _mapCommonEvents(type, args);
    if (command != null) return command;

    return switch (type) {
      _ => null,
    };
  }

  MqttEvent? mapRemoteCommandToEvent(Uint8Buffer payload) {
    final data = _getArgs(payload);
    if (data.isEmpty) return null;

    final type = int.parse(data[0]);
    final args = data.sublist(1);
    logger.fine("Got command from Remote with type $type");

    final command = _mapCommonEvents(type, args);
    if (command != null) return command;

    return switch (type) {
      1 => MqttSyncEvent.fromList(args),
      _ => null,
    };
  }

  List<String> _getArgs(Uint8Buffer payload) {
    final command = String.fromCharCodes(payload);
    if (!command.startsWith("CATL:")) return [];
    return command.substring(5).split(",");
  }

  MqttEvent? _mapCommonEvents(int type, List<String> args) {
    return switch (type) {
      3 => MqttPowerEvent.fromList(args),
      _ => null,
    };
  }
}
