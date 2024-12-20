import 'package:cattyled_app/config/config.dart';
import 'package:cattyled_app/util/qr_data.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:cattyled_app/config/config.dart';

enum ConfigLoadingState { none, loaded, notFound }

class ConfigLoader {
  static final logger = Logger("ConfigLoader");
  static const _configKey = "lampdata";

  Config _config = Config.placeholder();
  ConfigLoadingState _loadingState = ConfigLoadingState.none;

  Config get config => _config;
  ConfigLoadingState get loadingState => _loadingState;

  Future<ConfigLoadingState> load() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(_configKey)) {
      logger.warning("Unable to find config");
      _loadingState = ConfigLoadingState.notFound;
      return _loadingState;
    }

    final dataString = prefs.getString(_configKey)!;
    final data = parseData(dataString);

    _config = Config.fromQuery(data);
    _loadingState = ConfigLoadingState.loaded;
    logger.info("Config loaded");
    return _loadingState;
  }
}
