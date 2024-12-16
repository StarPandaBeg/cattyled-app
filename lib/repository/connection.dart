import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

const _connectedStatuses = [
  ConnectivityResult.wifi,
  ConnectivityResult.mobile,
  ConnectivityResult.ethernet
];

class ConnectionRepository {
  static final logger = Logger("ConnectionRepository");

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final ValueNotifier<bool> _isConnected = ValueNotifier(false);

  bool get isConnected => _isConnected.value;
  ValueListenable<bool> get isConnectedNotifier => _isConnected;

  ConnectionRepository() {
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_onConnectionStatusChange);
  }

  void dispose() {
    _connectivitySubscription.cancel();
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException {
      logger.shout('Couldn\'t check connectivity status');
      rethrow;
    }
    _onConnectionStatusChange(result);
  }

  void _onConnectionStatusChange(List<ConnectivityResult> state) {
    _isConnected.value = state.indexWhere(_connectedStatuses.contains) != -1;
  }
}
