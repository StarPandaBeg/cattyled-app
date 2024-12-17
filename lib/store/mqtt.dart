import 'package:cattyled_app/api/commands.dart';
import 'package:cattyled_app/repository/connection.dart';
import 'package:cattyled_app/repository/mqtt.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

abstract class MqttEvent {}

class _MqttConnectEvent extends MqttEvent {
  final bool state;

  _MqttConnectEvent({required this.state});
}

class MqttCommandEvent extends MqttEvent {
  final Command command;

  MqttCommandEvent(this.command);
}

class MqttState {
  final bool isConnected;

  MqttState({required this.isConnected});

  MqttState copyWith({bool? isConnected}) {
    return MqttState(
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class MqttBloc extends Bloc<MqttEvent, MqttState> {
  static final logger = Logger("MqttBloc");

  final _mqttRepo = MqttRepository();
  final _connRepo = ConnectionRepository();

  MqttBloc() : super(MqttState(isConnected: false)) {
    _setupNativeConnectionListener();
    _setupActualConnectionListener();
    _setupEventListeners();
  }

  @override
  Future<void> close() async {
    _connRepo.isConnectedNotifier
        .removeListener(_onNativeConnectionStatusChange);
    return super.close();
  }

  void _setupEventListeners() {
    on<_MqttConnectEvent>(
      (event, emit) {
        emit(state.copyWith(isConnected: event.state));
      },
    );
    on<MqttCommandEvent>(
      (event, emit) {
        final command = event.command;
        command.execute(_mqttRepo);
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
}
