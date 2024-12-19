import 'dart:async';

import 'package:cattyled_app/api/commands.dart';
import 'package:cattyled_app/repository/connection.dart';
import 'package:cattyled_app/repository/mqtt.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:typed_data/typed_data.dart';

abstract class LampEvent {}

class _LampConnectEvent extends LampEvent {
  final bool state;

  _LampConnectEvent({required this.state});
}

class LampPowerEvent extends LampEvent {
  final bool value;

  LampPowerEvent({required this.value});

  factory LampPowerEvent.fromList(List<String> values) {
    return LampPowerEvent(value: values[0] == "1");
  }
}

class LampColorEvent extends LampEvent {
  final Color value;

  LampColorEvent({required this.value});

  factory LampColorEvent.fromList(List<String> values) {
    final hue = int.parse(values[0]) / 255 * 360;
    final saturation = int.parse(values[1]) / 255;
    final value = int.parse(values[2]) / 255;
    final color = HSVColor.fromAHSV(1, hue, saturation, value);
    return LampColorEvent(value: color.toColor());
  }
}

class LampModeEvent extends LampEvent {
  final LampMode value;

  LampModeEvent({required this.value});

  factory LampModeEvent.fromList(List<String> values) {
    return LampModeEvent(value: LampMode.values[int.parse(values[0])]);
  }
}

class LampBrightnessEvent extends LampEvent {
  final int value;

  LampBrightnessEvent({required this.value});

  factory LampBrightnessEvent.fromList(List<String> values) {
    return LampBrightnessEvent(value: int.parse(values[0]));
  }
}

class LampStatusEvent extends LampEvent {
  final int brightness;
  final bool isRemoteActive;

  LampStatusEvent({required this.brightness, required this.isRemoteActive});

  factory LampStatusEvent.fromList(List<String> values) {
    return LampStatusEvent(
      brightness: int.parse(values[0]),
      isRemoteActive: values[2] == "1",
    );
  }
}

class LampSyncEvent extends LampEvent {
  final bool power;
  final Color color;
  final LampMode mode;

  LampSyncEvent({
    required this.power,
    required this.color,
    required this.mode,
  });

  factory LampSyncEvent.fromList(List<String> values) {
    final hue = int.parse(values[1]) / 255 * 360;
    final saturation = int.parse(values[2]) / 255;
    final value = int.parse(values[3]) / 255;
    final color = HSVColor.fromAHSV(1, hue, saturation, value);

    return LampSyncEvent(
      power: values[0] == "1",
      color: color.toColor(),
      mode: LampMode.values[int.parse(values[4])],
    );
  }
}

class LampCommandEvent extends LampEvent {
  final Command command;

  LampCommandEvent(this.command);
}

class LampState {
  final bool isConnected;
  final bool isSynced;
  final bool isEnabled;
  final Color color;
  final LampMode mode;
  final int brightness;
  final bool isRemoteActive;

  LampState({
    required this.isConnected,
    required this.isSynced,
    required this.isEnabled,
    required this.color,
    required this.mode,
    required this.brightness,
    required this.isRemoteActive,
  });

  LampState copyWith({
    bool? isConnected,
    bool? isSynced,
    bool? isEnabled,
    Color? color,
    LampMode? mode,
    int? brightness,
    bool? isRemoteActive,
  }) {
    return LampState(
      isConnected: isConnected ?? this.isConnected,
      isSynced: isSynced ?? this.isSynced,
      isEnabled: isEnabled ?? this.isEnabled,
      color: color ?? this.color,
      mode: mode ?? this.mode,
      brightness: brightness ?? this.brightness,
      isRemoteActive: isRemoteActive ?? this.isRemoteActive,
    );
  }

  factory LampState.initial() {
    return LampState(
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

class LampBloc extends Bloc<LampEvent, LampState> {
  static final logger = Logger("LampBloc");

  late MqttRepository _mqttRepo;
  final _connRepo = ConnectionRepository();
  final _parser = _CommandParser();

  late final StreamSubscription<Uint8Buffer> _localMessageSubscription;
  late final StreamSubscription<Uint8Buffer> _remoteMessageSubscription;

  Timer? _periodicTimer;
  DateTime _lastUpdateTime = DateTime.now();

  LampBloc() : super(LampState.initial()) {
    _mqttRepo = GetIt.instance<MqttRepository>();

    _setupNativeConnectionListener();
    _setupActualConnectionListener();
    _setupEventListeners();

    _localMessageSubscription = _mqttRepo.localMessages.listen(
      (p) => _parseEvent(_parser.mapLocalCommandToEvent, p),
    );
    _remoteMessageSubscription = _mqttRepo.remoteMessages.listen(
      (p) => _parseEvent(_parser.mapRemoteCommandToEvent, p),
    );

    add(_LampConnectEvent(state: _mqttRepo.isConnected));
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
    on<LampEvent>(
      (event, emit) {
        _lastUpdateTime = DateTime.now();
      },
    );
    on<_LampConnectEvent>(
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
    on<LampCommandEvent>(
      (event, emit) {
        final command = event.command;
        command.execute(_mqttRepo, add);
      },
    );
    on<LampPowerEvent>(
      (event, emit) {
        emit(state.copyWith(isEnabled: event.value));
      },
    );
    on<LampColorEvent>(
      (event, emit) {
        emit(state.copyWith(color: event.value));
      },
    );
    on<LampModeEvent>(
      (event, emit) {
        emit(state.copyWith(mode: event.value));
      },
    );
    on<LampBrightnessEvent>(
      (event, emit) {
        emit(state.copyWith(brightness: event.value));
      },
    );
    on<LampStatusEvent>(
      (event, emit) {
        emit(state.copyWith(
          brightness: event.brightness,
          isRemoteActive: event.isRemoteActive,
        ));
      },
    );
    on<LampSyncEvent>(
      (event, emit) {
        add(LampPowerEvent(value: event.power));
        add(LampColorEvent(value: event.color));
        add(LampModeEvent(value: event.mode));
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
    final isConnected = _connRepo.isConnected;
    if (isConnected == state.isConnected) return;
    try {
      final action = isConnected ? _mqttRepo.connect : _mqttRepo.disconnect;
      await action();
      logger.info(
        "Successfully ${isConnected ? 'connected to' : 'disconnected from'} MQTT server",
      );
    } catch (e) {
      logger.warning(
        "Unable to ${isConnected ? 'connect to' : 'disconnect from'} MQTT server",
        [e],
      );
    }
  }

  void _onActualConnectionStatusChange() {
    final state = _mqttRepo.isConnected;
    add(_LampConnectEvent(state: state));
  }

  void _parseEvent(
    LampEvent? Function(Uint8Buffer) onData,
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
    if (!statusOnly) add(LampCommandEvent(CommandSyncRequest()));
    add(LampCommandEvent(CommandStatusRequest()));
  }
}

class _CommandParser {
  static final logger = Logger("CommandParser");

  LampEvent? mapLocalCommandToEvent(Uint8Buffer payload) {
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

  LampEvent? mapRemoteCommandToEvent(Uint8Buffer payload) {
    final data = _getArgs(payload);
    if (data.isEmpty) return null;

    final type = int.parse(data[0]);
    final args = data.sublist(1);
    logger.fine("Got command from Remote with type $type");

    final command = _mapCommonEvents(type, args);
    if (command != null) return command;

    return switch (type) {
      1 => LampSyncEvent.fromList(args),
      7 => LampBrightnessEvent.fromList(args),
      8 => LampStatusEvent.fromList(args),
      _ => null,
    };
  }

  List<String> _getArgs(Uint8Buffer payload) {
    final command = String.fromCharCodes(payload);
    if (!command.startsWith("CATL:")) return [];
    return command.substring(5).split(",");
  }

  LampEvent? _mapCommonEvents(int type, List<String> args) {
    return switch (type) {
      3 => LampPowerEvent.fromList(args),
      4 => LampColorEvent.fromList(args),
      5 => LampModeEvent.fromList(args),
      _ => null,
    };
  }
}
