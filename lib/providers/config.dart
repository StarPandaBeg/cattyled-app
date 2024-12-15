import 'package:cattyled_app/config/config.dart';
import 'package:flutter/widgets.dart';

enum ConfigLoadingState { none, loaded, notFound }

class ConfigProvider with ChangeNotifier {
  Config _config = Config.placeholder();
  ConfigLoadingState _loadingState = ConfigLoadingState.none;

  Config get config => _config;
  ConfigLoadingState get loadingState => _loadingState;

  Future<void> load() async {
    _config = Config(
      mqttHost: const String.fromEnvironment("MQTT_HOST"),
      lampId: const String.fromEnvironment("LAMP_ID"),
      lampLocalName: const String.fromEnvironment("LAMP_LOCAL_ID"),
      lampRemoteName: const String.fromEnvironment("LAMP_REMOTE_ID"),
    );
    _loadingState = ConfigLoadingState.loaded;
    notifyListeners();
  }
}
