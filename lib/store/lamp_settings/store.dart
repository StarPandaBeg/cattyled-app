import 'dart:async';

import 'package:cattyled_app/repository/connection.dart';
import 'package:cattyled_app/repository/mqtt.dart';
import 'package:cattyled_app/store/lamp_settings/commands.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:typed_data/typed_data.dart';

export 'package:cattyled_app/store/lamp_settings/commands.dart';

abstract class LampSettingsEvent {}

class _LampSettingsConnectEvent extends LampSettingsEvent {
  final bool state;

  _LampSettingsConnectEvent({required this.state});
}

class LampSettingsCommandEvent extends LampSettingsEvent {
  final Command command;

  LampSettingsCommandEvent(this.command);
}

class LampSettingsWifiEvent extends LampSettingsEvent {
  final String ssid;
  final String password;

  LampSettingsWifiEvent({required this.ssid, required this.password});

  factory LampSettingsWifiEvent.fromList(List<String> values) {
    return LampSettingsWifiEvent(ssid: values[0], password: values[1]);
  }
}

class LampSettingsIpEvent extends LampSettingsEvent {
  final String ip;

  LampSettingsIpEvent({required this.ip});

  factory LampSettingsIpEvent.fromList(List<String> values) {
    return LampSettingsIpEvent(ip: values[0]);
  }
}

class LampSettingsMqttEvent extends LampSettingsEvent {
  final bool enabled;
  final String host;
  final int port;
  final String prefix;
  final bool hasCreds;
  final String? user;
  final String? password;

  LampSettingsMqttEvent({
    required this.enabled,
    required this.host,
    required this.port,
    required this.prefix,
    required this.hasCreds,
    this.user,
    this.password,
  });

  factory LampSettingsMqttEvent.fromList(List<String> values) {
    return LampSettingsMqttEvent(
      enabled: values[0] == "1",
      host: values[1],
      port: int.parse(values[2]),
      prefix: values[3],
      hasCreds: values[4] == "1",
      user: values[4] == "1" ? values[5] : "",
      password: values[4] == "1" ? values[6] : "",
    );
  }
}

class LampSettingsIdEvent extends LampSettingsEvent {
  final String localId;
  final String remoteId;

  LampSettingsIdEvent({
    required this.localId,
    required this.remoteId,
  });

  factory LampSettingsIdEvent.fromList(List<String> values) {
    return LampSettingsIdEvent(
      localId: values[0],
      remoteId: values[1],
    );
  }
}

class LampSettingsState {
  final bool isConnected;
  final bool isSynced;
  final String wifiSSID;
  final String wifiPassword;
  final String wifiIp;

  final bool mqttEnabled;
  final String mqttHost;
  final int mqttPort;
  final String mqttPrefix;
  final bool mqttHasCreds;
  final String? mqttUser;
  final String? mqttPassword;
  final String mqttLocalId;
  final String mqttRemoteId;

  LampSettingsState({
    required this.isConnected,
    required this.isSynced,
    required this.wifiSSID,
    required this.wifiPassword,
    required this.wifiIp,
    required this.mqttEnabled,
    required this.mqttHost,
    required this.mqttPort,
    required this.mqttPrefix,
    required this.mqttHasCreds,
    required this.mqttLocalId,
    required this.mqttRemoteId,
    this.mqttUser,
    this.mqttPassword,
  });

  LampSettingsState copyWith({
    bool? isConnected,
    bool? isSynced,
    String? wifiSSID,
    String? wifiPassword,
    String? wifiIp,
    bool? mqttEnabled,
    String? mqttHost,
    int? mqttPort,
    String? mqttPrefix,
    bool? mqttHasCreds,
    String? mqttUser,
    String? mqttPassword,
    String? mqttLocalId,
    String? mqttRemoteId,
  }) {
    return LampSettingsState(
      isConnected: isConnected ?? this.isConnected,
      isSynced: isSynced ?? this.isSynced,
      wifiSSID: wifiSSID ?? this.wifiSSID,
      wifiPassword: wifiPassword ?? this.wifiPassword,
      wifiIp: wifiIp ?? this.wifiIp,
      mqttEnabled: mqttEnabled ?? this.mqttEnabled,
      mqttHost: mqttHost ?? this.mqttHost,
      mqttPort: mqttPort ?? this.mqttPort,
      mqttPrefix: mqttPrefix ?? this.mqttPrefix,
      mqttHasCreds: mqttHasCreds ?? this.mqttHasCreds,
      mqttUser: mqttUser ?? this.mqttUser,
      mqttPassword: mqttPassword ?? this.mqttPassword,
      mqttLocalId: mqttLocalId ?? this.mqttLocalId,
      mqttRemoteId: mqttRemoteId ?? this.mqttRemoteId,
    );
  }

  factory LampSettingsState.initial() {
    return LampSettingsState(
      isConnected: false,
      isSynced: false,
      wifiSSID: "",
      wifiPassword: "",
      wifiIp: "",
      mqttEnabled: false,
      mqttHost: "",
      mqttPort: 1883,
      mqttPrefix: "",
      mqttHasCreds: false,
      mqttLocalId: "",
      mqttRemoteId: "",
    );
  }
}

class LampSettingsBloc extends Bloc<LampSettingsEvent, LampSettingsState> {
  static final logger = Logger("LampSettingsBloc");

  late MqttRepository _mqttRepo;
  final _connRepo = ConnectionRepository();
  final _parser = _CommandParser();

  late final StreamSubscription<Uint8Buffer> _localMessageSubscription;
  late final StreamSubscription<Uint8Buffer> _remoteMessageSubscription;

  Timer? _periodicTimer;
  DateTime _lastUpdateTime = DateTime.now();

  LampSettingsBloc() : super(LampSettingsState.initial()) {
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

    add(_LampSettingsConnectEvent(state: _mqttRepo.isConnected));
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
    on<LampSettingsEvent>(
      (event, emit) {
        _lastUpdateTime = DateTime.now();
      },
    );
    on<_LampSettingsConnectEvent>(
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
    on<LampSettingsCommandEvent>(
      (event, emit) {
        final command = event.command;
        command.execute(_mqttRepo, add);
      },
    );
    on<LampSettingsWifiEvent>(
      (event, emit) {
        emit(
          state.copyWith(
            wifiSSID: event.ssid,
            wifiPassword: event.password,
            isSynced: true,
          ),
        );
      },
    );
    on<LampSettingsIpEvent>(
      (event, emit) {
        emit(
          state.copyWith(
            wifiIp: event.ip,
            isSynced: true,
          ),
        );
      },
    );
    on<LampSettingsMqttEvent>(
      (event, emit) {
        emit(
          state.copyWith(
            mqttEnabled: event.enabled,
            mqttHost: event.host,
            mqttPort: event.port,
            mqttPrefix: event.prefix,
            mqttHasCreds: event.hasCreds,
            mqttUser: event.user,
            mqttPassword: event.password,
            isSynced: true,
          ),
        );
      },
    );
    on<LampSettingsIdEvent>(
      (event, emit) {
        emit(
          state.copyWith(
            mqttLocalId: event.localId,
            mqttRemoteId: event.remoteId,
            isSynced: true,
          ),
        );
      },
    );
  }

  void _setupPeriodicUpdate() {
    const period = Duration(seconds: 10);
    _periodicTimer = Timer.periodic(period, (_) {
      final timeSinceInteraction = DateTime.now().difference(_lastUpdateTime);
      final needUpdate = timeSinceInteraction.inSeconds < 20 && state.isSynced;
      needUpdate ? _requestUpdate() : null;
    });
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
    add(_LampSettingsConnectEvent(state: state));
  }

  void _parseEvent(
    LampSettingsEvent? Function(Uint8Buffer) onData,
    Uint8Buffer payload,
  ) {
    final event = onData(payload);
    if (event == null) return;
    add(event);
  }

  void _requestUpdate() {
    logger.fine("Requesting update");

    add(LampSettingsCommandEvent(CommandWifiRequest()));
    add(LampSettingsCommandEvent(CommandIpRequest()));
    add(LampSettingsCommandEvent(CommandMqttRequest()));
    add(LampSettingsCommandEvent(CommandIdRequest()));
    // if (!statusOnly) add(LampCommandEvent(CommandSyncRequest()));
    // add(LampCommandEvent(CommandStatusRequest()));
  }
}

class _CommandParser {
  static final logger = Logger("CommandParser");

  LampSettingsEvent? mapLocalCommandToEvent(Uint8Buffer payload) {
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

  LampSettingsEvent? mapRemoteCommandToEvent(Uint8Buffer payload) {
    final data = _getArgs(payload);
    if (data.isEmpty) return null;

    final type = int.parse(data[0]);
    final args = data.sublist(1);
    logger.fine("Got command from Remote with type $type");

    final command = _mapCommonEvents(type, args);
    if (command != null) return command;

    return switch (type) {
      -2 => LampSettingsWifiEvent.fromList(args),
      -6 => LampSettingsMqttEvent.fromList(args),
      -18 => LampSettingsIpEvent.fromList(args),
      -20 => LampSettingsIdEvent.fromList(args),
      _ => null,
    };
  }

  List<String> _getArgs(Uint8Buffer payload) {
    final command = String.fromCharCodes(payload);
    if (!command.startsWith("CATL:")) return [];
    return command.substring(5).split(",");
  }

  LampSettingsEvent? _mapCommonEvents(int type, List<String> args) {
    return switch (type) {
      _ => null,
    };
  }
}
