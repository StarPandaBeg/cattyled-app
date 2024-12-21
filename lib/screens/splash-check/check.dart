import 'package:cattyled_app/store/lamp/store.dart';
import 'package:cattyled_app/util/updates.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LampChecker extends ChangeNotifier {
  static final _logger = Logger("LampChecker");

  WebSocketChannel? _connection;
  bool _isOk = false;
  String _lastError = "";
  String _foundIp = "";
  bool _needUpdate = false;

  bool get isOk => _isOk;
  bool get needUpdate => _needUpdate;
  String get lastError => _lastError;
  String get foundIp => _foundIp;

  @override
  void dispose() {
    _connection?.sink.close();
    super.dispose();
  }

  Future<void> run() async {
    _isOk = false;
    _lastError = "";

    final lampIp = await _scanNetwork();
    if (lampIp == null) {
      _isOk = false;
      notifyListeners();
      return;
    }
    _foundIp = lampIp;
    await _doConnect(lampIp);
  }

  Future<String?> _scanNetwork() async {
    final ip = await NetworkInfo().getWifiIP();
    if (ip == null) {
      _logger.warning("Failed to get WiFi IP (NetworkInfo.getWifiIP())");
      _lastError =
          "Не удалось определить IP-адрес Вашего устройства. Проверьте подключение к WiFi.";
      return null;
    }

    final targetIp = await findAvailableIp(ip);
    if (targetIp == null) {
      _logger.warning("Failed to get Lamp IP");
      _lastError =
          "Не удалось определить IP-адрес лампы. Убедитесь, что она подключена к той же сети, что и Вы.";
      return null;
    }
    _logger.info("Found lamp IP: $targetIp");
    return targetIp;
  }

  Future<bool> _doConnect(String ip) async {
    final uri = Uri.parse('ws://$ip/ws');
    _connection = WebSocketChannel.connect(uri);

    try {
      await _connection!.ready;
    } catch (e) {
      _lastError =
          "Не удалось подключиться к лампе. Убедитесь, что она подключена к той же сети, что и Вы.";
      return false;
    }

    _connection!.stream.listen((message) => _parseEvent(message as String));
    _connection!.sink.add("CATL:-7");

    return true;
  }

  void _parseEvent(String data) {
    final parts = parseCommandFromString(data);
    final type = int.parse(parts[0]);
    final args = parts.sublist(1);

    if (type != -8) return;
    final firmwareVersion = Version.parse(args[0]);

    _needUpdate = firmwareVersion < Version(1, 2, 0);
    _isOk = true;
    notifyListeners();
  }
}
