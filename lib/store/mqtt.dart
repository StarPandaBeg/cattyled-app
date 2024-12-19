import 'dart:async';

import 'package:cattyled_app/api/commands.dart';
import 'package:cattyled_app/repository/connection.dart';
import 'package:cattyled_app/repository/mqtt.dart';
import 'package:flutter/widgets.dart';
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

class MqttColorEvent extends MqttEvent {
  final Color value;

  MqttColorEvent({required this.value});

  factory MqttColorEvent.fromList(List<String> values) {
    final hue = int.parse(values[0]) / 255 * 360;
    final saturation = int.parse(values[1]) / 255;
    final value = int.parse(values[2]) / 255;
    final color = HSVColor.fromAHSV(1, hue, saturation, value);
    return MqttColorEvent(value: color.toColor());
  }
}

class MqttModeEvent extends MqttEvent {
  final LampMode value;

  MqttModeEvent({required this.value});

  factory MqttModeEvent.fromList(List<String> values) {
    return MqttModeEvent(value: LampMode.values[int.parse(values[0])]);
  }
}

class MqttBrightnessEvent extends MqttEvent {
  final int value;

  MqttBrightnessEvent({required this.value});

  factory MqttBrightnessEvent.fromList(List<String> values) {
    return MqttBrightnessEvent(value: int.parse(values[0]));
  }
}

class MqttStatusEvent extends MqttEvent {
  final int brightness;
  final bool isRemoteActive;

  MqttStatusEvent({required this.brightness, required this.isRemoteActive});

  factory MqttStatusEvent.fromList(List<String> values) {
    return MqttStatusEvent(
      brightness: int.parse(values[0]),
      isRemoteActive: values[2] == "1",
    );
  }
}

class MqttSyncEvent extends MqttEvent {
  final bool power;
  final Color color;
  final LampMode mode;

  MqttSyncEvent({
    required this.power,
    required this.color,
    required this.mode,
  });

  factory MqttSyncEvent.fromList(List<String> values) {
    final hue = int.parse(values[1]) / 255 * 360;
    final saturation = int.parse(values[2]) / 255;
    final value = int.parse(values[3]) / 255;
    final color = HSVColor.fromAHSV(1, hue, saturation, value);

    return MqttSyncEvent(
      power: values[0] == "1",
      color: color.toColor(),
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
  final bool isSynced;
  final bool isEnabled;
  final Color color;
  final LampMode mode;
  final int brightness;
  final bool isRemoteActive;

  MqttState({
    required this.isConnected,
    required this.isSynced,
    required this.isEnabled,
    required this.color,
    required this.mode,
    required this.brightness,
    required this.isRemoteActive,
  });

  MqttState copyWith({
    bool? isConnected,
    bool? isSynced,
    bool? isEnabled,
    Color? color,
    LampMode? mode,
    int? brightness,
    bool? isRemoteActive,
  }) {
    return MqttState(
      isConnected: isConnected ?? this.isConnected,
      isSynced: isSynced ?? this.isSynced,
      isEnabled: isEnabled ?? this.isEnabled,
      color: color ?? this.color,
      mode: mode ?? this.mode,
      brightness: brightness ?? this.brightness,
      isRemoteActive: isRemoteActive ?? this.isRemoteActive,
    );
  }

  factory MqttState.initial() {
    return MqttState(
      isConnected: false,
      isSynced: false,
      isEnabled: false,
      color: const Color(0xffff0000),
      mode: LampMode.classic,
      brightness: 0,
      isRemoteActive: false,
    );
  }
}

class MqttBloc extends Bloc<MqttEvent, MqttState> {
  static final logger = Logger("MqttBloc");

  final _mqttRepo = MqttRepository();
  final _connRepo = ConnectionRepository();
  final _parser = _MqttCommandParser();

  late final StreamSubscription<Uint8Buffer> _localMessageSubscription;
  late final StreamSubscription<Uint8Buffer> _remoteMessageSubscription;

  Timer? _periodicTimer;
  DateTime _lastUpdateTime = DateTime.now();

  MqttBloc() : super(MqttState.initial()) {
    _setupNativeConnectionListener();
    _setupActualConnectionListener();
    _setupEventListeners();

    _localMessageSubscription = _mqttRepo.localMessages.listen(
      (p) => _parseEvent(_parser.mapLocalCommandToEvent, p),
    );
    _remoteMessageSubscription = _mqttRepo.remoteMessages.listen(
      (p) => _parseEvent(_parser.mapRemoteCommandToEvent, p),
    );
  }

  @override
  Future<void> close() async {
    _periodicTimer?.cancel();
    _localMessageSubscription.cancel();
    _remoteMessageSubscription.cancel();
    _connRepo.isConnectedNotifier
        .removeListener(_onNativeConnectionStatusChange);
    return super.close();
  }

  void _setupEventListeners() {
    on<MqttEvent>(
      (event, emit) {
        _lastUpdateTime = DateTime.now();
      },
    );
    on<_MqttConnectEvent>(
      (event, emit) {
        emit(state.copyWith(isConnected: event.state));

        if (event.state) {
          _requestUpdate();
          _setupPeriodicUpdate();
        } else {
          if (_periodicTimer != null) {
            _periodicTimer!.cancel();
            _periodicTimer = null;
            emit(state.copyWith(isSynced: false));
          }
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
    on<MqttColorEvent>(
      (event, emit) {
        emit(state.copyWith(color: event.value));
      },
    );
    on<MqttModeEvent>(
      (event, emit) {
        emit(state.copyWith(mode: event.value));
      },
    );
    on<MqttBrightnessEvent>(
      (event, emit) {
        emit(state.copyWith(brightness: event.value));
      },
    );
    on<MqttStatusEvent>(
      (event, emit) {
        emit(state.copyWith(
          brightness: event.brightness,
          isRemoteActive: event.isRemoteActive,
        ));
      },
    );
    on<MqttSyncEvent>(
      (event, emit) {
        add(MqttPowerEvent(value: event.power));
        add(MqttColorEvent(value: event.color));
        add(MqttModeEvent(value: event.mode));
        emit(state.copyWith(isSynced: true));
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

  void _parseEvent(
    MqttEvent? Function(Uint8Buffer) onData,
    Uint8Buffer payload,
  ) {
    final event = onData(payload);
    if (event == null) return;
    add(event);
  }

  void _setupPeriodicUpdate() {
    const period = Duration(seconds: 10);
    _periodicTimer = Timer.periodic(period, (_) {
      final timeSinceInteraction = DateTime.now().difference(_lastUpdateTime);
      final statusOnly = timeSinceInteraction.inSeconds < 20 && state.isSynced;
      _requestUpdate(statusOnly: statusOnly);
    });
  }

  void _requestUpdate({bool statusOnly = false}) {
    logger.fine("Requesting update");
    if (!statusOnly) add(MqttCommandEvent(CommandSyncRequest()));
    add(MqttCommandEvent(CommandStatusRequest()));
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
      7 => MqttBrightnessEvent.fromList(args),
      8 => MqttStatusEvent.fromList(args),
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
      4 => MqttColorEvent.fromList(args),
      5 => MqttModeEvent.fromList(args),
      _ => null,
    };
  }
}
